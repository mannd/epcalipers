//
//  HamburgerLayer.h
//  EP Calipers
//
//  Created by David Mann on 12/16/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// This corresponds with rows in menu.
typedef NS_ENUM(NSInteger, Layer) {
    Camera = 0,
    PhotoGallery,
    Lock,
    SampleEcg,
    Preferences,
    ToolTips,
    Manual,
    About
};

@interface HamburgerLayer : NSObject

@property (strong, nonatomic) NSString *name;
//@property (strong, nonatomic) NSString *iconName;
@property (nonatomic) Layer layer;
@property (nullable, strong, nonatomic)  NSString *altName;
//@property (nullable, strong, nonatomic) NSString *altIconName;
@property (nullable, strong, nonatomic) UIImage *icon;
@property (nullable, strong, nonatomic) UIImage *altIcon;

- (instancetype)initWithName:(NSString *)name iconName:(NSString *)iconName layer:(Layer)layer;
- (instancetype)initWithName:(NSString *)name iconName:(NSString *)iconName layer:(Layer)layer altName:(NSString *)altName altIconName:(NSString *)altIconName;

@end

NS_ASSUME_NONNULL_END
