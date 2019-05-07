//
//  MMURLSchemeHandler.h
//  WKWebview
//
//  Created by 李扬 on 2019/5/6.
//  Copyright © 2019 BeidouLife. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

extern NSString * const customMTTP;
extern NSString * const customMTTPS;

NS_ASSUME_NONNULL_BEGIN

@interface MMURLSchemeHandler : NSObject<WKURLSchemeHandler>

@end

NS_ASSUME_NONNULL_END
