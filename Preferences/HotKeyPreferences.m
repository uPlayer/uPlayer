//
//  HotKeyPreferences.m
//  PrefsTest
//
//  Created by Dave Jewell on 13/12/2007.
//  Copyright 2007 Dave Jewell. All rights reserved.
//

#import "HotKeyPreferences.h"
#import "LLHotKeyControl.h"

@interface HotKeyPreferences ()
@property (weak) IBOutlet LLHotKeyControl *btnPlayPause;
@property (weak) IBOutlet LLHotKeyControl *btnNext;
@property (weak) IBOutlet LLHotKeyControl *btnRandom;

@end

@implementation HotKeyPreferences
- (BOOL)isResizable
{
    return NO;
}

- (IBAction)PlayPause:(id)sender
{
    
}

- (IBAction)Next:(id)sender
{
}

- (IBAction)Random:(id)sender
{
}

@end
