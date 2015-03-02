//
//  PlayerQueue.h
//  uPlayer
//
//  Created by liaogang on 15/3/2.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayerTrack.h"

@interface PlayerQueue : NSObject

-(PlayerTrack*)pop;

-(void)push:(PlayerTrack*)item;

-(void)remove:(PlayerTrack*)item;

-(void)clear;

-(NSArray*)getIndex:(PlayerTrack*)item;

@end
