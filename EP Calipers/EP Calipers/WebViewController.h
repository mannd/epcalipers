//
//  WebViewController.h
//  EP Calipers
//
//  Created by David Mann on 4/1/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HelpProtocol.h"

@interface WebViewController : UIViewController <HelpProtocol>
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic) NSUInteger pageIndex;

@end
