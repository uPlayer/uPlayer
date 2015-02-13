//
//  GeneralPreferences.m
//  PrefsTest
//
//  Created by Dave Jewell on 13/12/2007.
//  Copyright 2007 Dave Jewell. All rights reserved.
//

#import "GeneralPreferences.h"
#import "UPlayer.h"

@interface GeneralPreferences ()
@property (weak) IBOutlet NSButton *resumeAtRebootCheckBox;
@property (weak) IBOutlet NSButton *trackSongsWhenPlayStarted;

@end

@implementation GeneralPreferences

-(void)awakeFromNib
{
    self.resumeAtRebootCheckBox.state = player().document.resumeAtReboot ? NSOnState : NSOffState;
    
    self.trackSongsWhenPlayStarted.state = player().document.trackSongsWhenPlayStarted? NSOnState : NSOffState;
}

- (BOOL)isResizable
{
	return NO;
}

- (IBAction)actionResumeAtReboot:(id)sender {
    player().document.resumeAtReboot = (self.resumeAtRebootCheckBox.state == NSOnState ? 1 : 0);
}
- (IBAction)actionTrackSongsWhenPlayStarted:(id)sender {
    player().document.trackSongsWhenPlayStarted= (self.trackSongsWhenPlayStarted.state == NSOnState ? 1 : 0);
}

@end
