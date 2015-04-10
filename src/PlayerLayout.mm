//
//  UPlayer.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayerLayout.h"








@interface PlayerLayout ()
@end

@implementation PlayerLayout

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        self.dicObjects = [NSMutableDictionary dictionary];
    }
    return self;
}



-(void)saveData:(NSData*)data withKey:(NSString*)key
{
    NSAssert(key,nil);
    self.dicObjects[key]=data;
}

-(NSData*)getDataByKey:(NSString *)key
{
    return self.dicObjects[key];
}

@end



