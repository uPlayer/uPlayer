//
//  UPlayer.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import "PlayerMessage.h"

#import <AVFoundation/AVFoundation.h>

const char *arrEvent[] =
{
    "track_started",
    "track_stopped",
    "track_stopped_playnext",
    "track_paused",
    "track_resumed",
    "track_selected",
    "track_progress_changed",
    "playerqueue_changed",
    "player_document_loaded",
    "to_reload_tracklist",
    "to_save_config",
    "to_reload_lyrics",
    "to_center_item",
    "to_change_player_title",
    "to_play_selected_track",
    "to_stop",
    "to_play"
};


NSString *eventIDtoString(EventID et)
{
    return [NSString stringWithUTF8String: arrEvent[et]];
}


void addObserverForEvent(id observer , SEL sel, EventID et)
{
    NSNotificationCenter *d =[NSNotificationCenter defaultCenter];
    
    [d addObserver:observer selector:sel name: eventIDtoString(et) object:nil];
}

void removeObserverForEvent(id observer , SEL sel, EventID et)
{
    NSNotificationCenter *d =[NSNotificationCenter defaultCenter];
    [d removeObserver:observer name:eventIDtoString(et) object:nil];
}

void removeObserver(id observer)
{
    NSNotificationCenter *d =[NSNotificationCenter defaultCenter];
    [d removeObserver:observer];
}


void postEvent(EventID et , id object)
{
    NSNotificationCenter *d =[NSNotificationCenter defaultCenter];

//    NSLog(@"%d: ",(int)et);
//    NSString *a = eventIDtoString(et);
//    NSLog(@"%@",a);
    
    [d postNotificationName: eventIDtoString(et) object:object];
    
}
