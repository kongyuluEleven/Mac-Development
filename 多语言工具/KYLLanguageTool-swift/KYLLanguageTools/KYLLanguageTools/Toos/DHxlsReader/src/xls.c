/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 * This file is part of libxls -- A multiplatform, C/C++ library
 * for parsing Excel(TM) files.
 *
 * Redistribution and use in source and binary forms, with or without modification, are
 * permitted provided that the following conditions are met:
 *
 *    1. Redistributions of source code must retain the above copyright notice, this list of
 *       conditions and the following disclaimer.
 *
 *    2. Redistributions in binary form must reproduce the above copyright notice, this list
 *       of conditions and the following disclaimer in the documentation and/or other materials
 *       provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY David Hoerl ''AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL David Hoerl OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * Copyright 2004 Komarov Valery
 * Copyright 2006 Christophe Leitienne
 * Copyright 2008-2012 David Hoerl
 *
 */

#include "config.h"

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>

#include <memory.h>
#include <math.h>
#include <sys/types.h>
#include <string.h>
#include <wchar.h>
#include <assert.h>

#include "xls.h"

#define min(a,b) ((a) < (b) ? (a) : (b))

int xls_debug=0;	// now global, so users can turn it on

static double NumFromRk(BYTE* rk);

extern void xls_addSST(xlsWorkBook* pWB,SST* sst,DWORD size);
extern void xls_appendSST(xlsWorkBook* pWB,BYTE* buf,DWORD size);
extern void xls_addFormat(xlsWorkBook* pWB,FORMAT* format);
extern BYTE* xls_addSheet(xlsWorkBook* pWB,BOUNDSHEET* bs);
extern void xls_addRow(xlsWorkSheet* pWS,ROW* row);
extern void xls_makeTable(xlsWorkSheet* pWS);
extern struct st_cell_data *xls_addCell(xlsWorkSheet* pWS,BOF* bof,BYTE* buf);
extern BYTE *xls_addFont(xlsWorkBook* pWB,FONT* font);
extern void xls_addXF8(xlsWorkBook* pWB,XF8* xf);
extern void xls_addXF5(xlsWorkBook* pWB,XF5* xf);
extern void xls_addColinfo(xlsWorkSheet* pWS,COLINFO* colinfo);
extern void xls_mergedCells(xlsWorkSheet* pWS,BOF* bof,BYTE* buf);
extern void xls_parseWorkBook(xlsWorkBook* pWB);
extern void xls_preparseWorkSheet(xlsWorkSheet* pWS);
extern void xls_formatColumn(xlsWorkSheet* pWS);
extern void xls_parseWorkSheet(xlsWorkSheet* pWS);
extern void xls_dumpSummary(char *buf,int isSummary,xlsSummaryInfo	*pSI);

#pragma pack(push, 1)

typedef struct {
	uint32_t		format[4];
	uint32_t		offset;
} sectionList;

typedef struct {
	uint16_t		sig;
	uint16_t		_empty;
	uint32_t		os;
	uint32_t		format[4];
	uint32_t		count;
	sectionList		secList[0];
} header;

typedef struct {
	uint32_t		propertyID;
	uint32_t		sectionOffset;
} propertyList;

typedef struct {
	uint32_t		length;
	uint32_t		numProperties;
	propertyList	properties[0];
} sectionHeader;

typedef struct {
	uint32_t		propertyID;
	uint32_t		data[0];
} property;

#pragma pack(pop)

int xls(int debug)
{
	xls_debug = debug;
    return 1;
}

void xls_addSST(xlsWorkBook* pWB,SST* sst,DWORD size)
{
    verbose("xls_addSST");

    pWB->sst.continued=0;
    pWB->sst.lastln=0;
    pWB->sst.lastid=0;
    pWB->sst.lastrt=0;
    pWB->sst.lastsz=0;

    pWB->sst.count = sst->num;
    pWB->sst.string =(struct str_sst_string *)calloc(pWB->sst.count, sizeof(struct str_sst_string));
    xls_appendSST(pWB,&sst->strings,size-8);
}

void xls_appendSST(xlsWorkBook* pWB,BYTE* buf,DWORD size)
{
    DWORD ln;	// String character count
    DWORD ofs;	// Current offset in SST buffer
    DWORD rt;	// Count of rich text formatting runs
    DWORD sz;	// Size of asian phonetic settings block
    BYTE flag;	// String flags
    BYTE* ret;

    if (xls_debug) {
	    printf("xls_appendSST %u\n", size);
    }

	sz = rt = ln = 0;	// kch
    ofs=0;

	while(ofs<size)
    {
        int ln_toread;

        // Restore state when we're in a continue record
        // or read string length
        if (pWB->sst.continued)
        {
            ln=pWB->sst.lastln;
            rt=pWB->sst.lastrt;
            sz=pWB->sst.lastsz;
        }
        else
        {
            ln=*(WORD_UA *)(buf+ofs);
            rt = 0;
            sz = 0;

            ofs+=2;
        }

		if (xls_debug) {
        	printf("ln=%u\n", ln);
		}

        // Read flags
        if ( (!pWB->sst.continued) || ( (pWB->sst.continued) && (ln != 0) ) )
        {
            flag=*(BYTE *)(buf+ofs);
            ofs++;

            // Count of rich text formatting runs
            if (flag & 0x8)
            {
                rt=*(WORD_UA *)(buf+ofs);
                ofs+=2;
            }

            // Size of asian phonetic settings block
            if (flag & 0x4)
            {
                sz=*(DWORD_UA *)(buf+ofs);
                ofs+=4;

				if (xls_debug) {
					printf("sz=%u\n", sz);
				}
            }
        }
        else
        {
            flag = 0;
        }

		// Read characters (compressed or not)
        ln_toread = 0;
        if (ln > 0)
        {
            if (flag & 0x1)
            {
                ln_toread = min((size-ofs)/2, ln);
                size_t new_len = 0;
                ret=unicode_decode(buf+ofs,ln_toread*2,&new_len,pWB->charset);

                if (ret == NULL)
                {
                    ret = (BYTE *)strdup("*failed to decode utf16*");
                    new_len = strlen((char *)ret);
                }

                ret = (BYTE *)realloc(ret,new_len+1);
                *(BYTE*)(ret+new_len)=0;

                ln -= ln_toread;
                ofs+=ln_toread*2;

                if (xls_debug) {
	                printf("String16SST: %s(%zd)\n",ret,new_len);
                }
            }
            else
            {
                ln_toread = min((size-ofs), ln);

				ret = utf8_decode((buf+ofs), ln_toread, pWB->charset);

                ln  -= ln_toread;
                ofs +=ln_toread;

                if (xls_debug) {
                	printf("String8SST: %s(%u) \n",ret,ln);
                }
            }
        }
        else
        {
         ret = (BYTE *)strdup("");
        }

        if (  (ln_toread > 0)
            ||(!pWB->sst.continued) )
        {
            // Concat string if it's a continue, or add string in table
            if (!pWB->sst.continued)
            {
                pWB->sst.lastid++;
                pWB->sst.string[pWB->sst.lastid-1].str=ret;
            }
            else
            {
                BYTE *tmp;
                tmp=pWB->sst.string[pWB->sst.lastid-1].str;
                tmp=(BYTE *)realloc(tmp,strlen((char *)tmp)+strlen((char *)ret)+1);
                pWB->sst.string[pWB->sst.lastid-1].str=tmp;
                memcpy(tmp+strlen((char *)tmp),ret,strlen((char *)ret)+1);
				free(ret);
            }

			if (xls_debug) {
	            printf("String %4u: %s<end>\n", pWB->sst.lastid-1, pWB->sst.string[pWB->sst.lastid-1].str);
			}
        }

		// Jump list of rich text formatting runs
        if (  (ofs < size)
            &&(rt > 0) )
          {
           int rt_toread = min((size-ofs)/4, rt);
           rt -= rt_toread;
           ofs += rt_toread*4;
          }

		// Jump asian phonetic settings block
        if (  (ofs < size)
            &&(sz > 0) )
          {
           int sz_toread = min((size-ofs), sz);
           sz -= sz_toread;
           ofs += sz_toread;
          }

        pWB->sst.continued=0;
    }

    // Save current character count and count of rich text formatting runs and size of asian phonetic settings block
	if (ln > 0 || rt > 0 || sz > 0) {
		pWB->sst.continued = 1;
		pWB->sst.lastln = ln;
		pWB->sst.lastrt = rt;
		pWB->sst.lastsz = sz;

		if (xls_debug) {
			printf("continued: ln=%u, rt=%u, sz=%u\n", ln, rt, sz);
		}
	}
}

static double NumFromRk(BYTE* rk)
{
    DWORD drk;
    drk=*(DWORD_UA *)rk;
	union 
	{
		double d;
		DWORD dw[2];
	} num;

	// What kind of value is this ?
    if (drk & 0x02) {
    	// Floating point value;
        num.d = (double)(drk >> 2);
    } else {
    	// Integer value
		num.dw[1] = drk & 0xfffffffc;
		num.dw[0] = 0;
    }

    // Is value multiplied by 100 ?
    if (drk & 0x01) {
        num.d /= 100.0;
    }

    return num.d;
}

BYTE* xls_addSheet(xlsWorkBook* pWB, BOUNDSHEET *bs)
{
	BYTE* name;
	DWORD filepos;
	BYTE visible, type;

	filepos = bs->filepos;
	visible = bs->visible;
	type = bs->type;

	// printf("charset=%s uni=%d\n", pWB->charset, unicode);
	// printf("bs name %.*s\n", bs->name[0], bs->name+1);
	name=get_string(bs->name, 0, pWB->is5ver, pWB->charset);
	// printf("name=%s\n", name);

	if(xls_debug) {
		printf ("xls_addSheet[0x%x]\n", type);
		switch (type & 0x0f)
		{
		case 0x00:
			/* worksheet or dialog sheet */
			printf ("85: Worksheet or dialog sheet\n");
			break;
		case 0x01:
			/* Microsoft Excel 4.0 macro sheet */
			printf ("85: Microsoft Excel 4.0 macro sheet\n");
			break;
		case 0x02:
			/* Chart */
			printf ("85: Chart sheet\n");
			break;
		case 0x06:
			/* Visual Basic module */
			printf ("85: Visual Basic sheet\n");
			break;
		default:
			printf ("???\n");
			break;
		}
		printf("visible: %x\n", visible);
		printf("    Pos: %Xh\n",filepos);
		printf("   type: %.4Xh\n",type);
		printf("   name: %s\n", name);
	}

    if (pWB->sheets.count==0)
    {
        pWB->sheets.sheet=(struct st_sheet_data *) malloc(sizeof (struct st_sheet_data));
    }
    else
    {
        pWB->sheets.sheet=(struct st_sheet_data *) realloc(pWB->sheets.sheet,(pWB->sheets.count+1)*sizeof (struct st_sheet_data));
    }
    pWB->sheets.sheet[pWB->sheets.count].name=name;
    pWB->sheets.sheet[pWB->sheets.count].filepos=filepos;
    pWB->sheets.sheet[pWB->sheets.count].visibility=visible;
    pWB->sheets.sheet[pWB->sheets.count].type=type;
    pWB->sheets.count++;

	return name;
}


void xls_addRow(xlsWorkSheet* pWS,ROW* row)
{
    struct st_row_data* tmp;

    //verbose ("xls_addRow");

    tmp=&pWS->rows.row[row->index];
    tmp->height=row->height;
    tmp->fcell=row->fcell;
    tmp->lcell=row->lcell;
    tmp->flags=row->flags;
    tmp->xf=row->xf&0xfff;
    tmp->xfflags=(row->xf >> 8)&0xf0;
    if(xls_debug) xls_showROW(tmp);
}

void xls_makeTable(xlsWorkSheet* pWS)
{
    WORD i,t;
    struct st_row_data* tmp;
    verbose ("xls_makeTable");

    pWS->rows.row=(struct st_row_data *)calloc((pWS->rows.lastrow+1),sizeof(struct st_row_data));

    for (t=0;t<=pWS->rows.lastrow;t++)
    {
        tmp=&pWS->rows.row[t];
        tmp->index=t;
        tmp->fcell=0;
        tmp->lcell=pWS->rows.lastcol;

		tmp->cells.count = pWS->rows.lastcol+1;
        tmp->cells.cell=(struct st_cell_data *)calloc(tmp->cells.count,sizeof(struct st_cell_data));

        for (i=0;i<=pWS->rows.lastcol;i++)
        {
            tmp->cells.cell[i].col=i;
            tmp->cells.cell[i].row=t;
            tmp->cells.cell[i].width=pWS->defcolwidth;
            tmp->cells.cell[i].xf=0;
            tmp->cells.cell[i].str=NULL;
            tmp->cells.cell[i].d=0;
            tmp->cells.cell[i].l=0;
            tmp->cells.cell[i].isHidden=0;
            tmp->cells.cell[i].colspan=0;
            tmp->cells.cell[i].rowspan=0;
            tmp->cells.cell[i].id=0x201;
            tmp->cells.cell[i].str=NULL;
        }
    }
}

struct st_cell_data *xls_addCell(xlsWorkSheet* pWS,BOF* bof,BYTE* buf)
{
    struct st_cell_data*	cell;
    struct st_row_data*		row;
    int						i;

	verbose ("xls_addCell");

    row=&pWS->rows.row[((COL*)buf)->row];
    //cell=&row->cells.cell[((COL*)buf)->col - row->fcell]; DFH - inconsistent
    cell=&row->cells.cell[((COL*)buf)->col];
//if(((COL*)buf)->col != cell->col)
//{
//printf("buf->col=%d cell->col=%d  row->fcell=%d\n", ((COL*)buf)->col , cell->col,  row->fcell);
//}
    cell->id=bof->id;
    cell->xf=((COL*)buf)->xf;

    switch (bof->id)
    {
    case 0x0006:	//FORMULA
		// test for formula, if
        if (((FORMULA*)buf)->res!=0xffff) {
			cell->l=0;
			// if a double, then set double and clear l
			memcpy(&cell->d, &((FORMULA*)buf)->resid, sizeof(double));	// Required for ARM
			cell->str=xls_getfcell(pWS->workbook,cell);
		} else {
			cell->l = 0xFFFF;
			switch(((FORMULA*)buf)->resid) {
			case 0:		// String
				return cell;	// cell is half complete, get the STRING next record
			case 1:		// Boolean
				memcpy(&cell->d, &((FORMULA*)buf)->resdata[2], sizeof(double)); // Required for ARM
				sprintf((char *)(cell->str = malloc(5)), "bool");
				break;
			case 2:		// error
				memcpy(&cell->d, &((FORMULA*)buf)->resdata[2], sizeof(double)); // Required for ARM
				sprintf((char *)(cell->str = malloc(6)), "error");
				break;
			case 3:		// empty string
				cell->str = calloc(1,1);
				break;
			}
		}
        break;
    case 0x00BD:	//MULRK

        for (i = 0; i <= *(WORD_UA *)(buf + (bof->size - 2)) - ((COL *)buf)->col &&
	       			i <= row->lcell - row->fcell - ((COL *)buf)->col; i++)
        {
            cell=&row->cells.cell[((COL*)buf)->col + i];
            //cell=&row->cells.cell[((COL*)buf)->col - row->fcell + i];  DFH - inconsistent
            //				col=row->cols[i];
            cell->id=0x027E; // DFH now RK, use to be bof->id;
            cell->xf=*((WORD_UA *)(buf+(4+i*6)));
            cell->d=NumFromRk((BYTE *)(buf+(4+i*6+2)));
            cell->str=xls_getfcell(pWS->workbook,cell);
        }
        break;
    case 0x00BE:	//MULBLANK
        for (i = 0; i <= *(WORD_UA *)(buf + (bof->size - 2)) - ((COL *)buf)->col &&
	       			i <= row->lcell - row->fcell - ((COL *)buf)->col; i++)
        {
            cell=&row->cells.cell[((COL*)buf)->col + i];
            //cell=&row->cells.cell[((COL*)buf)->col-row->fcell+i];
            //				col=row->cols[i];
            cell->id=0x0201; // DFH blank, use to be bof->id;
            cell->xf=*((WORD_UA *)(buf+(4+i*2)));
            cell->str=xls_getfcell(pWS->workbook,cell);
        }
        break;
    case 0x00FD:	//LABELSST
    case 0x0204:	//LABEL
		cell->l=*(WORD_UA *)&((LABEL*)buf)->value;	// LABEL and LABELSST same struct
        cell->str=xls_getfcell(pWS->workbook,cell);
		sscanf((char *)cell->str, "%d", &cell->l);
		sscanf((char *)cell->str, "%lf", &cell->d);
		break;
    case 0x027E:	//RK
        cell->d=NumFromRk(((RK*)buf)->value);
        cell->str=xls_getfcell(pWS->workbook,cell);
        break;
    case 0x0201:	//BLANK
        break;
    case 0x0203:	//NUMBER
		memcpy(&cell->d, &((BR_NUMBER*)buf)->value, sizeof(double)); // Required for ARM
        cell->str=xls_getfcell(pWS->workbook,cell);
        break;
    default:
        cell->str=xls_getfcell(pWS->workbook,cell);
        break;
    }
    if (xls_debug) xls_showCell(cell);

	return cell;
}

BYTE *xls_addFont(xlsWorkBook* pWB, FONT* font)
{
    struct st_font_data* tmp;

    verbose("xls_addFont");
    if (pWB->fonts.count==0)
    {
        pWB->fonts.font=(struct st_font_data *) malloc(sizeof(struct st_font_data));
    } else {
        pWB->fonts.font=(struct st_font_data *) realloc(pWB->fonts.font,(pWB->fonts.count+1)*sizeof(struct st_font_data));
    }

    tmp=&pWB->fonts.font[pWB->fonts.count];

    tmp->name=get_string((BYTE*)&font->name, 0, pWB->is5ver, pWB->charset);

    tmp->height=font->height;
    tmp->flag=font->flag;
    tmp->color=font->color;
    tmp->bold=font->bold;
    tmp->escapement=font->escapement;
    tmp->underline=font->underline;
    tmp->family=font->family;
    tmp->charset=font->charset;

    //	xls_showFont(tmp);
    pWB->fonts.count++;

	return tmp->name;
}

void xls_addFormat(xlsWorkBook* pWB, FORMAT* format)
{
    struct st_format_data* tmp;

    verbose("xls_addFormat");
    if (pWB->formats.count==0)
    {
        pWB->formats.format=(struct st_format_data *) malloc(sizeof(struct st_format_data));
    } else {
        pWB->formats.format=(struct st_format_data *) realloc(pWB->formats.format,(pWB->formats.count+1)*sizeof(struct st_format_data));
    }

    tmp=&pWB->formats.format[pWB->formats.count];
    tmp->index=format->index;
    tmp->value=get_string(format->value, !pWB->is5ver, pWB->is5ver, pWB->charset);
    if(xls_debug) xls_showFormat(tmp);
    pWB->formats.count++;
}

void xls_addXF8(xlsWorkBook* pWB,XF8* xf)
{
    struct st_xf_data* tmp;

    verbose("xls_addXF");
    if (pWB->xfs.count==0)
    {
        pWB->xfs.xf=(struct st_xf_data *) malloc(sizeof(struct st_xf_data));
    }
    else
    {
        pWB->xfs.xf=(struct st_xf_data *) realloc(pWB->xfs.xf,(pWB->xfs.count+1)*sizeof(struct st_xf_data));
    }

    tmp=&pWB->xfs.xf[pWB->xfs.count];

    tmp->font=xf->font;
    tmp->format=xf->format;
    tmp->type=xf->type;
    tmp->align=xf->align;
    tmp->rotation=xf->rotation;
    tmp->ident=xf->ident;
    tmp->usedattr=xf->usedattr;
    tmp->linestyle=xf->linestyle;
    tmp->linecolor=xf->linecolor;
    tmp->groundcolor=xf->groundcolor;

    //	xls_showXF(tmp);
    pWB->xfs.count++;
}
void xls_addXF5(xlsWorkBook* pWB,XF5* xf)
{
    struct st_xf_data* tmp;

    verbose("xls_addXF");
    if (pWB->xfs.count==0)
    {
        pWB->xfs.xf=(struct st_xf_data *) malloc(sizeof(struct st_xf_data));
    }
    else
    {
        pWB->xfs.xf=(struct st_xf_data *) realloc(pWB->xfs.xf,(pWB->xfs.count+1)*sizeof(struct st_xf_data));
    }

    tmp=&pWB->xfs.xf[pWB->xfs.count];

    tmp->font=xf->font;
    tmp->format=xf->format;
    tmp->type=xf->type;
    tmp->align=xf->align;
/*
    tmp->rotation=xf->rotation;
    tmp->ident=xf->ident;
    tmp->usedattr=xf->usedattr;
    tmp->linestyle=xf->linestyle;
    tmp->linecolor=xf->linecolor;
    tmp->groundcolor=xf->groundcolor;
*/

    //	xls_showXF(tmp);
    pWB->xfs.count++;
}

void xls_addColinfo(xlsWorkSheet* pWS,COLINFO* colinfo)
{
    struct st_colinfo_data* tmp;

    verbose("xls_addColinfo");
    if (pWS->colinfo.count==0)
    {
        pWS->colinfo.col=(struct st_colinfo_data *) malloc(sizeof(struct st_colinfo_data));
    }
    else
    {
        pWS->colinfo.col=(struct st_colinfo_data *) realloc(pWS->colinfo.col,(pWS->colinfo.count+1)*sizeof(struct st_colinfo_data));
    }

    tmp=&pWS->colinfo.col[pWS->colinfo.count];
    tmp->first=colinfo->first;
    tmp->last=colinfo->last;
    tmp->width=colinfo->width;
    tmp->xf=colinfo->xf;
    tmp->flags=colinfo->flags;

    if(xls_debug) xls_showColinfo(tmp);
    pWS->colinfo.count++;
}

void xls_mergedCells(xlsWorkSheet* pWS,BOF* bof,BYTE* buf)
{
    int count=*((WORD_UA *)buf);
    int i,c,r;
    struct MERGEDCELLS* span;
    verbose("Merged Cells");
    for (i=0;i<count;i++)
    {
        span=(struct MERGEDCELLS*)(buf+(2+i*sizeof(struct MERGEDCELLS)));
        //		printf("Merged Cells: [%i,%i] [%i,%i] \n",span->colf,span->rowf,span->coll,span->rowl);
        for (r=span->rowf;r<=span->rowl;r++)
            for (c=span->colf;c<=span->coll;c++)
                pWS->rows.row[r].cells.cell[c].isHidden=1;
        pWS->rows.row[span->rowf].cells.cell[span->colf].colspan=(span->coll-span->colf+1);
        pWS->rows.row[span->rowf].cells.cell[span->colf].rowspan=(span->rowl-span->rowf+1);
        pWS->rows.row[span->rowf].cells.cell[span->colf].isHidden=0;
    }
}

void xls_parseWorkBook(xlsWorkBook* pWB)
{
    BOF bof1;
    BOF bof2;
    BYTE* buf;
	BYTE once;

	// this to prevent compiler warnings
	once=0;
	bof2.size = 0;
	bof2.id = 0;
    verbose ("xls_parseWorkBook");
    do
    {
		if(xls_debug > 10) {
			printf("READ WORKBOOK filePos=%ld\n",  (long)pWB->filepos);
			printf("  OLE: start=%d pos=%zd size=%zd fatPos=%zu\n", pWB->olestr->start, pWB->olestr->pos, pWB->olestr->size, pWB->olestr->fatpos); 
		}

        ole2_read(&bof1, 1, 4, pWB->olestr);
 		if(xls_debug) xls_showBOF(&bof1);

        buf=(BYTE *)malloc(bof1.size);
        ole2_read(buf, 1, bof1.size, pWB->olestr);

        switch (bof1.id) {
        case 0x000A:	// EOF
            //verbose("EOF");
            break;
        case 0x0809:	// BIFF5-8
			{
				BIFF *b = (BIFF*)buf;
				if (b->ver==0x600)
					pWB->is5ver=0;
				else
					pWB->is5ver=1;
				pWB->type=b->type;

				if(xls_debug) {
					printf("version: %s\n", pWB->is5ver ? "BIFF5" : "BIFF8" );
					printf("   type: %.2X\n", pWB->type);
				}
			}
            break;

        case 0x0042:	// CODEPAGE
            pWB->codepage=*(WORD_UA *)buf;
			if(xls_debug) printf("codepage=%x\n", pWB->codepage);
            break;

        case 0x003c:	// CONTINUE
			if(once) {
				if (bof2.id==0xfc)
					xls_appendSST(pWB,buf,bof1.size);
				bof1=bof2;
			}
            break;

		case 0x003D:	// WINDOW1
			{
				WIND1 *w = (WIND1*)buf;
				if(xls_debug) {
					printf("WINDOW1: ");
					printf("xWn    : %d\n", w->xWn/20);
					printf("yWn    : %d\n", w->yWn/20);
					printf("dxWn   : %d\n", w->dxWn/20);
					printf("dyWn   : %d\n", w->dyWn/20);
					printf("grbit  : %d\n", w->grbit);
					printf("itabCur: %d\n", w->itabCur);
					printf("itabFi : %d\n", w->itabFirst);
					printf("ctabSel: %d\n", w->ctabSel);
					printf("wTabRat: %d\n", w->wTabRatio);
				}
			}
			break;

        case 0x00fc:	// SST
			//if(xls_debug) dumpbuf((BYTE *)"/tmp/SST",bof1.size,buf);
            xls_addSST(pWB,(SST*)buf,bof1.size);
            break;

        case 0x00ff:	// EXTSST
            //if(xls_debug > 1000) dumpbuf((BYTE *)"/tmp/EXTSST",bof1.size,buf);
            break;

        case 0x0085:	// BOUNDSHEET
			{
				BOUNDSHEET *bs = (BOUNDSHEET *)buf;
				//char *s;
				// different for BIFF5 and BIFF8
				/*s = */ xls_addSheet(pWB,bs);
			}
            break;

        case 0x00e0:  	// XF
			if(pWB->is5ver) {
				XF5 *xf;
				xf = (XF5 *)buf;

				xls_addXF5(pWB,xf);
				if(xls_debug) {
					printf("   font: %d\n", xf->font);
					printf(" format: %d\n", xf->format);
					printf("   type: %.4x\n", xf->type);
					printf("  align: %.4x\n", xf->align);
					printf("rotatio: %.4x\n", xf->color);
					printf("  ident: %.4x\n", xf->fill);
					printf("usedatt: %.4x\n", xf->border);
					printf("linesty: %.4x\n", xf->linestyle);
				}
			} else {
				XF8 *xf;
				xf = (XF8 *)buf;

				xls_addXF8(pWB,xf);
				if(xls_debug) {
					xls_showXF(xf);
				}
			}
            break;

        case 0x0031:	// FONT
			{
				BYTE *s;
				FONT *f = (FONT*)buf;
				s = xls_addFont(pWB,f);
				if(xls_debug) {
					printf(" height: %d\n", f->height);
					printf("   flag: 0x%x\n", f->flag);
					printf("  color: 0x%x\n", f->color);
					printf(" weight: %d\n", f->bold);
					printf("escapem: 0x%x\n", f->escapement);
					printf("underln: 0x%x\n", f->underline);
					printf(" family: 0x%x\n", f->family);
					printf("charset: 0x%x\n", f->charset);
					if(s) printf("   name: %s\n", s);
				}
			}
			break;

        case 0x041E:	//FORMAT
            xls_addFormat(pWB,(FORMAT*)buf);
            break;

		case 0x0293:	// STYLE
			if(xls_debug) {
				struct { unsigned short idx; unsigned char ident; unsigned char lvl; } *styl;
				styl = (void *)buf;

				printf("    idx: 0x%x\n", styl->idx & 0x07FF);
				if(styl->idx & 0x8000) {
					printf("  ident: 0x%x\n", styl->ident);
					printf("  level: 0x%x\n", styl->lvl);
				} else {
					BYTE *s = get_string(&buf[2], 1, pWB->is5ver, pWB->charset);
					printf("  name=%s\n", s);
				}
			}
			break;

		case 0x0092:	// PALETTE
			if(xls_debug > 10) {
				unsigned char *p = buf + 2;
				int idx, len;

				len = *(WORD_UA *)buf;
				for(idx=0; idx<len; ++idx) {
					printf("   Index=0x%2.2x %2.2x%2.2x%2.2x\n", idx+8, p[0], p[1], p[2] );
					p += 4;
				}
			}
			break;

		case 0x0022: // 1904
			if(xls_debug) {
				printf("   mode: 0x%x\n", *(WORD_UA *)buf);
			}
			break;

        default:
			if(xls_debug) printf("Not Processed in parseWoorkBook():  BOF=0x%4.4X\n", bof1.id);
            break;
        }
		free(buf);

        bof2=bof1;
		once=1;
    }
    while ((!pWB->olestr->eof)&&(bof1.id!=0x0A));
}


void xls_preparseWorkSheet(xlsWorkSheet* pWS)
{
    BOF tmp;
    BYTE* buf;

    verbose ("xls_preparseWorkSheet");

    ole2_seek(pWS->workbook->olestr,pWS->filepos);
    do
    {
        ole2_read(&tmp, 1,4,pWS->workbook->olestr);
        buf=(BYTE *)malloc(tmp.size);
        ole2_read(buf, 1,tmp.size,pWS->workbook->olestr);
        //	xls_showBOF(&tmp);
        switch (tmp.id)
        {
        case 0x55:     //DEFCOLWIDTH
            pWS->defcolwidth=*(WORD_UA *)buf*256;
            break;
        case 0x7D:     //COLINFO
            xls_addColinfo(pWS,(COLINFO*)buf);
            break;
        case 0x208:		//ROW
            if (pWS->rows.lastcol<((ROW*)buf)->lcell)
                pWS->rows.lastcol=((ROW*)buf)->lcell;
            if (pWS->rows.lastrow<((ROW*)buf)->index)
                pWS->rows.lastrow=((ROW*)buf)->index;
            break;
        }
        free(buf);
    }
    while ((!pWS->workbook->olestr->eof)&&(tmp.id!=0x0A));
}

void xls_formatColumn(xlsWorkSheet* pWS)
{
    DWORD i,t,ii;
    DWORD fcol,lcol;

    for (i=0;i<pWS->colinfo.count;i++)
    {
        if (pWS->colinfo.col[i].first<=pWS->rows.lastcol)
            fcol=pWS->colinfo.col[i].first;
        else
            fcol=pWS->rows.lastcol;

        if (pWS->colinfo.col[i].last<=pWS->rows.lastcol)
            lcol=pWS->colinfo.col[i].last;
        else
            lcol=pWS->rows.lastcol;

        for (t=fcol;t<=lcol;t++) {
            for (ii=0;ii<=pWS->rows.lastrow;ii++)
            {
                if (pWS->colinfo.col[i].flags&1)
                    pWS->rows.row[ii].cells.cell[t].isHidden=1;
                pWS->rows.row[ii].cells.cell[t].width=pWS->colinfo.col[i].width;
            }
        }
    }
}

void xls_parseWorkSheet(xlsWorkSheet* pWS)
{
    BOF tmp;
    BYTE* buf;
	long offset = pWS->filepos;

	struct st_cell_data *cell;
	xlsWorkBook *pWB = pWS->workbook;

    verbose ("xls_parseWorkSheet");

    xls_preparseWorkSheet(pWS);
	// printf("size=%d fatpos=%d)\n", pWS->workbook->olestr->size, pWS->workbook->olestr->fatpos);

    xls_makeTable(pWS);
    xls_formatColumn(pWS);

	cell = (void *)0;
    ole2_seek(pWS->workbook->olestr,pWS->filepos);
    do
    {
		long lastPos = offset;

		if(xls_debug > 10) {
			printf("LASTPOS=%ld pos=%zd filePos=%d filePos=%d\n", lastPos, pWB->olestr->pos, pWS->filepos, pWB->filepos);
		}
        ole2_read(&tmp, 1,4,pWS->workbook->olestr);
        buf=(BYTE *)malloc(tmp.size);
        ole2_read(buf, 1,tmp.size,pWS->workbook->olestr);
		offset += 4 + tmp.size;

		// xls_showBOF(&tmp);
        switch (tmp.id)
        {
        case 0x000A:		//EOF
            break;
        case 0x00E5:		//MERGEDCELLS
            xls_mergedCells(pWS,&tmp,buf);
            break;
        case 0x0208:		//ROW
			if(xls_debug > 10) printf("ROW: %x at pos=%ld\n", tmp.id, lastPos);
            xls_addRow(pWS,(ROW*)buf);
            break;
		case 0x0055:
			if(xls_debug > 10) printf("DEFAULT COL WIDTH: %d\n", *(WORD_UA *)buf);
			break;
		case 0x0225:
			if(xls_debug > 10) printf("DEFAULT ROW Height: 0x%x %d\n", ((WORD_UA *)buf)[0], ((WORD_UA *)buf)[1]);
			break;
		case 0x00D7:
			if(xls_debug > 10) {
				printf("DBCELL: size %d\n", tmp.size);
				DWORD *foo = (DWORD_UA *)buf;
				printf("DBCELL OFFSET=%4.4u -> ROW %ld\n", foo[0], lastPos-foo[0]);
				++foo;
				WORD *goo = (WORD *)foo;
				for(int i=0; i<5; ++i) printf("goo[%d]=%4.4x %u\n", i, goo[i], goo[i]);
			}
			break;
        case 0x020B:		//INDEX
			if(xls_debug > 10) {
				printf("INDEX: size %d\n", tmp.size);
				DWORD *foo = (DWORD_UA *)buf;
				for(int i=0; i<5; ++i) printf("FOO[%d]=%4.4x %u\n", i, foo[i], foo[i]);
			}
#if 0
0	4 4	4 8	4
12	4 16	4∙nm
Not used Index to first used row (rf, 0-based) Index to first row of unused tail of sheet (rl, last used row + 1, 0-based)
Absolute stream position of the DEFCOLWIDTH record (➜5.32) of the current sheet. If this record does not exist, the offset points to the record at the position where the DEFCOLWIDTH record would occur.
Array of nm absolute stream positions to the DBCELL record (➜5.29) of each Row Block
#endif
            break;
        case 0x00BD:		//MULRK
        case 0x00BE:		//MULBLANK
        case 0x0203:		//NUMBER
        case 0x027e:		//RK
        case 0x00FD:		//LABELSST
        case 0x0201:		//BLANK
        case 0x0204:		//LABEL
        case 0x0006:		//FORMULA
            cell = xls_addCell(pWS,&tmp,buf);
            break;
		case 0x0207:		//STRING, only follows a formula
			if(cell && cell->id == 0x06) { // formula
				cell->str = get_string(buf, !pWB->is5ver, pWB->is5ver, pWB->charset);
				if (xls_debug) xls_showCell(cell);
			}
			break;
#if 0 // debugging
		case 0x01B8:	// HYPERREF
			if(xls_debug) {
				printf("HYPERREF: ");
				unsigned char xx, *foo = (void *)buf;

				for(xx=0; xx<tmp.size; ++xx, ++foo) {
					printf("%2.2x ", *foo);
				}
				printf("\n");
			}
			break;
		case 0x023E:	// WINDOW2
			if(xls_debug) {
				printf("WINDOW2: ");
				unsigned short xx, *foo = (void *)buf;

				for(xx=0; xx<7; ++xx, ++foo) {
					printf("0x%4.4x ", *foo);
				}
				printf("\n");
			}
			break;
#endif
        default:
			if(xls_debug) {
				printf("UNKNOWN: %x at pos=%lu\n", tmp.id, lastPos);
			}
            break;
        }
        free(buf);
    }
    while ((!pWS->workbook->olestr->eof)&&(tmp.id!=0x0A));  // 0x0A == EOF
}

xlsWorkSheet * xls_getWorkSheet(xlsWorkBook* pWB,int num)
{
    xlsWorkSheet * pWS;
    verbose ("xls_getWorkSheet");
    pWS=(xlsWorkSheet *)calloc(1, sizeof(xlsWorkSheet));
    pWS->filepos=pWB->sheets.sheet[num].filepos;
    pWS->workbook=pWB;
    pWS->rows.lastcol=0;
    pWS->rows.lastrow=0;
    pWS->colinfo.count=0;
    return(pWS);
}

xlsWorkBook* xls_open(const char *file,const char* charset)
{
    xlsWorkBook* pWB;
    OLE2*		ole;

    pWB=(xlsWorkBook*)calloc(1, sizeof(xlsWorkBook));
    verbose ("xls_open");

    // open excel file
    if (!(ole=ole2_open((BYTE *)file)))
    {
        if(xls_debug) printf("File \"%s\" not found\n",file);
		free(pWB);
        return(NULL);
    }

    if ((pWB->olestr=ole2_fopen(ole, (BYTE *)"\005SummaryInformation")))
    {
        pWB->summary = calloc(1,4096);
		ole2_read(pWB->summary, 4096, 1, pWB->olestr);
		ole2_fclose(pWB->olestr);
	}

    if ((pWB->olestr=ole2_fopen(ole, (BYTE *)"\005DocumentSummaryInformation")))
    {
        pWB->docSummary = calloc(1,4096);
		ole2_read(pWB->docSummary, 4096, 1, pWB->olestr);
		ole2_fclose(pWB->olestr);
	}

    // open Workbook
    if (!(pWB->olestr=ole2_fopen(ole,(BYTE *)"Workbook")) && !(pWB->olestr=ole2_fopen(ole,(BYTE *)"Book")))
    {
        if(xls_debug) printf("Workbook not found\n");
        ole2_close(ole);
		free(pWB);
        return(NULL);
    }


    pWB->sheets.count=0;
    pWB->xfs.count=0;
    pWB->fonts.count=0;
    pWB->charset = (char *)malloc(strlen(charset) * sizeof(char)+1);
    strcpy(pWB->charset, charset);
    xls_parseWorkBook(pWB);

    return(pWB);
}

xlsRow *xls_row(xlsWorkSheet* pWS, WORD cellRow)
{
    struct st_row_data *row;

    if(cellRow > pWS->rows.lastrow) return NULL;
    row = &pWS->rows.row[cellRow];

    return row;
}

xlsCell	*xls_cell(xlsWorkSheet* pWS, WORD cellRow, WORD cellCol)
{
    struct st_row_data	*row;

    if(cellRow > pWS->rows.lastrow) return NULL;
    row = &pWS->rows.row[cellRow];
    if(cellCol >= row->lcell) return NULL;

    return &row->cells.cell[cellCol];
}

void xls_close_WB(xlsWorkBook* pWB)
{
	OLE2*		ole;

	verbose ("xls_close");

	if(!pWB) return;

    // OLE first
	ole=pWB->olestr->ole;
	
	ole2_fclose(pWB->olestr);

	ole2_close(ole);

    // WorkBook
    free(pWB->charset);

    // Sheets
    {
        DWORD i;
        for(i=0; i<pWB->sheets.count; ++i) {
            free(pWB->sheets.sheet[i].name);
        }
        free(pWB->sheets.sheet);
    }

    // SST
    {
        DWORD i;
        for(i=0; i<pWB->sst.count; ++i) {
            free(pWB->sst.string[i].str);
        }
        free(pWB->sst.string);
    }

    // xfs
    {
        free(pWB->xfs.xf);
    }

    // fonts
    {
        DWORD i;
        for(i=0; i<pWB->fonts.count; ++i) {
            free(pWB->fonts.font[i].name);
        }
        free(pWB->fonts.font);
    }

    // formats
    {
        DWORD i;
        for(i=0; i<pWB->formats.count; ++i) {
            free(pWB->formats.format[i].value);
        }
        free(pWB->formats.format);
    }

    // buffers
	if(pWB->summary)  free(pWB->summary);
	if(pWB->docSummary) free(pWB->docSummary);

	// TODO - free other dynamically allocated objects like string table??
	free(pWB);
}

void xls_close_WS(xlsWorkSheet* pWS)
{
	if(!pWS) return;

    // ROWS
    {
        DWORD i, j;
        for(j=0; j<=pWS->rows.lastrow; ++j) {
            struct st_row_data *row = &pWS->rows.row[j];
            for(i=0; i<row->cells.count; ++i) {
                free(row->cells.cell[i].str);
            }
            free(row->cells.cell);
        }
        free(pWS->rows.row);

    }

    // COLINFO
    {
        free(pWS->colinfo.col);
    }
    free(pWS);
}

const char* xls_getVersion(void)
{
    return PACKAGE_VERSION;
}

//
// http://poi.apache.org/hpsf/internals.html
// or google "DocumentSummaryInformation and UserDefined Property Sets" and look for MSDN hits
//

xlsSummaryInfo *xls_summaryInfo(xlsWorkBook* pWB)
{
	xlsSummaryInfo	*pSI;

	pSI = (xlsSummaryInfo *)calloc(1, sizeof(xlsSummaryInfo));
	xls_dumpSummary(pWB->summary, 1, pSI);
	xls_dumpSummary(pWB->docSummary, 0, pSI);

	return pSI;
}

void xls_close_summaryInfo(xlsSummaryInfo *pSI)
{
	if(!pSI) return;

	if(pSI->title)		free(pSI->title);
	if(pSI->subject)	free(pSI->subject);
	if(pSI->author)		free(pSI->author);
	if(pSI->keywords)	free(pSI->keywords);
	if(pSI->comment)	free(pSI->comment);
	if(pSI->lastAuthor)	free(pSI->lastAuthor);
	if(pSI->appName)	free(pSI->appName);
	if(pSI->category)	free(pSI->category);
	if(pSI->manager)	free(pSI->manager);
	if(pSI->company)	free(pSI->company);

	free(pSI);
}

void xls_dumpSummary(char *buf,int isSummary,xlsSummaryInfo *pSI) {
	header			*head;
	sectionList		*secList;
	propertyList	*plist;
	sectionHeader	*secHead;
	property		*prop;
	uint32_t i, j;

	if(!buf) return;	// perhaps the document was missing??

	head = (header *)buf;
	//printf("header: \n");
	//printf("  sig=%x\n", head->sig);
	//printf("  os=%x\n", head->os >> 16);
	//printf("  class=%8.8x%8.8x%8.8x%8.8x\n", head->format[0], head->format[1], head->format[2], head->format[3]);
	//printf("  count=%x\n", head->count);

	for(i=0; i<head->count; ++i) {
		secList = &head->secList[i];
		//printf("Section %d:\n", i);
		//printf("  class=%8.8x%8.8x%8.8x%8.8x\n", secList->format[0], secList->format[1], secList->format[2], secList->format[3]);
		//printf("  offset=%d (now at %ld\n", secList->offset, (char *)secList - (char *)buf + sizeof(sectionList));


		secHead = (sectionHeader *)((char *)head + secList->offset);
		//printf("  len=%d\n", secHead->length);
		//printf("  properties=%d\n", secHead->numProperties);
		for(j=0; j<secHead->numProperties; ++j) {
			BYTE **s;

			plist = &secHead->properties[j];
			//printf("      ---------\n");
			//printf("      propID=%d offset=%d\n", plist->propertyID, plist->sectionOffset);
			prop = (property *)((char *)secHead + plist->sectionOffset);
			//printf("      propType=%d\n", prop->propertyID);

			switch(prop->propertyID) {
			case 2:
				//printf("      shortVal=%x\n", *(uint16_t *)prop->data);
				break;
			case 3:
				//printf("      wordVal=%x\n", *(uint32_t *)prop->data);
				break;
			case 30:
				//printf("      longVal=%llx\n", *(uint64_t *)prop->data);
				//printf("      s[%u]=%s\n", *(uint32_t  *)prop->data, (char *)prop->data + 4);
				if(isSummary) {
					switch(plist->propertyID) {
					case 2:		s = &pSI->title;		break;
					case 3:		s = &pSI->subject;		break;
					case 4:		s = &pSI->author;		break;
					case 5:		s = &pSI->keywords;		break;
					case 6:		s = &pSI->comment;		break;
					case 8:		s = &pSI->lastAuthor;	break;
					case 18:	s = &pSI->appName;		break;
					default:	s = NULL;				break;
					}
				} else {
					switch(plist->propertyID) {
					case 2:		s = &pSI->category;		break;
					case 14:	s = &pSI->manager;		break;
					case 15:	s = &pSI->company;		break;
					default:	s = NULL;				break;
					}
				}
				if(s) *s = (BYTE *)strdup((char *)prop->data + 4);
				break;
			case 64:
				//printf("      longVal=%llx\n", *(uint64_t *)prop->data);
				break;
			case 65:
#if 0
				{
				uint32_t k;
				for(k=0; k<*(uint32_t  *)prop->data; ++k) {
				unsigned char *t = (unsigned char *)prop->data + 4 + k;
				printf(" %2.2x(%c)", *t, *t);
				}
				printf("\n");
				}
#endif
				break;
			default:
				//printf("      UNKNOWN!\n");
				break;
			}
		}
	}
}
