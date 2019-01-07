//
//  Translation.m
//  EP Calipers
//
//  Created by David Mann on 1/6/19.
//  Copyright © 2019 EP Studios. All rights reserved.
//

#import "Translation.h"


@implementation Translation

+ (NSString *)translatedKey:(NSString *)key {
    NSString *notFound = [NSString stringWithFormat:@"*<%@>*", key];
    NSString *translated = NSLocalizedStringWithDefaultValue(key, @"Localizable", [NSBundle mainBundle], notFound, @"");
    if ([translated length] > 1 && [[translated substringToIndex:2] isEqualToString:@"*<"]) {
        NSLog(@"Untranslated key %@", notFound);
    }
    return translated;
}
@end
