//
//  PlayerList.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//


#import "PlayerList.h"
#import "PlayerMessage.h"


@interface PlayerList()
@end


@implementation PlayerList

-(instancetype)initWithOwner:(PlayerlList*)llist
{
    self = [super init];
    if (self) {
        _llist = llist;
        _selectIndex = -1;
        _topIndex = 0;
        self.playerTrackList= [NSMutableArray array];
    }
    return self;
}

-(void)markSelected
{
    _llist.selectItem = self;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        _selectIndex = -1;
        _topIndex = 0;
        self.playerTrackList= [NSMutableArray array];
    }
    return self;
}

-(NSInteger)getIndex:(PlayerTrack*)track
{
    return [self.playerTrackList indexOfObject: track];
}

-(PlayerTrack*)getItem:(NSInteger)index
{
    assert(index>=0 && index < self.playerTrackList.count);
    
    return self.playerTrackList[index];
}

/*
-(PlayerTrack*)getSelectedItem
{
    return [self getItem: _selectIndex];
}
 */

-(size_t)count
{
    return self.playerTrackList.count;
}

-(NSArray*)addItems:(NSArray*)items
{
    int count = (int)items.count;
    if (count > 0) {
        assert( [items.firstObject isKindOfClass:[PlayerTrack class] ]);
        
        for (PlayerTrack *track in items) {
            track.list = self;
        }
        
        [self.playerTrackList addObjectsFromArray: items];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            postEvent(EventID_tracks_changed, self);
        });
        
        return items;
    }
    
    return nil;
}

-(NSArray*)addTrackInfoItems:(NSArray*)items
{
    int count = (int) items.count;
    if (count > 0)
    {
        assert( [items.firstObject isKindOfClass:[TrackInfo class] ]);
        
        NSMutableArray *arr = [NSMutableArray array];
        for (TrackInfo *info in items) {
            PlayerTrack *track = [[PlayerTrack alloc]init:self];
            track.info=info;
            [arr addObject:track];
        }
        
        [self.playerTrackList addObjectsFromArray: arr];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            postEvent(EventID_tracks_changed, self);
        });

        
        return arr;
    }
    
    return nil;
}

-(void)removeTrack:(NSInteger)index
{
    [self.playerTrackList removeObjectAtIndex:index];
    postEvent(EventID_tracks_changed, self);
}

-(void)removeTracks:(NSIndexSet*)indexs
{
    [self.playerTrackList removeObjectsAtIndexes: indexs];
    postEvent(EventID_tracks_changed, self);
}

-(NSArray*)trackAtSets:(NSIndexSet*)sets
{
    NSMutableArray *arr = [NSMutableArray array];
    [sets enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [arr addObject: [self.playerTrackList objectAtIndex:idx]];
    }];
    
    return arr;
}

-(void)removeAll
{
    self.selectIndex = -1;
    self.topIndex = -1;
    
    [self.playerTrackList removeAllObjects];
    
    postEvent(EventID_tracks_changed, self);
}

-(int)indexInParent
{
    return [self.llist.playerlList indexOfObject:self];
}

@end



@interface PlayerlList ()
@property (nonatomic,strong) PlayerList *tempPlayerlist;
@end


@implementation PlayerlList

-(instancetype)init
{
    self = [super init];
    if (self) {
//        _selectIndex = -1;
        self.playerlList = [NSMutableArray array];
    }
    return self;
}

-(PlayerList*)getItem:(int)index
{
    
    
    ///TODO ,delete
    if (index == self.playerlList.count) {
        return nil;
    }
    
    assert(index>=0 && index < self.playerlList.count);
    
    return self.playerlList[index];
}

-(NSInteger)getIndex:(PlayerList*)list
{
    return [_playerlList indexOfObject:list];
}

/*
-(void)setSelectItem:(PlayerList*)list
{
    NSUInteger index = [self.playerlList indexOfObject:list];
    if ( index == NSNotFound) {
#ifdef DEBUG
        assert(false);
#endif
    }
    else
    {
        _selectIndex = (int)index;
    }
    
}

-(PlayerList*)getSelectedList
{
    if (_selectIndex == -1)
        return nil;
    
    return [self getItem:_selectIndex];
}
*/

/*
-(PlayerList*)getPlayList
{
    if (_playIndex == -1)
        return nil;
    
    return [self getItem:_playIndex];
}*/

-(size_t)count
{
    return self.playerlList.count;
}

-(PlayerList*)newPlayerListWithName:(NSString*)name
{
    PlayerList *list = [[PlayerList alloc]initWithOwner:self];
    list.name = name;
    [self.playerlList addObject:list];
//    _selectIndex = (int)self.playerlList.count-1;
    
    postEvent(EventID_list_changed, nil);
    
    return list;
}

-(PlayerList*)newPlayerList
{
    return [self newPlayerListWithName:@"unnamed playlist"];
}

-(PlayerList*)tempPlayerList
{
    if (!_tempPlayerlist)
    {
        self.tempPlayerlist = [self newPlayerListWithName:@"temporary playlist"];
        _tempPlayerlist.type = type_temporary;
    }
    
    return _tempPlayerlist;
}

-(void)setTempPlayerList:(PlayerList*)list
{
    self.tempPlayerlist = list;
    list.type = type_temporary;
}

-(PlayerList*)deleteItem:(NSInteger)index
{
    NSInteger count = self.playerlList.count;
    
    if(count == 1)
    {
        NSAssert( index == 0, @"");
        [self.playerlList removeObjectAtIndex:0];
        return nil;
    }
    else
    {
        NSAssert(-1 < index && index < count, @"index beyond ..");
        [self.playerlList removeObjectAtIndex:index];
        
        NSInteger r = index == count - 1? index - 1 : index;
        
        return [self getItem:(int)r];
    }
}

-(PlayerList*)getPreviousItem:(NSInteger)index
{
    NSInteger count = self.playerlList.count;
    if(count == 1)
        return nil;
    
    NSInteger prev = index - 1;
    if (prev == -1) {
        prev = count - 1;
    }
    
    return [self getItem:(int)prev];
}

-(PlayerList*)getNextItem:(NSInteger)index
{
    NSInteger count = self.playerlList.count;
    if(count == 1)
        return nil;
    
    NSInteger prev = index + 1;
    if (prev == count) {
        prev = 0;
    }
    
    return [self getItem:(int)prev];
}

@end
