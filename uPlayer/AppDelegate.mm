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
#import "serialize.h"

#import "AppPreferences.h"

typedef void (^JobBlock)();
typedef void (^JobBlockDone)();
void dojobInBkgnd(JobBlock job ,JobBlockDone done)
{
    dispatch_queue_t  _dispatchQueue  = dispatch_queue_create("KxSMBProvider", DISPATCH_QUEUE_SERIAL);
    dispatch_async(_dispatchQueue, ^{
        job();
        dispatch_async(dispatch_get_main_queue(), ^{
            done();
        });
    });
    
}




@interface AppDelegate ()
@property (weak) IBOutlet NSMenuItem *menuOpenDirectory;
@property (weak) IBOutlet NSMenuItem *menuPlayOrPause;

@end



@implementation AppDelegate
- (IBAction)cmdStop:(id)sender {
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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    PlayerDocument *d = player().document;
    
    if( [d load] )
    {
        postEvent(EventID_to_reload_tracklist, nil);
        postEvent(EventID_player_document_loaded, nil);
    }
    
    
    self.menuOpenDirectory.enabled = [d.playerlList count]>0;
    if( [player().engine isPlaying]  )
        self.menuPlayOrPause.title =NSLocalizedString( @"Pause" ,nil );
    else
        self.menuPlayOrPause.title = NSLocalizedString( @"Play",nil);
    
    
    if ([d.playerlList count] == 0)
    {
        ///
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



- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    collectInfo( player().document , player().engine);
    
    
    
    
    
    
    
    
    
    
    
    [player().document save];
    
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return TRUE;
}

@end
