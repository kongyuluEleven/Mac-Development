//
//  VerifyAppReceipt.m
//  KylStoreKit
//
//  Created by kongyulu on 2021/11/26.
//

#import "VerifyAppReceipt.h"
#import <IOKit/IOKitLib.h>
#import <Foundation/Foundation.h>
#import <Security/Security.h>
#include <openssl/pkcs7.h>
#include <openssl/objects.h>
#include <openssl/sha.h>
#include <openssl/x509.h>
#include <openssl/err.h>


NSString *const kIAPBundleIdentifer = @"BundleIdentifier";
NSString *const kIAPBundleIdentiferData = @"BundleIdentifierData";
NSString *const kIAPVersion = @"Version";
NSString *const kIAPOpaqueValue = @"OpaqueValue";
NSString *const kIAPHash = @"Hash";

@implementation VerifyAppReceipt

+(NSData *)appleRootCert {
    OSStatus status;
    
    SecKeychainRef keychain = nil;
    status = SecKeychainOpen("/System/Library/Keychains/SystemRootCertificates.keychain", &keychain);
    if(status) {
        if(keychain) CFRelease(keychain);
        return nil;
    }
    
    CFArrayRef searchList = CFArrayCreate(kCFAllocatorDefault, (const void**)&keychain, 1, &kCFTypeArrayCallBacks);

    if (keychain)
        CFRelease(keychain);
    
    SecKeychainSearchRef searchRef = nil;
    status = SecKeychainSearchCreateFromAttributes(searchList, kSecCertificateItemClass, NULL, &searchRef);
    //[[NSGarbageCollector defaultCollector] disableCollectorForPointer:searchRef];
    if(status) {
        if(searchRef) CFRelease(searchRef);
        if(searchList) CFRelease(searchList);
        return nil;
    }
    
    SecKeychainItemRef itemRef = nil;
    NSData * resultData = nil;
    
    while(SecKeychainSearchCopyNext(searchRef, &itemRef) == noErr && resultData == nil) {
        // Grab the name of the certificate
        SecKeychainAttributeList list;
        SecKeychainAttribute attributes[1];
        
        attributes[0].tag = kSecLabelItemAttr;
        
        list.count = 1;
        list.attr = attributes;
        
        SecKeychainItemCopyContent(itemRef, nil, &list, nil, nil);
        NSData *nameData = [NSData dataWithBytesNoCopy:attributes[0].data length:attributes[0].length freeWhenDone:NO];
        NSString *name = [[NSString alloc] initWithData:nameData encoding:NSUTF8StringEncoding];
        
        if([name isEqualToString:@"Apple Root CA"]) {
            CSSM_DATA certData;
            status = SecCertificateGetData((SecCertificateRef)itemRef, &certData);
            if(status) {
                if(itemRef) CFRelease(itemRef);
            }
                        
            resultData = [NSData dataWithBytes:certData.Data length:certData.Length];
            
            SecKeychainItemFreeContent(&list, NULL);
            if(itemRef) CFRelease(itemRef);
        }
        
        //[name release];
    }
    CFRelease(searchList);
    CFRelease(searchRef);
    
    return resultData;
}


+(NSDictionary *)dictionaryWithAppStoreReceipt:(NSString *)path {
    NSData * rootCertData = [self appleRootCert];
    if(rootCertData == nil)
    {
        return nil;
    }
    
    enum ATTRIBUTES
    {
        ATTR_START = 1,
        BUNDLE_ID,
        VERSION,
        OPAQUE_VALUE,
        HASH,
        ATTR_END
    };
    
    ERR_load_PKCS7_strings();
    ERR_load_X509_strings();
    OpenSSL_add_all_digests();
    
    // Expected input is a PKCS7 container with signed data containing
    // an ASN.1 SET of SEQUENCE structures. Each SEQUENCE contains
    // two INTEGERS and an OCTET STRING.
    
    const char * receiptPath = [[path stringByStandardizingPath] fileSystemRepresentation];
    FILE *fp = fopen(receiptPath, "rb");
    if (fp == NULL)
        return nil;
    
    PKCS7 *p7 = d2i_PKCS7_fp(fp, NULL);
    fclose(fp);
    
    if (!PKCS7_type_is_signed(p7)) {
        PKCS7_free(p7);
        return nil;
    }
    
    if (!PKCS7_type_is_data(p7->d.sign->contents)) {
        PKCS7_free(p7);
        return nil;
    }
    
    int verifyReturnValue = 0;
    X509_STORE *store = X509_STORE_new();
    if (store)
    {
        unsigned char *data = (unsigned char *)(rootCertData.bytes);
        X509 *appleCA = d2i_X509(NULL, &data, rootCertData.length);
        if (appleCA)
        {
            BIO *payload = BIO_new(BIO_s_mem());
            X509_STORE_add_cert(store, appleCA);

            if (payload)
            {
                verifyReturnValue = PKCS7_verify(p7,NULL,store,NULL,payload,0);
                BIO_free(payload);
            }

            // this code will come handy when the first real receipts arrive
#if 1
            unsigned long err = ERR_get_error();
            if(err)
                printf("%lu: %s\n",err,ERR_error_string(err,NULL));
            else {
                STACK_OF(X509) *stack = PKCS7_get0_signers(p7, NULL, 0);
                for(NSUInteger i = 0; i < sk_num(stack); i++) {
                    const X509 *signer = (X509*)sk_value(stack, i);
                    //NSLog(@"name = %s", signer->name);
                    NSLog(@"name = %s", signer);
                }
            }
#endif

            X509_free(appleCA);
        }
        X509_STORE_free(store);
    }
    EVP_cleanup();
    
    if (verifyReturnValue != 1)
    {
        PKCS7_free(p7);
        return nil;
    }
    
    ASN1_OCTET_STRING *octets = p7->d.sign->contents->d.data;
    unsigned char *p = octets->data;
    unsigned char *end = p + octets->length;
    
    int type = 0;
    int xclass = 0;
    long length = 0;
    
    ASN1_get_object(&p, &length, &type, &xclass, end - p);
    if (type != V_ASN1_SET) {
        PKCS7_free(p7);
        return nil;
    }
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    
    while (p < end) {
        ASN1_get_object(&p, &length, &type, &xclass, end - p);
        if (type != V_ASN1_SEQUENCE)
            break;
        
        const unsigned char *seq_end = p + length;
        
        int attr_type = 0;
        int attr_version = 0;
        
        // Attribute type
        ASN1_get_object(&p, &length, &type, &xclass, seq_end - p);
        if (type == V_ASN1_INTEGER && length == 1) {
            attr_type = p[0];
        }
        p += length;
        
        // Attribute version
        ASN1_get_object(&p, &length, &type, &xclass, seq_end - p);
        if (type == V_ASN1_INTEGER && length == 1) {
            attr_version = p[0];
            attr_version = attr_version;
        }
        p += length;
        
        // Only parse attributes we're interested in
        if (attr_type > ATTR_START && attr_type < ATTR_END) {
            NSString *key;
            
            ASN1_get_object(&p, &length, &type, &xclass, seq_end - p);
            if (type == V_ASN1_OCTET_STRING) {
                
                // Bytes
                if (attr_type == BUNDLE_ID || attr_type == OPAQUE_VALUE || attr_type == HASH) {
                    NSData *data = [NSData dataWithBytes:p length:length];
                    
                    switch (attr_type) {
                        case BUNDLE_ID:
                            // This is included for hash generation
                            key = kIAPBundleIdentiferData;
                            break;
                        case OPAQUE_VALUE:
                            key = kIAPOpaqueValue;
                            break;
                        case HASH:
                            key = kIAPHash;
                            break;
                    }
                    
                    [info setObject:data forKey:key];
                }
                
                // Strings
                if (attr_type == BUNDLE_ID || attr_type == VERSION) {
                    int str_type = 0;
                    long str_length = 0;
                    unsigned char *str_p = p;
                    ASN1_get_object(&str_p, &str_length, &str_type, &xclass, seq_end - str_p);
                    if (str_type == V_ASN1_UTF8STRING) {
                        //NSString *string = [[[NSString alloc] initWithBytes:str_p length:str_length encoding:NSUTF8StringEncoding] autorelease];
                        NSString *string = [[NSString alloc] initWithBytes:str_p length:str_length encoding:NSUTF8StringEncoding];
                        switch (attr_type) {
                            case BUNDLE_ID:
                                key = kIAPBundleIdentifer;
                                break;
                            case VERSION:
                                key = kIAPVersion;
                                break;
                        }
                        
                        [info setObject:string forKey:key];
                    }
                }
            }
            p += length;
        }
        
        // Skip any remaining fields in this SEQUENCE
        while (p < seq_end) {
            ASN1_get_object(&p, &length, &type, &xclass, seq_end - p);
            p += length;
        }
    }
    
    PKCS7_free(p7);
    return info;
}



// Returns a CFData object, containing the machine's GUID.
+(CFDataRef)copy_mac_address {
    kern_return_t             kernResult;
    mach_port_t               master_port;
    CFMutableDictionaryRef    matchingDict;
    io_iterator_t             iterator;
    io_object_t               service;
    CFDataRef                 macAddress = nil;
    
    kernResult = IOMasterPort(MACH_PORT_NULL, &master_port);
    if (kernResult != KERN_SUCCESS) {
        printf("IOMasterPort returned %d\n", kernResult);
        return nil;
    }
    
    matchingDict = IOBSDNameMatching(master_port, 0, "en0");
    if(!matchingDict) {
        printf("IOBSDNameMatching returned empty dictionary\n");
        return nil;
    }
    
    kernResult = IOServiceGetMatchingServices(master_port, matchingDict, &iterator);
    if (kernResult != KERN_SUCCESS) {
        printf("IOServiceGetMatchingServices returned %d\n", kernResult);
        return nil;
    }
    
    while((service = IOIteratorNext(iterator)) != 0)
    {
        io_object_t        parentService;
        
        kernResult = IORegistryEntryGetParentEntry(service, kIOServicePlane, &parentService);
        if(kernResult == KERN_SUCCESS)
        {
            if(macAddress) CFRelease(macAddress);
            
            macAddress = (CFDataRef)IORegistryEntryCreateCFProperty(parentService, CFSTR("IOMACAddress"), kCFAllocatorDefault, 0);
            IOObjectRelease(parentService);
        }
        else {
            printf("IORegistryEntryGetParentEntry returned %d\n", kernResult);
        }
        
        IOObjectRelease(service);
    }
    
    return macAddress;
}

+(int)validateReceiptAtPath:(NSString *)path {
    NSDictionary * receipt = [self dictionaryWithAppStoreReceipt: path];
    
    if (!receipt)
        return 173;
    
    NSData * guidData = nil;
    NSString *bundleVersion = nil;
    NSString *bundleIdentifer = nil;
    guidData = (__bridge NSData*)[self copy_mac_address];

//    if ([NSGarbageCollector defaultCollector])
//        [[NSGarbageCollector defaultCollector] enableCollectorForPointer:(__bridge const void * _Nonnull)(guidData)];
//    else
//        [guidData autorelease];

    if (!guidData)
        return 173;
    
//    bundleVersion = @"8.5.5";
    bundleIdentifer = @"com.Wondershare.Vivideo";
    NSMutableData *input = [NSMutableData data];
    [input appendData:guidData];
    [input appendData:[receipt objectForKey:kIAPOpaqueValue]];
    [input appendData:[receipt objectForKey:kIAPBundleIdentiferData]];
    
    NSMutableData *hash = [NSMutableData dataWithLength:SHA_DIGEST_LENGTH];
    SHA1((const unsigned char *)[input bytes], [input length], (unsigned char *)[hash mutableBytes]);
//    BOOL hashValue = [hash isEqualToData:[receipt objectForKey:kReceiptHash]];
//    BOOL bVersion = [bundleVersion isEqualToString:[receipt objectForKey:kReceiptVersion]];
//    BOOL bidValue = [bundleIdentifer isEqualToString:[receipt objectForKey:kReceiptBundleIdentifer]];

    if ([hash isEqualToData:[receipt objectForKey:kIAPHash]] &&
        [bundleIdentifer isEqualToString:[receipt objectForKey:kIAPBundleIdentifer]]) {
        return 9;
    }

    return 173;
}

@end
