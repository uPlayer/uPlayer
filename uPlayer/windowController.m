//
//  windowController.m
//  uPlayer
//
//  Created by liaogang on 15/1/28.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import "windowController.h"
#import "ViewController.h"

@interface WindowController ()
<NSToolbarDelegate>
@end

@implementation WindowController
- (IBAction)actionSearch:(id)sender
{
    ViewController *vc = (ViewController *) self.contentViewController;
    
    NSSearchField *sf = (NSSearchField *)sender;
    
    [vc filterTable:sf.stringValue];
}

-(instancetype)init
{
    self =[ super init];
    if (self) {
        
        
        
    }
    
    return self;
}

@end

