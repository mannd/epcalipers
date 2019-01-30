//
//  BlackView.h
//  EP Calipers
//
//  Created by David Mann on 1/13/19.
//  Copyright © 2019 EP Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HamburgerDelegate <NSObject>
@property (nonatomic) BOOL hamburgerMenuIsOpen;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHamburgerLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHamburgerWidth;
@property (nonatomic) CGFloat maxBlackAlpha;
- (void)hideHamburgerMenu;
- (void)showHamburgerMenu;
@end

@interface BlackView : UIView<UIGestureRecognizerDelegate>

@property (weak, nonatomic) id <HamburgerDelegate> delegate;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end

NS_ASSUME_NONNULL_END
