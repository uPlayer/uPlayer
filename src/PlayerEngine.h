//
//  UPlayer.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//


@interface PlayerEngine : NSObject


-(bool)isPlaying ;

-(bool)isPaused;

-(bool)isPending;

-(bool)isStopped;


- (void) playPause:(id)sender;

- (void) seekForward:(id)sender;

- (void) seekBackward:(id)sender;

- (void) seek:(id)sender;

- (void) skipToNextTrack:(id)sender;

- (BOOL) playURL:(NSURL *)url;

- (BOOL) enqueueURL:(NSURL *)url;

- (BOOL) stop;


@end

/// @todo nsprogress ?

@interface ProgressInfo : NSObject
@property (nonatomic) double current,total,fractionComplete;
@end