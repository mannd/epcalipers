//
//  MiniQTcResult.m
//  EP Calipers
//
//  Created by David Mann on 12/31/17.
//  Copyright © 2017 EP Studios. All rights reserved.
//

#import "MiniQTcResult.h"


@implementation MiniQTcResult

- (NSString *)calculateFromQtInSec:(double)qtInSec rrInSec:(double)rrInSec formula:(QTcFormulaPreference)formula convertToMsec:(BOOL)convertToMsec units:(NSString *)units {
    
    NSDictionary *formulaNames = [NSDictionary dictionaryWithObjectsAndKeys:@"Bazett", [NSNumber numberWithInteger:Bazett], @"Framingham", [NSNumber numberWithInteger:Framingham], @"Fridericia", [NSNumber numberWithInteger:Fridericia], @"Hodges", [NSNumber numberWithInteger:Hodges], nil];
    NSString *errorResult = NSLocalizedString(@"Invalid Result", @"");
    if (rrInSec <= 0) {
        return errorResult;
    }
    NSArray* formulas = nil;
    switch (formula) {
        case Bazett:
            formulas = [NSArray arrayWithObject:[NSNumber numberWithInteger:Bazett]];
            break;
        case Framingham:
            formulas = [NSArray arrayWithObject:[NSNumber numberWithInteger:Framingham]];
            break;
        case Fridericia:
            formulas = [NSArray arrayWithObject:[NSNumber numberWithInteger:Fridericia]];
            break;
        case Hodges:
            formulas = [NSArray arrayWithObject:[NSNumber numberWithInteger:Hodges]];
            break;
        case all:
            formulas = [NSArray arrayWithObjects:[NSNumber numberWithInteger:Bazett], [NSNumber numberWithInteger:Framingham], [NSNumber numberWithInteger:Fridericia], [NSNumber numberWithInteger:Hodges], nil];
            break;
    }
   
    double meanRR = rrInSec;
    double qt = qtInSec;
    if (convertToMsec) {
        meanRR *= 1000;
        qt *= 1000;
    }
    NSString *result = [NSString localizedStringWithFormat:NSLocalizedString(@"Mean RR = %.4g %@\nQT = %.4g %@", comment:@""), meanRR, units, qt, units];
    double qtc = 0;
    for (NSNumber *calculator in formulas) {
        QTcFormulaPreference calc = (QTcFormulaPreference)[calculator integerValue];
        switch (calc) {
            case Bazett:
                qtc = [self bazettQtcFromQt:qtInSec rr:rrInSec];
                break;
            case Framingham:
                qtc = [self framinghamQtcFromQt:qtInSec rr:rrInSec];
                break;
            case Fridericia:
                qtc = [self fridericiaQtcFromQt:qtInSec rr:rrInSec];
                break;
            case Hodges:
                qtc = [self hodgesQtcFromQt:qtInSec rr:rrInSec];
                break;
            default:
                break;
        }
        if (qtc == INFINITY || qtc == NAN || qtc <= 0) {
            return errorResult;
        }
        qtc = round(qtc * 10000.0) / 10000.0;
        if (convertToMsec) {
            qtc *= 1000;
        }
        NSString *qtcResult = [NSString localizedStringWithFormat:NSLocalizedString(@"\nQTc = %.4g %@ (%@ formula)", comment:""), qtc, units, [formulaNames objectForKey:calculator]];
        result = [result stringByAppendingString:qtcResult];
    }
    
    return result;
}

- (double)qtcExpFromQtInSec:(double)qtInSec rr:(double)rrInSec exp:(double)exp {
    return qtInSec / pow(rrInSec, exp);
}

- (double)qtcLinearFromQtInSec:(double)qtInSec rr:(double)rrInSec alpha:(double)alpha  {
    return qtInSec + alpha * (1 - rrInSec);
}

- (double)bazettQtcFromQt:(double)qtInSec rr:(double)rrInSec {
    return [self qtcExpFromQtInSec:qtInSec rr:rrInSec exp:0.5];
}

- (double)framinghamQtcFromQt:(double)qtInSec rr:(double)rrInSec {
    return [self qtcLinearFromQtInSec:qtInSec rr:rrInSec alpha:0.154];
}

- (double)fridericiaQtcFromQt:(double)qtInSec rr:(double)rrInSec {
    return [self qtcExpFromQtInSec:qtInSec rr:rrInSec exp:1.0 / 3.0];
}

- (double)hodgesQtcFromQt:(double)qtInSec rr:(double)rrInSec {
    return qtInSec + 0.00175 * ((60.0 / rrInSec) - 60);
}

@end
