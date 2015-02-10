//
//  windowController.m
//  uPlayer
//
//  Created by liaogang on 15/1/28.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import "windowController.h"
#import "TracklistViewController.h"
#import "UPlayer.h"
#import "PlayerMessage.h"



@implementation NSSliderCellHideThumbWhenDisable
-(void)drawKnob:(NSRect)knobRect
{
    if (self.enabled)
        [super drawKnob:knobRect];
}
@end



@interface WindowController ()
<NSToolbarDelegate>
@property (weak) IBOutlet NSPopUpButton *playOrderBtn;
@property (weak) IBOutlet NSSlider *progressSlider;
@property (weak) IBOutlet NSSlider *volumnSlider;
@property (weak) IBOutlet NSSearchField *searchField;
@end

@implementation WindowController
- (IBAction)actionOrderChanged:(id)sender {
    
    player().document.playOrder = (PlayOrder)self.playOrderBtn.indexOfSelectedItem;
}


- (IBAction)actionSearch:(id)sender
{
    TracklistViewController *vc = (TracklistViewController *) self.contentViewController;
    
    NSSearchField *sf = (NSSearchField *)sender;
    
    [vc filterTable:sf.stringValue];
}


- (IBAction)actionProgressSlider:(id)sender {
    [player().engine seekToTime:[sender floatValue]];
}

- (IBAction)actionVolumnSlider:(id)sender {
}


-(void)updateProgressInfo:(NSNotification*)n
{
    if (!self.progressSlider.highlighted)
    {
        ProgressInfo *info = n.object;
        
        NSAssert([info isKindOfClass:[ProgressInfo class]], nil);
        
        [self.progressSlider setMinValue:0];
        [self.progressSlider setMaxValue:info.total];
        [self.progressSlider setDoubleValue:info.current];
    }
    
}

-(void)setWindowTitle:(NSNotification*)n
{
    NSAssert([n.object isKindOfClass:[NSString class]],nil);
    
    self.window.title=n.object;
    
    self.progressSlider.enabled = YES;
}

-(void)trackStopped
{
    NSLog(@"track stopped.");
    
    self.window.title = player().document.windowName;
    
    self.progressSlider.enabled = false;
}



-(void)dealloc
{
    removeObserver(self);
}




-(void)awakeFromNib
{
    /// @todo remove the progress bar thumb when stopped.
    
    self.window.title=player().document.windowName;
    
    [self.playOrderBtn addItemsWithTitles: kPlayOrder];
    

    addObserverForEvent(self , @selector(setWindowTitle:), EventID_to_change_player_title);
    
    addObserverForEvent(self , @selector(trackStopped), EventID_track_stopped);
    
    addObserverForEvent(self, @selector(updateProgressInfo:), EventID_track_progress_changed);
    
    addObserverForEvent(self, @selector(initCtrls), EventID_player_document_loaded);
}

-(void)initCtrls
{
     [self.playOrderBtn selectItemAtIndex: player().document.playOrder ];
}

@end

