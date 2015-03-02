//
//  PlayerQueue.m
//  uPlayer
//
//  Created by liaogang on 15/3/2.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import "PlayerQueue.h"

@interface PlayerQueue ()
@property (nonatomic,strong) NSMutableArray *queue;
@end

@implementation PlayerQueue

-(instancetype)init
{
    self = [super init];
    if (self) {
        _queue = [NSMutableArray array];
    }
    return self;
}

-(PlayerTrack*)pop
{
    if (_queue.count>0) {
        PlayerTrack* first = _queue.firstObject;
        [_queue removeObjectAtIndex:0 ];
        return first;
    }
    
    return nil;
}

-(void)push:(PlayerTrack*)item
{
    [_queue addObject:item];
}

-(void)remove:(PlayerTrack*)item
{
    [_queue removeObject:item];
}

-(void)clear
{
    [_queue removeAllObjects];
}

-(NSArray*)getIndex:(PlayerTrack*)item
{
    NSAssert(false,nil);
    
    return nil;
}

@end
