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
#import "AppDelegate.h"
#import "PlaylistViewController.h"
#import "keycode.h"

#define uPlayerWinPos @"uPlayerWinPos"



@interface NSSliderCellHideThumbWhenDisable : NSSliderCell
-(void)drawKnob:(NSRect)knobRect;
@end

@implementation NSSliderCellHideThumbWhenDisable
-(void)drawKnob:(NSRect)knobRect
{
    if (self.enabled)
        [super drawKnob:knobRect];
}
@end



@interface WindowController () <NSToolbarDelegate>
@property (weak) IBOutlet NSPopUpButton *playOrderBtn;
@property (weak) IBOutlet NSSlider *progressSlider;
@property (weak) IBOutlet NSSlider *volumnSlider;
@property (weak) IBOutlet NSSearchField *searchField;

@property (nonatomic,strong) NSString *searchKeys;

@property (strong,nonatomic) PlaylistViewController* playlistManager;
@end

@implementation WindowController

-(void)awakeFromNib
{
    self.window.title=player().document.windowName;
    
    [self.playOrderBtn addItemsWithTitles:  kPlayOrder];
    
    addObserverForEvent(self , @selector(updateUI), EventID_track_state_changed);
    
    addObserverForEvent(self , @selector(trackStarted:), EventID_track_started);
    
    addObserverForEvent(self, @selector(updateProgressInfo:), EventID_track_progress_changed);
    
    addObserverForEvent(self, @selector(initCtrls), EventID_player_document_loaded);
    
    addObserverForEvent(self, @selector(showPlaylistManager), EventID_to_show_playlist);
    
    
}

-(void)showPlaylistManager
{
    NSWindow *wnd;
    
    if (!_playlistManager)
    {
        NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
        
       self.playlistManager = [storyboard instantiateControllerWithIdentifier:@"PlaylistViewController"];
    }
    
    wnd = _playlistManager.view.window;
    if (!wnd)
        wnd = [NSWindow windowWithContentViewController:_playlistManager];
    
    if (wnd.parentWindow)
        [wnd makeKeyWindow];
    else
        [self.window addChildWindow:wnd ordered:NSWindowAbove];
    
}

- (IBAction)actionOrderChanged:(id)sender
{
    player().document.playOrder = (PlayOrder)self.playOrderBtn.indexOfSelectedItem;
}


- (IBAction)actionSearch:(id)sender
{
    TracklistViewController *vc = (TracklistViewController *) self.contentViewController;
    
    NSSearchField *sf = (NSSearchField *)sender;
    
    [vc filterTable:sf.stringValue];
}


- (IBAction)actionProgressSlider:(id)sender
{
    [player().engine seekToTime:[sender floatValue]];
}

- (IBAction)actionVolumnSlider:(id)sender
{
    [player().engine setVolume:[sender floatValue]];
}

-(void)updateProgressInfo:(NSNotification*)n
{
    if (!self.progressSlider.highlighted)
    {
        ProgressInfo *info = n.object;
        
        NSAssert([info isKindOfClass:[ProgressInfo class]], nil);
        [self.progressSlider setMaxValue:info.total];
        [self.progressSlider setDoubleValue:info.current];
    }
    
}

-(void)trackStarted:(NSNotification*)n
{
    ProgressInfo *info = n.object;
    NSAssert([info isKindOfClass:[ProgressInfo class]], nil);
    [self.progressSlider setMaxValue:info.total];
    [self.progressSlider setDoubleValue:0];
}

-(void)updateUI
{
    PlayerlList *ll = player().document.playerlList;
    PlayerTrack *track = [[ll getPlayList] getPlayItem];
    
    
    BOOL stopped = [player().engine isStopped];
    //BOOL playing = [player().engine isPlaying];
    BOOL paused = [player().engine isPaused];
    
    if (stopped)
    {
        self.window.title = player().document.windowName;
        self.progressSlider.enabled = false;
    }
    else
    {
        if (track)
        {
            NSString *title = [NSString stringWithFormat:@"%@ %@", track.info.artist, track.info.title];
            NSString *wTitle;
            if ( paused )
            {
                wTitle = [title stringByAppendingFormat:@"  (%@)", NSLocalizedString(@"Paused" ,nil) ];
            }
            else
            {
                wTitle = title;
            }
            
            self.window.title = wTitle;
            
        }
        self.progressSlider.enabled = true;
    }
    
}


-(void)dealloc
{
    removeObserver(self);
}


-(void)initCtrls
{
    [self.playOrderBtn selectItemAtIndex: player().document.playOrder ];
    
    self.progressSlider.enabled = player().document.playState != playstate_stopped;
    
    self.volumnSlider.doubleValue = player().document.volume;
}

-(void)windowDidLoad
{
    [super windowDidLoad];
    
    [self.window setFrameUsingName: uPlayerWinPos];
    [self.window setFrameAutosaveName:uPlayerWinPos];
    
}

-(void)keyDown:(NSEvent *)theEvent
{
    NSLog(@"%@",self);
//    printf("key pressed: %s\n", [[theEvent description] cString]);
}

-(void)activeSearchControl
{
    [self.window makeFirstResponder:_searchField];
    
    if (_searchKeys )
        _searchField.stringValue = _searchKeys;
    
}



-(void)clearSearchControl
{
    _searchKeys = _searchField.stringValue;
    _searchField.stringValue = @"";
    
    CGKeyCode keyCode = keyCodeFormKeyString(@"ESCAPE");
    
    
    NSEvent *event = [NSEvent keyEventWithType:NSKeyDown location:NSMakePoint(0, 0) modifierFlags:0 timestamp:[[NSProcessInfo processInfo] systemUptime] windowNumber:self.window.windowNumber context:nil characters:@"ESCAPE" charactersIgnoringModifiers:nil isARepeat:NO keyCode:keyCode];
                      
//    [[NSApplication sharedApplication] sendEvent:event];
    
    
    if([_searchField abortEditing] )
    {
        NSLog(@"123");
    }
    [self.window endEditingFor:_searchField];
    _searchField.editable = false;
    _searchField.selectable=false;
    [[_searchField window] makeFirstResponder:self];
    [_searchField abortEditing];
    _searchField.editable = true;
    _searchField.selectable = true;
    
}

@end
