//
//  MMURLSchemeHandler.m
//  WKWebview
//
//  Created by 李扬 on 2019/5/6.
//  Copyright © 2019 BeidouLife. All rights reserved.
//

#import "MMURLSchemeHandler.h"
#import <CommonCrypto/CommonDigest.h>
#import <Foundation/Foundation.h>

NSString * const customMTTP = @"mttp";
NSString * const customMTTPS = @"mttps";

@implementation MMURLSchemeHandler
{
    NSMutableArray<id <WKURLSchemeTask>> *_urlSchemeTasks;
}

static bool isLiyang(char ch) {
    return (ch == '_' || (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z'));
}

static void replaceText(char* text) {
    int32_t http = 0;
    memcpy(&http, "http", sizeof(http));
    uint32_t test = 0;
    size_t len = strlen(text);
    if (len >= 4) {
        memcpy(&test, text, sizeof(test));
        for (size_t i = 3; i < len; i++) {
            if (test == http) {
                if (i == 3 || !isLiyang(text[i-4])) {
                    if (i == len-1 || !isLiyang(text[i+1])) {
                        text[i-3] = 'm';
                        printf("iiii %d\n", i);
                        // http
                    } else if (i < len-1 && text[i+1] == 's' && (i == len-2 || !isLiyang(text[i+2]))) {
                        text[i-3] = 'm';
                        // https
                        printf("iiii %d\n", i);
                    }
                }
            }
            test >>= 8;
            test |= (text[i+1]<<24);
        }
    }
}

- (void)webView:(WKWebView *)webView startURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask
{
    if (_urlSchemeTasks == nil) _urlSchemeTasks = [NSMutableArray array];
    [_urlSchemeTasks addObject:urlSchemeTask];
    NSMutableURLRequest *request = [urlSchemeTask.request mutableCopy];
    
    NSURLComponents *components = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:NO];
    if ([components.scheme isEqualToString:customMTTP]) {
        components.scheme = @"http";
    } else if ([components.scheme isEqualToString:customMTTPS]) {
        components.scheme = @"https";
    }
    request.URL = components.URL;
    [request addValue:@"1" forHTTPHeaderField:@"mttp"];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if ([_urlSchemeTasks containsObject:urlSchemeTask]) {
            if (error) {
                [urlSchemeTask didFailWithError:error];
            } else {
                if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                    NSString *contentType = [(NSHTTPURLResponse *)response allHeaderFields][@"content-type"];
                    if ([contentType hasPrefix:@"text/html"] ||
                        [contentType hasPrefix:@"application/javascript"] ||
                        [contentType hasPrefix:@"text/css"]) {
                        printf("iiii  %s\n", request.URL.absoluteString.UTF8String);
                        char end = 0;
                        NSMutableData *temp = [data mutableCopy];
                        [temp appendBytes:&end length:sizeof(end)];
                        char *body = (char*)[temp mutableBytes];
                        replaceText(body);
                        [temp setLength:temp.length-sizeof(end)];
                        data = temp;
                        
                        [data writeToFile:[NSString stringWithFormat:@"/Users/liyang/Desktop/ithome/%@.txt", [self MD5WithStr:request.URL.absoluteString]]  atomically:YES];
                        printf("%s\n", [self MD5WithStr:request.URL.absoluteString].UTF8String);
                        
                        printf("\n\n\n\n\n\n\n");
                    }
                }
                
                @try {
                    [urlSchemeTask didReceiveResponse:response];
                    
                    [urlSchemeTask didReceiveData:data];
                    
                    [urlSchemeTask didFinish];
                } @catch (NSException *exception) {
                } @finally {
                }
            }
            [_urlSchemeTasks removeObjectIdenticalTo:urlSchemeTask];
        }
        
    }] resume];
}

- (void)webView:(WKWebView *)webView stopURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask;
{
    [_urlSchemeTasks removeObjectIdenticalTo:urlSchemeTask];
}

- (NSString*)MD5WithStr:(NSString *)str
{
    // Create pointer to the string as UTF8
    const char *ptr = [str UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

@end
