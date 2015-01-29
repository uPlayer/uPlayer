//
//  UPlayer.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface PlayerDocument : NSObject
@property (nonatomic,strong) NSString *windowName;
@property (nonatomic) bool resumeAtReboot;
@property (nonatomic) int volume;
@property (nonatomic) PlayOrder playOrder;
@property (nonatomic) int playListIndex,trackIndex;
@property (nonatomic) enum PlayStatus playStatus;
@property (nonatomic) int listFontHeight,lyricsFontHeight;

@property (nonatomic,strong) NSArray *trackInfoList;
@end





