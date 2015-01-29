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
    EventID_playerqueue_changed,
    EventID_to_save_config,
    EventID_to_reload_lyrics,
    EventID_to_center_item
};

NSArray *arrEvent = @[
                     @"track_started",
                      @"track_stopped",
                      @"track_paused",
                      @"track_resumed",
                      @"track_selected",
                      @"playerqueue_changed",
                      @"to_save_config",
                      @"to_reload_lyrics",
                      @"to_center_item"
                      ];


void addObserverForEvent(id observer , enum EventID et);

void removeObserverForEvent(id observer , SEL sel, enum EventID et);

void removeObserver(id observer);

void postEvent(enum EventID et , id object);

