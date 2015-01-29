//
//  windowController.m
//  uPlayer
//
//  Created by liaogang on 15/1/28.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import "windowController.h"
#import "ViewController.h"
#import "UPlayer.h"
#import "PlayerMessage.h"

@interface WindowController ()
<NSToolbarDelegate>
@property (weak) IBOutlet NSComboBox *orderCombo;
@property (weak) IBOutlet NSSlider *progressSlider;
@property (weak) IBOutlet NSSlider *volumnSlider;
@property (weak) IBOutlet NSSearchField *searchField;
@end

@implementation WindowController
- (IBAction)actionSearch:(id)sender
{
    ViewController *vc = (ViewController *) self.contentViewController;
    
    NSSearchField *sf = (NSSearchField *)sender;
    
    [vc filterTable:sf.stringValue];
}

- (IBAction)actionChangePlayOrder:(id)sender {
}

- (IBAction)actionProgressSlider:(id)sender {
}

- (IBAction)actionVolumnSlider:(id)sender {
}

-(void)windowWillLoad
{
    addObserverForEvent(self , @selector(setWindowTitle:), EventID_to_change_player_title);
    
    addObserverForEvent(self, @selector(updateProgressInfo:), EventID_track_progress_changed);
    
}


-(void)updateProgressInfo:(NSNotification*)n
{
    ProgressInfo *info = n.object;
    
    NSAssert([info isKindOfClass:[ProgressInfo class]], nil);
    
    
    [self.progressSlider setMinValue:0];
    [self.progressSlider setMaxValue:info.total];
    [self.progressSlider setDoubleValue:info.current];
    
}

-(void)setWindowTitle:(NSNotification*)n
{
    NSAssert([n.object isKindOfClass:[NSString class]],nil);
    
    self.window.title=n.object;
}

- (void) windowWillClose:(NSNotification *)notification
{
    removeObserver(self);
    
    [player().engine stop];
}

@end

