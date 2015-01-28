//
//  UPlayer.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PlayerTypeDefines.h"
#import "PlayerTrack.h"
#import "PlayerDocument.h"
#import "PlayerLayout.h"
#import "PlayerCore.h"


@interface UPlayer : NSObject
@property (nonatomic,strong) PlayerDocument *document;
@property (nonatomic,strong) PlayerLayout *layout;
@property (nonatomic,strong) PlayerCore *core;
@end


UPlayer *player(); // the global and only instance.


