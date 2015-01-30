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
@property (nonatomic) int selectIndex,topIndex;
@property (nonatomic,strong) NSMutableArray *playerTrackList;//PlayerTrack


-(PlayerTrack*)getItem:(int)index;
-(size_t)count;
-(PlayerTrack*)getSelectedItem;
-(void)addItems:(NSArray*)items;
-(void)addTrackInfoItems:(NSArray*)items;
@end


/// list of player list.
@interface PlayerlList : NSObject
@property (nonatomic) int selectIndex;
@property (nonatomic,strong) NSMutableArray *playerlList;


-(PlayerList*)getItem:(int)index;
-(PlayerList*)getSelectedList;
-(size_t)count;

-(PlayerList*)newPlayerList;
@end





