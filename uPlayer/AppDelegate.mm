//
//  AppDelegate.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import "AppDelegate.h"
#import "UPlayer.h"
#import "PlayerMessage.h"
#import "PlayerSerialize.h"
#import "AppPreferences.h"
#include "Last_fm_user.h"
#include "Last_fm_api.h"
#import <LLHotKey.h>
#import <LLHotKeyCenter.h>
#import <Carbon/Carbon.h>

#import "shortcutKey.h"
#import "ThreadJob.h"
#import "PlaylistViewController.h"
#import "PlayerTypeDefines.h"

@interface AppDelegate ()
@property (weak) IBOutlet NSMenuItem *menuOpenDirectory;
@property (weak) IBOutlet NSMenuItem *menuPlayOrPause;

@property (nonatomic,strong) NSStatusItem *statusItem;
@end



@implementation AppDelegate
- (IBAction)cmdRandom:(id)sender {
    postEvent(EventID_to_play_random, nil);
    postEvent(EventID_to_reload_tracklist, nil);
}

- (IBAction)cmdNext:(id)sender {
        postEvent(EventID_to_play_next, nil);
        postEvent(EventID_to_reload_tracklist, nil);
}

- (IBAction)cmdStop:(id)sender {
        postEvent(EventID_to_stop, nil);
}

- (IBAction)cmdOpenKeyBlindings:(id)sender
{
    NSArray *urlArr = [NSArray arrayWithObject: [NSURL fileURLWithPath:  [ApplicationSupportDirectory() stringByAppendingPathComponent: keyblindingFileName ]] ];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs: urlArr ];
}

- (IBAction)cmdPlayPause:(id)sender {
    
    PlayerEngine *e = player().engine;
    
    bool isPaused =  [e isPaused];
    
    if( [ e isStopped])
        postEvent(EventID_to_play_selected_track, nil);
    else
        postEvent(EventID_to_play_pause_resume, nil);
    
    
    NSMenuItem *item = (NSMenuItem *)sender;
    item.title =   NSLocalizedString( (isPaused ?@"Pause" :@"Play") , nil);
}


- (IBAction)showPreferences:(id)sender {
    [NSPreferences setDefaultPreferencesClass:[AppPreferences class] ];
    
	[[NSPreferences sharedPreferences] showPreferencesPanel];
}

- (IBAction)cmdNewPlayerList:(id)sender {
    
    PlayerDocument *document = player().document;
    PlayerlList *lList = document.playerlList;
    
    PlayerList *list = [lList newPlayerList];
    
    postEvent(EventID_to_reload_tracklist, list );
    
    self.menuOpenDirectory.enabled=true;
}

- (IBAction)cmdOpenDirectory:(id)sender
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    [openDlg setCanChooseDirectories: YES ];
    [openDlg setAllowsMultipleSelection:NO];
    
    NSString *initPath = NSSearchPathForDirectoriesInDomains( NSMusicDirectory, NSUserDomainMask, true ).firstObject;
    
    openDlg.directoryURL = [NSURL fileURLWithPath: initPath];
    
    if ( [openDlg runModal] == NSModalResponseOK)
    {
        NSArray* files = [openDlg URLs];
        if (files.count > 0) {
            
            NSString* fileName =[(NSURL*)(files.firstObject) path];
            
            PlayerDocument *document = player().document;
            PlayerList *list = [document.playerlList getSelectedList];
            
            dojobInBkgnd(
                         ^{
                             [list  addTrackInfoItems: enumAudioFiles(fileName)];
                         } ,
                         ^{
                             postEvent(EventID_to_reload_tracklist, list);
                         });
            
        }
    }
    
}

- (IBAction)cmdFind:(id)sender
{
    NSLog(@"command: Find");
}

- (IBAction)cmdShowPlayingItem:(id)sender
{
    postEvent(EventID_to_reload_tracklist, nil);
}

- (IBAction)cmdShowPlayList:(id)sender
{
    postEvent(EventID_to_show_playlist, nil);
}

#pragma mark -



-(void)hotKeyTriggered:(LLHotKey*)hotKey
{
    NSUInteger m = hotKey.modifierFlags;
    std::string s = msgKeytoString( m & NSControlKeyMask, m & NSCommandKeyMask, m & NSShiftKeyMask, m & NSAlternateKeyMask, hotKey.keyCode);
    shortcutKeyPressed( s, false);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // set up status bar
    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    _statusItem.title = @"";
    
    _statusItem.image = [NSImage imageNamed:@"player"];
    
    _statusItem.alternateImage = [NSImage imageNamed:@"player"];
    
    _statusItem.highlightMode = YES;
    
    NSArray *array;
    if ([[NSBundle mainBundle]  loadNibNamed:@"StatusMenu" owner:self topLevelObjects:&array] )
    {
        for (id arrItem in array)
        {
            if ([arrItem isKindOfClass:[NSMenu class]])
            {
                NSMenu *menu = arrItem;
                NSAssert([menu isKindOfClass:[NSMenu class]], @"not menu");
                [_statusItem setMenu: menu];
                break;
            }
        }
    }
    
    // add observers
    addObserverForEvent(self, @selector(scrobbler:), EventID_track_started);
    
    addObserverForEvent(self , @selector(track_state_changed), EventID_track_state_changed);
    
    // locad config files.
    PlayerDocument *d = player().document;
    
    if( [d load] )
    {
        postEvent(EventID_to_reload_tracklist, nil);
    }
    
    postEvent(EventID_player_document_loaded, nil);
    
    player().engine.volume = player().document.volume;
    
    self.menuOpenDirectory.enabled = [d.playerlList count]>0;
    
    if( [player().engine isPlaying] )
        self.menuPlayOrPause.title =NSLocalizedString(@"Pause" ,nil);
    else
        self.menuPlayOrPause.title = NSLocalizedString(@"Play",nil);
    
    
    // register hotkeys from cache file.
    verifyLoadFileShortcutKey();
    
    NSArray *hotKeys = globalHotKeysLoaded();
    
    for (LLHotKey *hotKey in hotKeys) {
        [[LLHotKeyCenter defaultCenter] addObserver:self selector:@selector(hotKeyTriggered:) hotKey:hotKey];
    }
    
    // add ~/music to a default playerlist, if is none.
    if ([d.playerlList count] == 0)
    {
        NSArray *arr = NSSearchPathForDirectoriesInDomains(NSMusicDirectory, NSUserDomainMask , TRUE);
        
        NSString *userMusic = arr.firstObject;
        
        [self cmdNewPlayerList:nil];
        
        PlayerList *list = [d.playerlList getSelectedList];
        
        dojobInBkgnd(
                     ^{
                         [list  addTrackInfoItems: enumAudioFiles( userMusic )];
                     } ,
                     ^{
                         postEvent(EventID_to_reload_tracklist, list);
                     });
        
        
    }
    
    
    

    
    

    
    
}


-(void)track_state_changed
{
    PlayerlList *ll = player().document.playerlList;
    PlayerTrack *track = [[ll getPlayList] getPlayItem];
    
    
    BOOL stopped = [player().engine isStopped];
    //BOOL playing = [player().engine isPlaying];
    BOOL paused = [player().engine isPaused];
    
    if (stopped)
    {
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
            
            [[_statusItem.menu itemAtIndex:0] setTitle:wTitle];
            
        }
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    collectInfo( player().document , player().engine);
    
    [player().document save];
    
    saveFileShortcutKey();
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

-(void)scrobblerSong:(TrackInfo*)info
{
    dojobInBkgnd(^{
        string artist(info.artist.UTF8String);
        string track(info.title.UTF8String);
        
        LFUser *user = lastFmUser() ;
        if (track_scrobble(user->sessionKey, artist, track) )
        {
            
        }
        
    },nil);
}

-(void)scrobbler:(NSNotification*)n
{
    LFUser *user = lastFmUser();
    if (user->isConnected)
    {
        TrackInfo *info = [[player().document.playerlList getPlayList] getPlayItem].info;
        
        dojobInBkgnd(^{
            string artist(info.artist.UTF8String);
            string track(info.title.UTF8String);
            track_updateNowPlaying(user->sessionKey, artist, track);
        }, nil);
        
        // scrobble a song when played half time of above 40 seconds.
        ProgressInfo *progress= n.object;
        NSAssert([progress isKindOfClass:[ProgressInfo class]], nil);
        NSTimeInterval t = progress.total;
        if (t > 40)
            t = 40;
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        
        [self performSelector:@selector(scrobblerSong:) withObject:info afterDelay:t];
        
    }
    
}

@end
