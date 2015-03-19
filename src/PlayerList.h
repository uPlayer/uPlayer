//
//  PlayerList.h
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "PlayerTrack.h"
#import "PlayerTypeDefines.h"




@interface PlayerList: NSObject
@property (nonatomic,strong) NSString *name;
@property (nonatomic) int selectIndex,playIndex,topIndex;
@property (nonatomic,strong) NSMutableArray *playerTrackList;//class PlayerTrack

@property (nonatomic) enum PlayerListType type;

-(PlayerTrack*)getItem:(NSInteger)index;
-(NSInteger)getIndex:(PlayerTrack*)track;
-(size_t)count;
-(PlayerTrack*)getSelectedItem;
-(PlayerTrack*)getPlayItem;
-(void)addItems:(NSArray*)items;

/**
 @param items: array of TrackInfo*
 @return :array of PlayerTrack *.
 */
-(NSArray*)addTrackInfoItems:(NSArray*)items;

-(void)removeTracks:(NSIndexSet*)indexs;
-(void)removeTrack:(NSInteger)index;
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

-(PlayerList*)tempPlayerList;
-(void)setTempPlayerList:(PlayerList*)list;

// return the nearest one before or after the deleted.
-(PlayerList*)deleteItem:(NSInteger)index;

@end
