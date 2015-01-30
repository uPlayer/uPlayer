//
//  UPlayer.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "PlayerList.h"

@interface PlayerDocument : NSObject

/// value need to searialize.
@property (nonatomic) int resumeAtReboot;
@property (nonatomic) int volume;
@property (nonatomic) int playOrder; //enum PlayOrder
@property (nonatomic) int playStatus;//enum PlayStatus
@property (nonatomic) int fontHeight;

@property (nonatomic,strong) PlayerlList *playerlList;


/// value not need to ==>
@property (nonatomic,strong) NSString *windowName;
@property (nonatomic,strong) PlayerTrack *currPlayingTrack;
@property (nonatomic,strong) PlayerList *currPlayingList;
/// value not need to <==





@end





