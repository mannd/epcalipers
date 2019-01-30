//
//  Alert.h
//  EP Calipers
//
//  Created by David Mann on 12/15/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Alert : NSObject
+ (void)showSimpleAlertWithTitle:(NSString *)title message:(NSString *)message viewController:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
