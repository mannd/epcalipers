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
- (NSArray *)allLayers {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    HamburgerLayer *cameraLayer = [[HamburgerLayer alloc] initWithName:L(@"Take photo") iconName:@"camera" layer:Camera];
    [array addObject:cameraLayer];
    HamburgerLayer *selectPhotoLayer = [[HamburgerLayer alloc] initWithName:L(@"Select photo") iconName:@"photos" layer:PhotoGallery];
    [array addObject:selectPhotoLayer];
    HamburgerLayer *sampleEcgLayer = [[HamburgerLayer alloc] initWithName:L(@"Sample ECG") iconName:@"sample" layer:SampleEcg];
    [array addObject:sampleEcgLayer];
    HamburgerLayer *preferencesLayer = [[HamburgerLayer alloc] initWithName:L(@"Preferences") iconName:@"settings" layer:Preferences];
    [array addObject:preferencesLayer];
    HamburgerLayer *helpLayer = [[HamburgerLayer alloc] initWithName:L(@"Help") iconName:@"help" layer:Help];
    [array addObject:helpLayer];
    HamburgerLayer *aboutLayer = [[HamburgerLayer alloc] initWithName:L(@"About EP Calipers") iconName:@"about" layer:About];
    [array addObject:aboutLayer];

    return array;
}
@end
