//
//  Translation.h
//  EP Calipers
//
//  Created by David Mann on 1/6/19.
//  Copyright © 2019 EP Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

// Look for untranslated string by default.
#ifdef DEBUG
#define L(s) [Translation translatedKey:s]
//#define X(s) [NSString stringWithFormat:@"*<%@>*", s]
//#define L(s) NSLocalizedStringWithDefaultValue(s, @"Localizable", [NSBundle mainBundle], X(s), @"")
#else
#define L(s) NSLocalizedString(s, nil)
#endif

NS_ASSUME_NONNULL_BEGIN

@interface Translation : NSObject
+ (NSString *)translatedKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
