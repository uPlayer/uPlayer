//
//  PlayerEngine.h
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import "PlayerTypeDefines.h"

@class PlayerTrack;
@class ProgressInfo;

@interface PlayerEngine : NSObject

///Whether or not the Player is playing not paused.
@property (nonatomic, readonly) BOOL isPlaying;

/**The volume level of the player.
 * This property is persistent.
 */
@property float volume;


// if time is -1,it will be ignored
-(BOOL)playURL:(NSURL *)url initPaused:(bool)paused time:(NSTimeInterval)time;

-(enum PlayState)getPlayState;

-(bool)isPaused;

-(bool)isPending;

-(bool)isStopped;

-(void)playPause;

-(void)seekToTime:(NSTimeInterval)time;

-(void)stop;

-(void)stop2;

/// save info and stop.
-(struct PlayStateTime)close;

@property (nonatomic,strong,readonly) ProgressInfo *progressInfo;

@end






@interface ProgressInfo : NSObject
@property (nonatomic) double current,
total;
@end


enum{
    FFT_SAMPLE_SIZE = 2048
};

@interface FFTSampleBlock : NSObject
@property (nonatomic,unsafe_unretained) Float32 *pSampleL,*pSampleR;
@end

