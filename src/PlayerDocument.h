//
//  UPlayer.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "PlayerList.h"
#import "PlayerQueue.h"

@interface PlayerDocument : NSObject

/// value need to searialize.
@property (nonatomic) int resumeAtReboot;
@property (nonatomic) int trackSongsWhenPlayStarted; //track song when playing changed autoly. 
@property (nonatomic) float volume;
@property (nonatomic) int playOrder,//enum PlayOrder
playState,//enum PlayStatus
fontHeight,
lastFmEnabled;

@property (nonatomic) int playingIndexList,playingIndexTrack;


@property (nonatomic) NSTimeInterval playTime;




@property (nonatomic,strong) PlayerQueue *playerQueue;
@property (nonatomic,strong) PlayerlList *playerlList;

@property (nonatomic,strong) NSString *windowName;


@end


@interface PlayerDocument (documentLoaded)
-(void)didLoad;
-(void)willSave;
@end
