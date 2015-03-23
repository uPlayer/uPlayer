//
//  GeneralPreferences.m
//  PrefsTest
//
//  Created by Dave Jewell on 13/12/2007.
//  Copyright 2007 Dave Jewell. All rights reserved.
//

#import "AccountPreferences.h"
#import "UPlayer.h"
#import "Last_fm_user.h"
#import "Last_fm_api.h"
#import "ThreadJob.h"

@interface AccountPreferences ()
@property (weak) IBOutlet NSButton *btnConnect;
@property (weak) IBOutlet NSTextField *labelLastFmName;
@property (weak) IBOutlet NSButton *lastFmEnabled;
@property (weak) IBOutlet NSImageView *imageLastFm;
@property (weak) IBOutlet NSTextField *descriptionLastFm;

@property (assign) LFUser *user;
@end

@implementation AccountPreferences
-(void)awakeFromNib
{
    _user = lastFmUser();
    
    [self update: player().document.lastFmEnabled];
    
    player(); // initLasfFm
    
    [self updateUIUser: _user ];
}

-(void)update:(BOOL)enabled
{
    self.lastFmEnabled.state = enabled?NSOnState:NSOffState;
    self.imageLastFm.enabled = enabled;
    self.descriptionLastFm.enabled = enabled;
    self.labelLastFmName.hidden = !enabled;
    self.btnConnect.hidden = !enabled;
}

-(void)updateUIUser:(LFUser*)user
{
    if (user->isConnected)
    {
        self.labelLastFmName.stringValue = [NSString stringWithUTF8String: user->name.c_str()];
        self.btnConnect.title = NSLocalizedString(@"disconnect",nil);
    }
    else
    {
        self.labelLastFmName.stringValue =  @"";
        self.btnConnect.title = NSLocalizedString(@"connect", nil);
    }
    
}

-(BOOL)isResizable
{
	return NO;
}

- (IBAction)actionEnableLastFm:(id)sender
{
    int enabled = (self.lastFmEnabled.state == NSOnState);
    
    player().document.lastFmEnabled = enabled;
    
    [self update: enabled];
}

- (IBAction)actionConnect:(id)sender
{
    if (_user->isConnected)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        
        [alert addButtonWithTitle: NSLocalizedString(@"OK",nil) ];
        
        [alert addButtonWithTitle: NSLocalizedString(@"Cancel",nil) ];
        
        [alert setMessageText: NSLocalizedString(@"Disconnect the session?",nil ) ];
        
        [alert setInformativeText: NSLocalizedString(@"The session connection needs login in on web browser.",nil) ];
        
        [alert setAlertStyle:NSWarningAlertStyle];
        
        if ([alert runModal] == NSAlertFirstButtonReturn)
        {
            clearSession(* _user );
            
            [self updateUIUser: _user];
        }
        
        
    }
    else
    {
        NSAlert *alert = [[NSAlert alloc]init];
        [alert setMessageText: NSLocalizedString(@"uPlayer is 'Waiting' for your authorization",nil ) ];
        [alert setInformativeText: NSLocalizedString(@"Switch to the web instanse just opened and login in to allow uPlayer for scrobbling songs",nil) ];
        [alert addButtonWithTitle: NSLocalizedString(@"Abort", nil)];
        
        __block bool stopAuth = false;
        
        dojobInBkgnd(^{
            
            if (auth( *_user , true , stopAuth ) )
            {
                
            }
            
        } , ^{
            // Close the Alert...
            NSPanel *panel = alert.window;
            [panel orderOut:nil];
            [panel close];
            [NSApp endSheet: panel];
            
            [self updateUIUser: _user];
        });
        
        if ([alert runModal] == NSAlertFirstButtonReturn)
        {
            stopAuth = true;
            
            [self updateUIUser: _user];
        }
        
    }
    
    
}

@end
