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
@property (weak) IBOutlet NSPopUpButton *playOrderBtn;
@property (weak) IBOutlet NSSlider *progressSlider;
@property (weak) IBOutlet NSSlider *volumnSlider;
@property (weak) IBOutlet NSSearchField *searchField;
@end

@implementation WindowController
- (IBAction)actionOrderChanged:(id)sender {
    
    postEvent(EventID_to_change_player_order, [NSNumber numberWithInt: (int)self.playOrderBtn.indexOfSelectedItem]);
}


- (IBAction)actionSearch:(id)sender
{
    ViewController *vc = (ViewController *) self.contentViewController;
    
    NSSearchField *sf = (NSSearchField *)sender;
    
    [vc filterTable:sf.stringValue];
}


- (IBAction)actionProgressSlider:(id)sender {
}

- (IBAction)actionVolumnSlider:(id)sender {
}

-(void)windowWillLoad
{
    addObserverForEvent(self , @selector(setWindowTitle:), EventID_to_change_player_title);
    
    addObserverForEvent(self , @selector(clearWindowTitle:), EventID_track_stopped);
    
    addObserverForEvent(self, @selector(updateProgressInfo:), EventID_track_progress_changed);
}

-(void)windowDidLoad
{
    
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

-(void)clearWindowTitle:(NSNotification*)n
{
    self.window.title = player().document.windowName;
}

-(void)dealloc
{
    
    removeObserver(self);
}




-(void)awakeFromNib
{
    /// @todo remove the progress bar thumb when stopped.
    
    self.window.title=player().document.windowName;
    
    [self.playOrderBtn addItemsWithTitles:@[    @"single",
                                                        @"default" ,
                                                        @"random" ,
                                                        @"repeat_single" ,
                                                        @"repeat_list" ,
                                                        @"shuffle" ]];
    
    [self.playOrderBtn selectItemAtIndex:1];
    
}


@end

