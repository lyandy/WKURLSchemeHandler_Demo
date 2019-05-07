//
//  ViewController.m
//  WKURLSchemeHandler_Demo
//
//  Created by 李扬 on 2019/5/7.
//  Copyright © 2019 李扬. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "MMURLSchemeHandler.h"

@interface ViewController ()
{
    WKWebView *webView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    
    MMURLSchemeHandler *handler = [[MMURLSchemeHandler alloc] init];
    
    [config setURLSchemeHandler:handler forURLScheme:customMTTP];
    [config setURLSchemeHandler:handler forURLScheme:customMTTPS];
    
    webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:config];
    
    [self.view addSubview:webView];
    
    //    NSString *str = @"https://maimai.cn";
    //    NSString *str = @"https://www.baidu.com";
    NSString *str = @"https://www.ithome.com";
    
    //    NSURL *url = [NSURL URLWithString:str];
    
    NSURL *url = [NSURL URLWithString:[str stringByReplacingOccurrencesOfString:@"http" withString:customMTTP]];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    [webView loadRequest:request];
}


@end
