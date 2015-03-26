//
//  PlayerLastFm.m
//  uPlayer
//
//  Created by liaogang on 15/3/26.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import "PlayerLastFm.h"
#import "Last_fm_user.h"
#import "Last_fm_api.h"
#import "PlayerTrack.h"
#import "ThreadJob.h"
#import <string>


void lastFm_loveTrack(PlayerTrack *track)
{
    dojobInBkgnd(^{
        std::string artist(track.info.artist.UTF8String);
        std::string title(track.info.title.UTF8String);
        
        LFUser *user = lastFmUser() ;
        track_love(user->sessionKey , artist , title);
    }, ^{
        
        NSUserNotification* n = [[ NSUserNotification alloc] init] ;
        n.title = @" Last.Fm: Loved ";
        n.informativeText = track.info.title;
        
        NSUserNotificationCenter *c = [NSUserNotificationCenter defaultUserNotificationCenter];
        [c deliverNotification: n];
        
    });
}
