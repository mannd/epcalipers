//
//  CaliperView.h
//  EP Calipers
//
//  Created by David Mann on 3/23/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Settings.h"

@interface CalipersView : UIView

- (id)initWithCoder:(NSCoder *)aDecoder;
@property (nonatomic, strong)NSMutableArray *calipers;
@property (weak, nonatomic)IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic)Settings *settings;

@end
