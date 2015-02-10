//
//  UPlayer.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "PlayerTrack.h"


@interface PlayerList: NSObject
@property (nonatomic,strong) NSString *name;
@property (nonatomic) int selectIndex,playIndex,topIndex;
@property (nonatomic,strong) NSMutableArray *playerTrackList;//PlayerTrack


-(PlayerTrack*)getItem:(int)index;
-(size_t)count;
-(PlayerTrack*)getSelectedItem;
-(PlayerTrack*)getPlayItem;
-(void)addItems:(NSArray*)items;
-(void)addTrackInfoItems:(NSArray*)items;
@end


/// list of player list.
@interface PlayerlList : NSObject
@property (nonatomic) int selectIndex,playIndex;
@property (nonatomic,strong) NSMutableArray *playerlList;


-(PlayerList*)getItem:(int)index;

-(void)setSelectItem:(PlayerList*)list;
-(PlayerList*)getSelectedList;
-(PlayerList*)getPlayList;
-(size_t)count;

-(PlayerList*)newPlayerList;
@end





