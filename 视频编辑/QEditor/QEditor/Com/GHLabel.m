//
//  GHLabel.m
//  LLabel
//
//  Created by 李国怀 on 2016/9/7.
//  Copyright © 2016年 李国怀. All rights reserved.
//

#import "GHLabel.h"

typedef NS_ENUM(NSInteger, TapHandleType){
    TapHandleNone,
    TapHandlelink,
    TapHandleUser
};

@interface GHLabel()
@property (nonatomic, strong) NSTextStorage *textStorage;//是NSMutableAttributedString的子类，由于可以灵活地往文字添加或修改属性，所以非常适用于保存并修改文字属性。
@property (nonatomic, strong) NSLayoutManager *layoutManager;//管理NSTextStorage其中的文字内容的排版布局。
@property (nonatomic, strong) NSTextContainer *textContainer;//定义了一个矩形区域用于存放已经进行了排版并设置好属性的文字
@property (nonatomic, strong) NSMutableArray *userRanges;
@property (nonatomic, strong) NSMutableArray *linkRanges;
@property (nonatomic, strong) NSValue *selectedRangeValue;//记录选中的Range
@property (nonatomic, assign) BOOL  isSelected;//记录是否点击
@property (nonatomic, assign) TapHandleType  tapHandleType;//点击类型
@end


@implementation GHLabel
//在设置字体，文字，
- (void)setFont:(UIFont *)font{
    [super setFont:font];
    [self prepareText];
}
- (void)setText:(NSString *)text{
    [super setText:text];
    [self prepareText];
}
- (void)setAttributedText:(NSAttributedString *)attributedText{
    [super setAttributedText:attributedText];
    [self prepareText];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepareTextSystem];
    }
    return self;
}
//设置容器大小为label的尺寸
- (void)layoutSubviews{
    self.textContainer.size = self.frame.size;
}
//重写drawTextInRect方法绘制背景，文字
- (void)drawTextInRect:(CGRect)rect{
    
    if (_selectedRangeValue) {
        UIColor *selectColor = _isSelected ? [UIColor colorWithWhite:0.6 alpha:0.2] : [UIColor clearColor];
        //设置文字背景颜色
        [self.textStorage addAttribute:NSBackgroundColorAttributeName value:selectColor range:self.selectedRangeValue.rangeValue];
        //绘制背景
        [self.layoutManager drawBackgroundForGlyphRange:self.selectedRangeValue.rangeValue atPoint:CGPointMake(0, 0)];
    }
    NSRange range = NSMakeRange(0, self.textStorage.length);
    //绘制文字
    [self.layoutManager drawGlyphsForGlyphRange:range atPoint:CGPointZero];
}

- (void)prepareTextSystem {

//    [self prepareText];

    //将布局添加到storage
    [self.textStorage addLayoutManager:self.layoutManager];
    //将容器添加到布局中
    [self.layoutManager addTextContainer:self.textContainer];
    self.userInteractionEnabled = YES;
    //设置左右边距
    self.textContainer.lineFragmentPadding = 10;
}

- (void)prepareText{
    NSAttributedString *attrString;
    if (self.attributedText) {
        attrString = self.attributedText;
    }else if (self.text){
        attrString = [[NSAttributedString alloc]initWithString:self.text];
        
    }else {
        attrString = [[NSAttributedString alloc]initWithString:@""];
    }
    self.selectedRangeValue = nil;
    //设置折行
    NSMutableAttributedString *attrMString = [self addLineBreak:attrString];
    [self.textStorage setAttributedString:attrMString];
    
    //正则匹配
     self.linkRanges = [self getRanges:@"http(s)?://([\\w-]+\\.)+[\\w-]+(/[\\w- ./?%&=]*)?"];
    UIColor *attrColor = _attrStrColor == nil ? [UIColor blueColor] : _attrStrColor;
    for (NSValue *rangeValue in self.linkRanges) {
        [self.textStorage addAttribute:NSForegroundColorAttributeName value:attrColor range:rangeValue.rangeValue];
    }
    
    self.userRanges = [self getRanges:@"@\\w{1,}?:"];
    for (NSValue *rangeValue in self.userRanges) {
        [self.textStorage addAttribute:NSForegroundColorAttributeName value:attrColor range:rangeValue.rangeValue];
    }
    
    [self setNeedsDisplay];
}

- (NSMutableArray<NSValue *> *)getRanges:(NSString*)pattern{
    
    NSRegularExpression *regular = [[NSRegularExpression alloc]initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *results = [regular matchesInString:self.textStorage.string options:NSMatchingReportCompletion range:NSMakeRange(0, self.textStorage.string.length)];
    NSMutableArray *ranges = [NSMutableArray array];
    for (NSTextCheckingResult *result in results) {
        
        NSValue *value = [NSValue valueWithRange:result.range];
        [ranges addObject:value];
    }
    return ranges;
}
#pragma mark - 点击交互
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _isSelected = YES;
    
    CGPoint selectPoint = [[touches anyObject] locationInView:self];
    self.selectedRangeValue = [self getSelectRange:selectPoint];
    if (!_selectedRangeValue) {
        [super touchesBegan:touches withEvent:event];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!_selectedRangeValue) {
        [super touchesEnded:touches withEvent:event];
        return;
    }
    _isSelected = NO;
    [self setNeedsDisplay];
    NSString *contentText = [self.textStorage.string substringWithRange:_selectedRangeValue.rangeValue];
    switch (_tapHandleType) {
        case TapHandleUser:
            if (_userTaphandle) {
            _userTaphandle(self,contentText,_selectedRangeValue.rangeValue);
            }
            break;
            case TapHandlelink:
            if (_linkTapHandle) {
             _linkTapHandle(self,contentText,_selectedRangeValue.rangeValue);
            }
            break;
        default:
            break;
    }
    
}

-(NSValue*)getSelectRange:(CGPoint)selectPoint{
    if (self.textStorage.length == 0) {
        return nil;
    }
    //得到点击的是label内的第几个字符索引
    NSInteger index = [self.layoutManager glyphIndexForPoint:selectPoint inTextContainer:self.textContainer];
    for (NSValue *rangeValue in self.linkRanges) {
        NSRange range = rangeValue.rangeValue;
        if (index >= range.location && index <range.location + range.length) {
            _tapHandleType = TapHandlelink;
            [self setNeedsDisplay];
            return rangeValue;
        }
    }
    for (NSValue *rangeValue in self.userRanges) {
        NSRange range = rangeValue.rangeValue;
        if (index >= range.location && index <range.location + range.length) {
            _tapHandleType = TapHandleUser;
            [self setNeedsDisplay];
            return rangeValue;
        }
    }
    _tapHandleType = TapHandleNone;
    return nil;
}

- (NSMutableAttributedString*)addLineBreak:(NSAttributedString *) attrString{
    NSMutableAttributedString *attrMString = [[NSMutableAttributedString alloc]initWithAttributedString:attrString];
    if (attrMString.length == 0) {
        return attrMString;
    }
    NSRange range = NSMakeRange(0, 0);
    NSMutableDictionary *dict = (NSMutableDictionary*)[attrMString attributesAtIndex:0 effectiveRange:&range];
    //里面有NSShadow,NSParagraphStyle,NSFont,NSColor四个值
    NSLog(@"%@",dict);
    
    NSMutableParagraphStyle *paragraphStyle = [dict[NSParagraphStyleAttributeName] mutableCopy] ;
    //设置paragraphStyle，如果不为空，则设置折行模式,为空则自己生成并add
    if (paragraphStyle) {
        paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    }else {
        paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    }
    [attrMString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    return attrMString;
}

#pragma mark - Get
- (NSTextStorage*)textStorage{
    if (!_textStorage) {
        _textStorage = [[NSTextStorage alloc]init];
    }
    return _textStorage;
}

- (NSLayoutManager*)layoutManager{
    if (!_layoutManager) {
        _layoutManager = [[NSLayoutManager alloc]init];
    }
    return _layoutManager;
}
- (NSTextContainer*)textContainer{
    if (!_textContainer) {
        _textContainer = [[NSTextContainer alloc]init];
    }
    return _textContainer;
}


@end
