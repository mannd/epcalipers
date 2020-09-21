//
//  WebViewController.h
//  EP Calipers
//
//  Created by David Mann on 4/1/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <WebKit/WKNavigationDelegate.h>

@interface WebViewController : UIViewController <WKNavigationDelegate>
@property (strong, nonatomic) IBOutlet WKWebView * _Nonnull webView;
@property (nullable, strong, nonatomic) NSString *anchor;
@property (nullable, strong, nonatomic) NSString *fullLink;

@end
