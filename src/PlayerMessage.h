//
//  UPlayer.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import <Cocoa/Cocoa.h>


typedef NS_ENUM(NSInteger, EventID)
{
    EventID_track_started,
    EventID_track_stopped,
    EventID_track_paused,
    EventID_track_resumed,
    EventID_track_selected,
    EventID_track_progress_changed,
    EventID_playerqueue_changed,
    EventID_to_save_config,
    EventID_to_reload_lyrics,
    EventID_to_center_item,
    EventID_to_change_player_title
};




#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */

    
    void addObserverForEvent(id observer , SEL sel, enum EventID et);
    
    void removeObserverForEvent(id observer , SEL sel, enum EventID et);
    
    void removeObserver(id observer);
    
    void postEvent(enum EventID et , id object);
    
#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */

