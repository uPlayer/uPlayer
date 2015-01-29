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
#import "PlayerEngine.h"

@interface UPlayer : NSObject
@property (nonatomic,strong) PlayerDocument *document;
@property (nonatomic,strong) PlayerLayout *layout;
@property (nonatomic,strong) PlayerEngine *engine;
@end



#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */
    
UPlayer *player(); // the global and only instance.


void playTrack(TrackInfo *track);

#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */
