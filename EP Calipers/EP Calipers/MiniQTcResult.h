//
//  MiniQTcResult.h
//  EP Calipers
//
//  Created by David Mann on 12/31/17.
//  Copyright © 2017 EP Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EPSMainViewController.h"

@interface MiniQTcResult : NSObject <QTcResultProtocol>

- (NSString *)calculateFromQtInSec:(double)qtInSec rrInSec:(double)rrInSec formula:(QTcFormulaPreference)formula convertToMsec:(BOOL)convertToMsec units:(NSString *)units;

@end
