//
//  UPlayer.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "PlayerSerachMng.h"

@implementation PlayerSearchMng

-(void)search:(NSString *)key
{
    assert(self.playerlistOriginal);
    
    //search title first.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.title contains[c] %@",key,key,key];
    
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"SELF.artist contains[c] %@ ||SELF.album contains[c] %@",key,key,key];
    
    NSArray *dataOld = [_playerlistOriginal.playerTrackList copy];
    
    NSArray *dataNew ;
    dataNew = [dataOld filteredArrayUsingPredicate:predicate];
    
    dataNew = [ dataNew arrayByAddingObjectsFromArray:[dataOld filteredArrayUsingPredicate: predicate2]];
    
    
    int i = 0;
    for (PlayerTrack *track in dataNew)
    {
        NSNumber *numNew = [NSNumber numberWithInt:i];
        
        self.dicFilterToOrginal[numNew] = track;
        i++;
    }
    
    _playerlistFilter.playerTrackList = dataNew;
    
}

-(PlayerTrack*)getOrginalByIndex:(int)index
{
    NSNumber *numNew = [NSNumber numberWithInt:index];
    return (PlayerTrack*) self.dicFilterToOrginal[numNew];
}

@end


