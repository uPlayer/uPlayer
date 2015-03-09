//
//  UPlayer.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//


#import "PlayerList.h"

@interface PlayerList()

@end


@implementation PlayerList

-(instancetype)init
{
    self = [super init];
    if (self) {
        _selectIndex = -1;
        _playIndex = -1;
        _topIndex = 0;
        self.playerTrackList= [NSMutableArray array];
    }
    return self;
}

-(PlayerTrack*)getItem:(NSInteger)index
{
    assert(index>=0 && index < self.playerTrackList.count);
    
    return self.playerTrackList[index];
}

-(PlayerTrack*)getSelectedItem
{
    return [self getItem: _selectIndex];
}

-(PlayerTrack*)getPlayItem
{
    if (_playIndex == -1)
        return nil;
    
    return [self getItem:_playIndex];
}

-(size_t)count
{
    return self.playerTrackList.count;
}

-(void)addItems:(NSArray*)items
{
    int count = (int)items.count;
    if (count > 0) {
        assert( [items.firstObject isKindOfClass:[PlayerTrack class] ]);
        
        
        int index = (int) self.playerTrackList.count;
        
        for (PlayerTrack *track in items) {
            track.index=index;
            index++;
        }
        
        [self.playerTrackList addObjectsFromArray: items];
    }
}

-(void)addTrackInfoItems:(NSArray*)items
{
     int count = (int) items.count;
    if (count > 0) {
        assert( [items.firstObject isKindOfClass:[TrackInfo class] ]);
         int index = (int)self.playerTrackList.count;
        
        NSMutableArray *arr = [NSMutableArray array];
        for (TrackInfo *info in items) {
            PlayerTrack *track = [[PlayerTrack alloc]init:self];
            track.info=info;
            track.index=index;
            [arr addObject:track];
            index++;
        }
        
        [self.playerTrackList addObjectsFromArray: arr];
        
    }
}
@end



@implementation PlayerlList

-(instancetype)init
{
    self = [super init];
    if (self) {
        _selectIndex = -1;
        self.playerlList = [NSMutableArray array];
    }
    return self;
}

-(PlayerList*)getItem:(int)index
{
    assert(index>=0 && index < self.playerlList.count);
    
    return self.playerlList[index];
}

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

-(PlayerList*)getPlayList
{
    if (_playIndex == -1)
        return nil;
    
    return [self getItem:_playIndex];
}

-(size_t)count
{
    return self.playerlList.count;
}

-(PlayerList*)newPlayerList
{
    PlayerList *list = [[PlayerList alloc]init];
    list.name=@"unnamed playerlist";
    [self.playerlList addObject:list];
    _selectIndex = (int)self.playerlList.count-1;
    return list;
}

@end
