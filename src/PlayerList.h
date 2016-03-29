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

@class PlayerlList;


@interface PlayerList: NSObject <NSCoding>

@property (nonatomic,strong) NSString *name;

@property (nonatomic) int selectIndex,topIndex;

@property (nonatomic,strong) NSMutableArray<PlayerTrack*> *playerTrackList;//class PlayerTrack

@property (nonatomic) enum PlayerListType type;


//index in file arrays saved
@property (nonatomic) int fileIndex;

//
-(instancetype)initWithOwner:(PlayerlList*)llist;
@property (nonatomic) PlayerlList *llist;
-(void)markSelected;
-(int)indexInParent;



-(PlayerTrack*)getItem:(NSInteger)index;
-(NSInteger)getIndex:(PlayerTrack*)track;
-(size_t)count;
//-(PlayerTrack*)getSelectedItem;
//-(PlayerTrack*)getPlayItem;
-(NSArray*)addItems:(NSArray*)items;

/**
 @param items: array of TrackInfo*
 @return :array of PlayerTrack *.
 */
-(NSArray*)addTrackInfoItems:(NSArray*)items;
-(NSArray*)trackAtSets:(NSIndexSet*)sets;
-(void)removeTracks:(NSIndexSet*)indexs;
-(void)removeTrack:(NSInteger)index;
-(void)removeAll;
@end









/// list of player list.
@interface PlayerlList : NSObject <NSCoding>

/// use selectItem at application's runtime. selectIndex when serialize.
@property (nonatomic) int selectIndex;
-(void)setSelectItem:(PlayerList*)list;
-(const PlayerList*)getSelectedItem;

@property (nonatomic,strong) NSMutableArray *playerlList;

-(PlayerList*)getItem:(int)index;

-(NSInteger)getIndex:(PlayerList*)list;



-(size_t)count;

-(PlayerList*)newPlayerList;

-(PlayerList*)tempPlayerList;
-(void)setTempPlayerList:(PlayerList*)list;

// return the nearest one before or after the deleted.
-(PlayerList*)deleteItem:(NSInteger)index;

-(PlayerList*)getPreviousItem:(NSInteger)index;
-(PlayerList*)getNextItem:(NSInteger)index;

@end

@interface PlayerlList (documentLoaded)
-(void)willSave;

-(void)didLoad;
@end
