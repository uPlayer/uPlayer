//
//  UPlayer.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import "UPlayer.h"
#include "Last_fm_user.h"
#include "Last_fm_api.h"
#import "ThreadJob.h"
#import "PlayerMessage.h"
#import "PlayerSerialize.h"

void initLastFm()
{
    NSString *usrSessionPath = [ApplicationSupportDirectory() stringByAppendingPathComponent:@"lastFmUser.session"];
    
    setUserProfilePath(usrSessionPath.UTF8String );
    
    setLastFmApiKey("855aed416969f546b9dd6e1a0f6c483d");
    setLastFmSecret("f87866e88029b55d2eb06de561553c8d");
    
    
    // Load Last.fm session locally
    authLocal(* lastFmUser()  );
}

@interface UPlayer ()
@end


@implementation UPlayer

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        self.document = [[PlayerDocument alloc ] init];
        self.layout= [[PlayerLayout alloc] init];
        self.engine= [[PlayerEngine alloc] init];
       
        initLastFm();
        
        addObserverForEvent(self, @selector(cmdSavePlaylist), EventID_list_changed);
        
        addObserverForEvent(self, @selector(cmdSavePlaylist), EventID_tracks_changed);
        
        addObserverForEvent(self, @selector(cmdSavePlaylist), EventID_list_name_changed);
        
        addObserverForEvent(self, @selector(cmdSaveConfig), EventID_to_save_config);
        addObserverForEvent(self, @selector(cmdSavePlaylist), EventID_to_save_playlist);
        addObserverForEvent(self, @selector(cmdSaveUILayout), EventID_to_save_ui_layout);
        
        
        
    }
    return self;
}




-(void)cmdSaveConfig
{
    NSLog(@"cmdSaveConfig");
    [self.document saveConfig];
}

-(void)cmdSavePlaylist
{
    [self.document savePlaylist];
}

-(void)cmdSaveUILayout
{
    [self.layout save];
}

@end




static UPlayer *_player ; 

UPlayer *player()
{
    return _player?_player:(_player=[[UPlayer alloc]init]);
}
