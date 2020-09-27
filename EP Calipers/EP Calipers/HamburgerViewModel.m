//
//  HamburgerViewModel.m
//  EP Calipers
//
//  Created by David Mann on 12/16/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import "HamburgerViewModel.h"
#import "Translation.h"
#import "Defs.h"

// TODO: define strings with new keys

@implementation HamburgerViewModel

// NOTE: These must be added in same order as HamburgerLayer enum.
- (NSArray *)allLayers {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    HamburgerLayer *cameraLayer = [[HamburgerLayer alloc] initWithName:L(@"Take_photo") iconName:@"camera" layer:Camera];
    [array addObject:cameraLayer];
    HamburgerLayer *selectPhotoLayer = [[HamburgerLayer alloc] initWithName:L(@"Select_image") iconName:@"photos" layer:PhotoGallery];
    [array addObject:selectPhotoLayer];
    HamburgerLayer *lockLayer = [[HamburgerLayer alloc] initWithName:L(@"Lock_image") iconName:@"lock" layer:Lock altName:L(@"Unlock_image") altIconName:@"unlock"];
    [array addObject:lockLayer];
    HamburgerLayer *sampleEcgLayer = [[HamburgerLayer alloc] initWithName:L(@"Sample_ecg") iconName:@"ecg" layer:SampleEcg];
    [array addObject:sampleEcgLayer];
    HamburgerLayer *preferencesLayer = [[HamburgerLayer alloc] initWithName:L(@"Preferences") iconName:@"settings" layer:Preferences];
    [array addObject:preferencesLayer];
    HamburgerLayer *tooltipLayer = [[HamburgerLayer alloc] initWithName:L(@"Show_tooltips") iconName:@"hammer" layer:ToolTips altName:L(@"Hide_tooltips") altIconName:@"hammer"];
    [array addObject:tooltipLayer];
//    HamburgerLayer *helpLayer = [[HamburgerLayer alloc] initWithName:L(@"Quick_help") iconName:@"help" layer:Help];
//    [array addObject:helpLayer];
    HamburgerLayer *manualLayer = [[HamburgerLayer alloc] initWithName:L(@"Help") iconName:@"help" layer:Manual];
    [array addObject:manualLayer];
    HamburgerLayer *aboutLayer = [[HamburgerLayer alloc] initWithName:L(@"About_ep_calipers") iconName:@"about" layer:About];
    [array addObject:aboutLayer];

    return array;
}
@end
