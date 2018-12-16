//
//  EcgImageView.h
//  EP Calipers
//
//  Created by David Mann on 12/16/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EcgImageView : UIImageView

@property (nonatomic) BOOL hamburgerMenuEnabled;
@property (nonatomic) BOOL allowSideSwipe;

- (id)initWithCoder:(NSCoder *)aDecoder;

@end

NS_ASSUME_NONNULL_END
