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
    playorder_default ,
    playorder_random ,
    playorder_repeat_single ,
    playorder_repeat_list ,
    playorder_shuffle,
    playorder_single
};

#define kPlayOrder (  @[@"default" ,@"random" ,@"repeat_single" , @"repeat_list" , @"shuffle", @"single"])


enum PlayState
{
    playstate_stopped,
    playstate_playing,
    playstate_paused,
    playstate_pending
};


struct PlayStateTime
{
    enum PlayState state;
    NSTimeInterval time;
    CGFloat volume;
};

#define docFileName  @"core.cfg"
#define layoutFileName  @"ui.cfg"
#define keyblindingFileName @"keymaps.json"
