//
//  UPlayer.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//


#import <Foundation/Foundation.h>


typedef NS_ENUM(int, PlayOrder)
{
    playorder_single ,
    playorder_default ,
    playorder_random ,
    playorder_repeat_single ,
    playorder_repeat_list ,
    playorder_shuffle
};



enum PlayState
{
    playstate_stopped,
    playstate_playing,
    playstate_paused,
    playstate_pending
};




