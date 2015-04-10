//
//  UPlayer.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//





@protocol PlayerLayout <NSObject>

-(void)saveTo:(FILE*)file;

-(void)loadFrom:(FILE*)file;

@end



@interface PlayerLayout :NSObject

@property (nonatomic,strong) NSMutableDictionary *dicObjects;

-(void)saveData:(NSData*)data withKey:(NSString*)key;

-(NSData*)getDataByKey:(NSString *)key;

@end

