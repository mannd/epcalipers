//
//  HamburgerViewModel.m
//  EP Calipers
//
//  Created by David Mann on 12/16/18.
//  Copyright © 2018 EP Studios. All rights reserved.
//

#import "HamburgerViewModel.h"
#include "Defs.h"

@implementation HamburgerViewModel

// NOTE: These must be added in same order as HamburgerLayer enum.
- (NSArray *)allLayers {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    HamburgerLayer *cameraLayer = [[HamburgerLayer alloc] initWithName:L(@"Take photo") iconName:@"camera" layer:Camera];
    [array addObject:cameraLayer];
    HamburgerLayer *selectPhotoLayer = [[HamburgerLayer alloc] initWithName:L(@"Select image") iconName:@"photos" layer:PhotoGallery];
    [array addObject:selectPhotoLayer];
    HamburgerLayer *lockLayer = [[HamburgerLayer alloc] initWithName:L(@"Lock image") iconName:@"lock" layer:Lock altName:L(@"Unlock image") altIconName:@"unlock"];
    [array addObject:lockLayer];
    HamburgerLayer *sampleEcgLayer = [[HamburgerLayer alloc] initWithName:L(@"Sample ECG") iconName:@"sample" layer:SampleEcg];
    [array addObject:sampleEcgLayer];
    HamburgerLayer *nextPageLayer = [[HamburgerLayer alloc] initWithName:L(@"PDF next page") iconName:@"nextpage" layer:NextPage];
    [array addObject:nextPageLayer];
    HamburgerLayer *previousPageLayer = [[HamburgerLayer alloc] initWithName:L(@"PDF previous page") iconName:@"previouspage" layer:NextPage];
    [array addObject:previousPageLayer];
    HamburgerLayer *preferencesLayer = [[HamburgerLayer alloc] initWithName:L(@"Preferences") iconName:@"settings" layer:Preferences];
    [array addObject:preferencesLayer];
    HamburgerLayer *helpLayer = [[HamburgerLayer alloc] initWithName:L(@"Help") iconName:@"help" layer:Help];
    [array addObject:helpLayer];
    HamburgerLayer *aboutLayer = [[HamburgerLayer alloc] initWithName:L(@"About EP Calipers") iconName:@"about" layer:About];
    [array addObject:aboutLayer];

    return array;
}
@end
