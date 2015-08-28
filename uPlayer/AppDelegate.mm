//
//  AppDelegate.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import "AppDelegate.h"
#import "UPlayer.h"
#import "PlayerTypeDefines.h"
#import "PlayerMessage.h"
#import "PlayerSerialize.h"
#import "PlayerError.h"

#import "AppPreferences.h"
#import "Last_fm_user.h"
#import "Last_fm_api.h"
#import <LLHotKey.h>
#import <LLHotKeyCenter.h>
#import <Carbon/Carbon.h>

#import "shortcutKey.h"
#import "ThreadJob.h"
#import "PlaylistViewController.h"
#import "windowController.h"
#import "PlayerLastFm.h"



@interface AppDelegate ()

@property (nonatomic,strong) NSWindowController * mainWindowController;

@property (weak) IBOutlet NSMenuItem *menuOpenDirectory;

@property (weak) IBOutlet NSMenuItem *menuPlayOrPause;

@property (nonatomic,strong) NSStatusItem *statusItem;
@end



@implementation AppDelegate
-(instancetype)init
{
    self = [super init];
    if (self) {
        
        // First init message center.
        initPlayerMessage();
        
        // Add observers
        [self addObservers];
        
        // Load ui layout
        [player().layout load];
        
        [self setUpHotkeys];
        
        
        // Load and maintain main window controller
        NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
        
        self.mainWindowController = [storyboard instantiateControllerWithIdentifier:@"IDMainWindow"];
        
        
        [self setUpStatusBar];
        
        // Load document and notify the window
        [self loadDocument];
        
        [_mainWindowController showWindow:nil];
        
    }
    
    return self;
}

-(void)addObservers
{
    addObserverForEvent(self, @selector(playerErrorHandler:), EventID_play_error_happened);
    
    addObserverForEvent(self, @selector(scrobbler:), EventID_track_started);
    
    addObserverForEvent(self , @selector(track_state_changed), EventID_track_state_changed);
    
    addObserverForEvent(self, @selector(lastFm_loveTrack:), EventID_to_love_item);
    
}

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
    
    if( [ e isStopped])
        postEvent(EventID_to_play_selected_track, nil);
    else
        postEvent(EventID_to_play_pause_resume, nil);
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
            PlayerList *list = document.playerlList.selectItem;
            
            dojobInBkgnd(
                         ^{
                             postEvent(EventID_importing_tracks_begin, nil);
                             [list  addTrackInfoItems: enumAudioFiles(fileName)];
                         } ,
                         ^{
                             postEvent(EventID_importing_tracks_end, nil);
                             postEvent(EventID_to_reload_tracklist, list);
                         });
            
        }
    }
    
}

-(void)reloadiTunesMedia
{
    PlayerList *selected = player().document.playerlList.selectItem;
    [selected removeAll];
    postEvent(EventID_to_reload_tracklist, selected);
    
    [self loadiTunesMedia];
}

- (IBAction)cmdReloadiTunesMedia:(id)sender
{
    NSString *alertSuppressionKey = @"ReloadiTunesMedia";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey: alertSuppressionKey])
    {
        [self reloadiTunesMedia];
    }
    else
    {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.alertStyle=NSWarningAlertStyle;
        alert.messageText = NSLocalizedString(@"Reload iTunes Media Source?", nil );
        alert.informativeText = NSLocalizedString(@"This will remove all tracks in current playlist first.", nil );
        [alert addButtonWithTitle:NSLocalizedString(@"OK",nil)];
        [alert addButtonWithTitle:NSLocalizedString(@"Cancel",nil)];
        alert.showsSuppressionButton = YES;
        
        if( [alert runModal] == NSAlertFirstButtonReturn)
            [self reloadiTunesMedia];
        
        if (alert.suppressionButton.state == NSOnState)
            [defaults setBool: YES forKey: alertSuppressionKey];
    }
}

- (IBAction)cmdFind:(id)sender
{
    WindowController *vc = [NSApplication sharedApplication].mainWindow.windowController;
    
    [vc activeSearchControl];
}

- (IBAction)cmdShowPlayingItem:(id)sender
{
    postEvent(EventID_to_reload_tracklist, nil);
}

- (IBAction)cmdShowPlayList:(id)sender
{
    postEvent(EventID_to_show_playlist, nil);
}

- (IBAction)cmdPrevPlaylist:(id)sender
{
    PlayerlList *llist = player().document.playerlList;
    
    PlayerList *currList = llist.selectItem;
    
    PlayerList *prevList =  [llist getPreviousItem: [llist getIndex:currList]];
    
    if(prevList)
        postEvent(EventID_to_reload_playlist, prevList);
}

- (IBAction)cmdNextPlaylist:(id)sender
{
     PlayerlList *llist = player().document.playerlList;
    
    PlayerList *currList = llist.selectItem;
    
    PlayerList *nextList =  [llist getNextItem: [llist getIndex:currList]];
    
    if(nextList)
        postEvent(EventID_to_reload_playlist, nextList);
}


#pragma mark -



-(void)hotKeyTriggered:(LLHotKey*)hotKey
{
    NSUInteger m = hotKey.modifierFlags;
    std::string s = msgKeytoString( m & NSControlKeyMask, m & NSCommandKeyMask, m & NSShiftKeyMask, m & NSAlternateKeyMask, hotKey.keyCode);
    shortcutKeyPressed( s, false);
}

-(void)setUpStatusBar
{
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    _statusItem.title = @"";
    
    _statusItem.image = [NSImage imageNamed:@"uPlayerStatus"];
    
    _statusItem.alternateImage = [NSImage imageNamed:@"uPlayerStatus"];
    
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
}

/// Register hotkeys from cache file.
-(void)setUpHotkeys
{
    verifyLoadFileShortcutKey();
    
    NSArray *hotKeys = globalHotKeysLoaded();
    
    for (LLHotKey *hotKey in hotKeys) {
        [[LLHotKeyCenter defaultCenter] addObserver:self selector:@selector(hotKeyTriggered:) hotKey:hotKey];
    }
}

-(void)loadDocument
{
    PlayerDocument *d = player().document;
    
    if( [d load] )
    {
        postEvent(EventID_to_reload_tracklist, nil);
    }
    
    postEvent(EventID_player_document_loaded, nil);
    
    player().engine.volume = player().document.volume;
    
    self.menuOpenDirectory.enabled = [d.playerlList count]>0;
}


- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
    NSMutableArray *trackInfos = [NSMutableArray array];
    for(NSString *filename in filenames)
    {
        TrackInfo *trackInfo = getId3Info( filename );
        trackInfo.path=filename;
        if(trackInfo)
            [trackInfos addObject:trackInfo];
    }
    
    
    PlayerDocument *d = player().document;
    PlayerList *list = [d.playerlList tempPlayerList];
    
    NSMutableArray *tracks = (NSMutableArray*)[list addTrackInfoItems: trackInfos];

    postEvent(EventID_to_play_item, tracks.firstObject);
    
    // add others to player queue.
    [tracks removeObjectAtIndex:0];
    
    [d.playerQueue push2:tracks];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    PlayerDocument *d = player().document;
    
    // add a default playlist if have not
    if( [d.playerlList count] == 0)
        [self cmdNewPlayerList:nil];
    
    // add ~/music to a default playerlist, if is none.
    if ( [d.playerlList count] == 1 && d.playerlList.selectItem.count == 0)
    {
        [self loadiTunesMedia];
    }
    
}

-(void)loadiTunesMedia
{
   PlayerDocument *d = player().document;
    
    NSArray *arr = NSSearchPathForDirectoriesInDomains(NSMusicDirectory, NSUserDomainMask , TRUE);
    
    NSString *userMusic = arr.firstObject;
    
    userMusic = [userMusic stringByAppendingPathComponent:@"iTunes/iTunes Media/Music"];
    
    PlayerList *list = d.playerlList.selectItem;
    
    dojobInBkgnd(
                 ^{
                     postEvent(EventID_importing_tracks_begin, nil);
                     [list  addTrackInfoItems: enumAudioFiles( userMusic )];
                 } ,
                 ^{
                     postEvent(EventID_importing_tracks_end, nil);
                     postEvent(EventID_to_reload_tracklist, list);
                 });
}

-(void)track_state_changed
{
    PlayerTrack *track = player().playing;
    
    BOOL stopped = [player().engine isStopped];
    BOOL paused = [player().engine isPaused];
    
    if (stopped)
    {
    }
    else
    {
        if (track)
        {
            NSString *title = compressTitle(track.info);
            
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

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
    [self.mainWindowController showWindow:nil];
    
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    postEvent(EventID_applicationWillTerminate, nil);
    
    collectInfo( player().document , player().engine);
    
    [player().document save];
    
    [player().layout save];
    
    saveFileShortcutKey();
}

#pragma mark -

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
    if( player().document.lastFmEnabled)
    {
        LFUser *user = lastFmUser();
        if (user->isConnected)
        {
            TrackInfo *info =  player().playing.info;
            
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
}

-(void)playerErrorHandler:(NSNotification*)n
{
    PlayerError *error = n.object;
    
    [[NSAlert alertWithError:error] runModal];
}


-(BOOL)importDirectoryEnabled
{
    return player().document.playerlList.selectItem.type != type_temporary ;
}

-(bool)lastFmEnabled
{
    return player().document.lastFmEnabled;
}

- (IBAction)cmdLastFm_Love:(id)sender
{
    postEvent(EventID_to_love_item, nil);
}

-(void)lastFm_loveTrack:(NSNotification*)n
{
    PlayerTrack *track = n.object;
    if (track == nil)
        track = player().playing;
    
    lastFm_loveTrack( track );
}

@end
