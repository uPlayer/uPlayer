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
-(PlayerTrack*)getItem:(int)index
{
    assert(index>=0 && index < self.playerTrackList.count);
    
    return self.playerTrackList[index];
}

-(PlayerTrack*)getSelectedItem
{
    return [self getItem: _selectIndex];
}

-(size_t)count
{
    return self.playerTrackList.count;
}

@end



@implementation PlayerlList

-(PlayerList*)getItem:(int)index
{
    assert(index>=0 && index < self.playerlList.count);
    
    return self.playerlList[index];
}

-(PlayerList*)getSelectedList
{
    return [self getItem:_selectIndex];
}

-(size_t)count
{
    return self.playerlList.count;
}

@end


