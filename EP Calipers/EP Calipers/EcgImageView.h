//
//  EcgImageView.h
//  EP Calipers
//
//  Created by David Mann on 12/16/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HamburgerDelegate <NSObject>

@property (nonatomic) BOOL hamburgerMenuIsOpen;

- (void)hideHamburgerMenu;

@end

@interface EcgImageView : UIImageView<UIGestureRecognizerDelegate>

@property (nonatomic) BOOL allowSideSwipe;
@property (nonatomic) BOOL isLeftToRight;
@property (weak, nonatomic) id <HamburgerDelegate> delegate;

- (id)initWithCoder:(NSCoder *)aDecoder;

@end

NS_ASSUME_NONNULL_END
