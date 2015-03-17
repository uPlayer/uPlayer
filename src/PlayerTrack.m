//
//  UPlayer.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//


#import "PlayerTrack.h"

#ifdef DEBUG
#import "PlayerList.h"
#endif

//static int guuid = 0;

@interface TrackInfo()
{
//    int uuid;
}
@end


@implementation TrackInfo

-(instancetype)init
{
    self = [super init];
    if (self) {
        
//        uuid = guuid++;
    }
    
    return self;
}

/// use uuid instead.
-(BOOL)isEqual:(id)object
{
    NSAssert( false, nil);
    return 0;
}

//-(int)uuid
//{
//    return uuid;
//}

@end



@implementation PlayerTrack

-(NSInteger)getIndex
{
    return [self.list getIndex:self];
}

-(instancetype)init
{
    NSAssert(false, nil);
    return nil;
}

-(instancetype)init:(PlayerList*)list
{
    self =[ super init];
    if (self) {
        self.list=list;
    }
    return self;
}

@end
