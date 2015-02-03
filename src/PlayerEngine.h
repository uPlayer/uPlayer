//
//  UPlayer.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import "PlayerTypeDefines.h"

@interface PlayerEngine : NSObject

-(bool)isPlaying ;

-(bool)isPaused;

-(bool)isPending;

-(bool)isStopped;

- (void) playPause;

- (void) seekForward;

- (void) seekBackward;

- (void) seekToPos:(id)sender;

- (void) seekToTime:(id)sender;

- (void) skipToNextTrack;

- (BOOL) playURL:(NSURL *)url;

- (BOOL) enqueueURL:(NSURL *)url;

- (BOOL) stop;


@end

/// @todo nsprogress ?

@interface ProgressInfo : NSObject
@property (nonatomic) double current,total,fractionComplete;//time
@end

