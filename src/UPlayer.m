//
//  UPlayer.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

<<<<<<< HEAD
#import "UPlayer.h"






@implementation UPlayer

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        self.document = [[PlayerDocument alloc ] init];
        self.layout= [[PlayerLayout alloc] init];
        self.core = [[PlayerCore alloc] init];
        
    }
    return self;
}

@end




static UPlayer *_player ; 

UPlayer *player()
{
    return _player?_player:(_player=[[UPlayer alloc]init]);
}

=======
#import <Foundation/Foundation.h>
>>>>>>> eb33dbd211f0a9a2aaa5c588b10c9e76795eb186
