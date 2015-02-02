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

@interface AppDelegate ()
@property (weak) IBOutlet NSMenuItem *menuOpenDirectory;

@end



@implementation AppDelegate


- (IBAction)showPreferences:(id)sender {
    [NSPreferences setDefaultPreferencesClass:[AppPreferences class] ];
    
	[[NSPreferences sharedPreferences] showPreferencesPanel];
}

- (IBAction)cmdNewPlayerList:(id)sender {

    //NSPreferences *pre;
    
    PlayerDocument *document = player().document;
    PlayerlList *lList = document.playerlList;
    
    [lList newPlayerList];
    
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
            
            [list  addTrackInfoItems: enumAudioFiles(fileName)];
            
            postEvent(EventID_to_reload_tracklist, nil);
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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    if( [player().document load] )
    {
        postEvent(EventID_to_reload_tracklist, nil);
        postEvent(EventID_player_document_loaded, nil);
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [player().engine stop];
    
    [player().document save];
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return TRUE;
}

@end
