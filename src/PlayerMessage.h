//
//  UPlayer.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum : NSUInteger {
    EventID_track_started = 0,
    EventID_track_stopped ,
    EventID_track_paused ,
    EventID_track_resumed ,
    
    EventID_track_state_changed,
    
    EventID_track_selected ,
    EventID_track_progress_changed ,
    EventID_playerqueue_changed ,
    EventID_player_document_loaded , // 使配置生效
    
    /// param: PlayerList* list , if list is nil , then go to the playing item.
    /// else reload the list at list.topitem. and list is selected.
    EventID_to_reload_tracklist ,
    EventID_to_save_config,
    EventID_to_reload_lyrics,
    EventID_to_center_item,
    EventID_to_play_selected_track,
    EventID_to_show_playlist,
    
    EventID_to_play_pause_resume,
    EventID_to_stop,
    EventID_track_stopped_playnext , // play next by track ended.
    EventID_to_play_next // play next by user
} EventID;





#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */

    
    void addObserverForEvent(id observer , SEL sel, EventID et);
    
    void removeObserverForEvent(id observer , SEL sel, EventID et);
    
    void removeObserver(id observer);
    
    void postEvent(EventID et , id object);
    
#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */

