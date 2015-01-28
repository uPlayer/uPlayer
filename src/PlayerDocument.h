//
//  UPlayer.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

<<<<<<< HEAD

#import <Foundation/Foundation.h>

@interface PlayerDocument : NSObject

=======
#import <Foundation/Foundation.h>

@interface PlayerDocument
>>>>>>> eb33dbd211f0a9a2aaa5c588b10c9e76795eb186
@property (nonatomic,strong) NSString *windowName;
@property (nonatomic) bool resumeAtReboot;
@property (nonatomic) int volume;
@property (nonatomic) PlayOrder playOrder;
@property (nonatomic) int playListIndex,trackIndex;
@property (nonatomic) enum PlayStatus playStatus;
@property (nonatomic) int listFontHeight,lyricsFontHeight;
<<<<<<< HEAD

@end


=======
@end
>>>>>>> eb33dbd211f0a9a2aaa5c588b10c9e76795eb186
