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
#import <Cocoa/Cocoa.h>

void lastFm_loveTrack(PlayerTrack *track)
{
    __block bool success = false;
    
    dojobInBkgnd(^{
        std::string artist(track.info.artist.UTF8String);
        std::string title(track.info.title.UTF8String);
        
        LFUser *user = lastFmUser() ;
        success = track_love(user->sessionKey , artist , title);
    }, ^{
        
        NSString *title;
        if (success)
            title = NSLocalizedString(@"Love Succeed",nil);
        else
            title = NSLocalizedString(@"Love Failed",nil);
        
        
        NSUserNotification* n = [[ NSUserNotification alloc] init] ;
        n.title = title;
        n.informativeText = compressTitle(track.info);
        
       [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:n];
    });
}
