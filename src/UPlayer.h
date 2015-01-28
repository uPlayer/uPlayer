//
//  UPlayer.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PlayerTypeDefines.h"
<<<<<<< HEAD
#import "PlayerTrack.h"
#import "PlayerDocument.h"
#import "PlayerLayout.h"
#import "PlayerCore.h"
=======
#import "PlayerDocument.h"
#import "PlayerLayout.h"
#import "PlayerCore.h"
#import "PlayerTrack.h"
>>>>>>> eb33dbd211f0a9a2aaa5c588b10c9e76795eb186

@interface UPlayer : NSObject
@property (nonatomic,strong) PlayerDocument *document;
@property (nonatomic,strong) PlayerLayout *layout;
@property (nonatomic,strong) PlayerCore *core;
@end

<<<<<<< HEAD

UPlayer *player(); // the global and only instance.

=======
>>>>>>> eb33dbd211f0a9a2aaa5c588b10c9e76795eb186
