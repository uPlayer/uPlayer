//
//  UPlayer.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef NS_OPTIONS(int, PlayOrder)
{
    playorder_single = 0,
    playorder_default = 1,
    playorder_random = 2,
    playorder_repeat_single = 4,
    playorder_repeat_list = 8,
    playorder_shuffle = 16
};


enum PlayStatus
{
    playstatus_stopped,
    playstatus_playing,
    playstatus_paused
};




