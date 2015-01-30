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
    
    PlayerList *list =  [lList newPlayerList];
    
    self.menuOpenDirectory.enabled=true;
}

- (IBAction)cmdOpenDirectory:(id)sender
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    [openDlg setCanChooseDirectories: YES ];
    [openDlg setAllowsMultipleSelection:NO];
    
    NSString *initPath = NSSearchPathForDirectoriesInDomains( NSMusicDirectory, NSUserDomainMask, false).firstObject;
    
    if ( [openDlg runModalForDirectory:initPath file:nil] == NSOKButton )
    {
        NSArray* files = [openDlg filenames];
        if (files.count > 0) {
            NSString* fileName = files.firstObject;
            
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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [player().document load];
    postEvent(EventID_to_reload_tracklist, nil);
    postEvent(EventID_player_document_loaded, nil);
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [player().engine stop];
    
    [player().document save];
}

@end
