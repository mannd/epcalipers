//
//  WebViewController.h
//  EP Calipers
//
//  Created by David Mann on 4/1/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (nullable, strong, nonatomic) NSString *anchor;
@property (nullable, strong, nonatomic) NSString *fullLink;

@end
