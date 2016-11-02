//
//  PlayerEngine.mm
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "PlayerEngine.h"
#import "PlayerMessage.h"
#import "PlayerTypeDefines.h"
#import "UPlayer.h"

static void *ObservationContext_Rate = &ObservationContext_Rate;
static void *ObservationContext_Duration = &ObservationContext_Duration;
static void *ObservationContext_Status = &ObservationContext_Status;


const NSTimeInterval timeInterval = 0.2;

@interface PlayerEngine ()
{
    PlayState _state;
    BOOL firstLoaded;
    int justSeeked;
}

@property (nonatomic,strong) AVAudioEngine  *audioEngine;
@property (nonatomic,strong) AVAudioPlayerNode  *audioFilePlayer;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic, readonly) double sampleRate;
@end

@implementation PlayerEngine

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        
        _audioEngine = [AVAudioEngine new];
        _audioFilePlayer = [AVAudioPlayerNode new];
        [_audioEngine attachNode:_audioFilePlayer];
        
        firstLoaded = true;
        _state = playstate_stopped;
        _progressInfo = [ProgressInfo new];

        
        addObserverForEvent(self, @selector(playNext), EventID_track_stopped_playnext);
        
        addObserverForEvent(self, @selector(actionPlayNext), EventID_to_play_next);
        
        addObserverForEvent(self, @selector(needResumePlayAtBoot), EventID_player_document_loaded);
       
        addObserverForEvent(self, @selector(stop), EventID_to_stop);
        
        addObserverForEvent(self, @selector(playPause), EventID_to_play_pause_resume);
        
        addObserverForEvent(self, @selector(actionPlayRandom), EventID_to_play_random);
        
        [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(timerComing) userInfo:nil repeats:YES];
        
    }
    
    return self;
}
    
-(void)timerComing
{
    if (justSeeked > 0)
    {
        justSeeked-=1;
    }
    else
    {
        if ( _state == playstate_playing )
        {
            _progressInfo.current += timeInterval;
            postEvent(EventID_track_progress_changed, _progressInfo);
        }
    }
    
}
    
-(void)needResumePlayAtBoot
{
    PlayerDocument *doc = player().document;
    if (doc.resumeAtReboot && doc.playState != playstate_stopped )
    {
        PlayerTrack *track = Playing();
        PlayerList *list = track.list;
        
        if ( doc.playState == playstate_playing )
        {
            playTrack( track );
        }
        else
        {
            playTrackPauseAfterInit( list, track , doc.playTime);
        }
        
    }
}


-(void)DidPlayToEndTime:(NSNotification*)n
{
    postEvent(EventID_track_stopped_playnext, nil);
    
    if( player().document.trackSongsWhenPlayStarted)
        postEvent(EventID_to_reload_tracklist, Playing());
}

// action by user.
-(void)actionPlayNext
{
    [self playNext];
    PlayerTrack *track = Playing();
    postEvent(EventID_to_reload_tracklist, track );
}

-(void)playNext
{
    PlayerDocument *d = player().document;
    PlayerQueue *queue = d.playerQueue;
    
    PlayerTrack *trackQueue = [queue pop] ;
    if ( trackQueue )
    {
        playTrack(trackQueue);
    }
    else
    {
        PlayerTrack *track = Playing();
        PlayerList *list = track.list;
        
        assert(list);
        
        int index = (int)track.index;
        int count = (int)[list count];
        if(count > 0)
        {
            int indexNext =-1;
            PlayOrder order = (PlayOrder)d.playOrder;
            
            if (order == playorder_single) {
                [self stop];
            }
            else if (order == playorder_default)
            {
                indexNext = index +1;
            }
            else if(order == playorder_random)
            {
                static int s=0;
                if(s++==0)
                    srand((uint )time(NULL));
                
                indexNext =rand() % (count);
            }else if(order == playorder_repeat_single)
            {
                playTrack(track);
                return;
                
            }else if(order == playorder_repeat_list)
            {
                indexNext = index + 1;
                if ( indexNext == count )
                    indexNext = 0;
            }
            
            
            track = nil;
            if ( indexNext >= 0 && indexNext < [list count] )
                track = [list getItem: indexNext ];
            
            
            playTrack(track);
        }
    }
}

-(void)dealloc
{
//    [self.player removeTimeObserver:self.timeObserver];
    removeObserver(self);
}

-(PlayState)getPlayState
{
    return _state;
}

-(BOOL)isPlaying
{
    return _state == playstate_playing;
}

-(bool)isPaused
{
    return _state == playstate_paused;
}

-(bool)isStopped
{
    return  _state == playstate_stopped;
}

-(bool)isPending
{
    return _state == playstate_pending;
}

// by user
-(void)actionPlayRandom
{
    PlayerDocument *d = player().document;
    
    PlayerTrack *track = Playing();
    
    const PlayerList *list = track.list;
    
    if (!list)
        list = [d.playerlList getSelectedItem] ;
    
    assert(list);
    
    int count = (int)[list count];
    
    static int s=0;
    if(s++==0)
        srand((uint )time(NULL));
    
    int indexNext =rand() % (count) - 1;
    
    PlayerTrack* next = nil;
    
    if ( indexNext > 0 && indexNext < [list count] )
        next = [list getItem: indexNext ];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        playTrack(next);
    });
    
    postEvent(EventID_to_reload_tracklist, next );
}

-(void)playPause
{
    if (self.isPlaying) {
        [_audioFilePlayer pause];
        _state = playstate_paused ;
        postEvent(EventID_track_paused, nil);
    }
    else if (self.isPaused)
    {
        [_audioFilePlayer play];
        _state = playstate_playing ;
        postEvent(EventID_track_resumed, nil);
    }
    
    
    postEvent(EventID_track_state_changed, nil);
}


-(void)seekToTime:(NSTimeInterval)time
{
    justSeeked = 2;
    _progressInfo.current = time + 2 * timeInterval;
   
    AVAudioTime *startTime = [AVAudioTime timeWithSampleTime:time * self.sampleRate atRate:self.sampleRate];
    [_audioFilePlayer pause];
    [_audioFilePlayer playAtTime:startTime];
}

    
-(BOOL)playURL:(NSURL *)url pauseAfterInit:(BOOL)pauseAfterInit startTime:(NSTimeInterval)startTime
{
    NSURL* fileURL = url;
    auto audioFile = [[AVAudioFile alloc] initForReading:fileURL error:nil];
    auto audioFormat = audioFile.processingFormat;
    uint32 audioFrameCount = (uint32)audioFile.length;
    auto audioFileBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:audioFormat frameCapacity: audioFrameCount];
    [audioFile readIntoBuffer:audioFileBuffer error:nil];
    
    
    auto mainMixer = _audioEngine.mainMixerNode;
    
    [_audioEngine connect:_audioFilePlayer to:mainMixer format:audioFileBuffer.format];
    [_audioEngine startAndReturnError:nil];
   
    
    AVAudioFormat *outputFormat = [_audioFilePlayer outputFormatForBus:0];
    
    _sampleRate = outputFormat.sampleRate;
    
    if (startTime == 0) {
        [_audioFilePlayer play];
    }
    else{
        AVAudioTime *tStart = [AVAudioTime timeWithSampleTime: startTime * self.sampleRate atRate: self.sampleRate];
        [_audioFilePlayer playAtTime: tStart];
    }
    
    
    [_audioFilePlayer scheduleBuffer:audioFileBuffer atTime:nil options:AVAudioPlayerNodeBufferLoops completionHandler: nil ];
    
    
    if (pauseAfterInit)
    {
        [_audioFilePlayer pause];
        _state = playstate_paused;
    }
    else{
        [_audioFilePlayer play];
        _state = playstate_playing;
    }
    
    
    _progressInfo.current = startTime;
    
    _progressInfo.total = audioFrameCount / self.sampleRate;
    
    postEvent(EventID_track_started, _progressInfo );
    postEvent(EventID_track_state_changed, nil);
    
    return TRUE;
}


-(BOOL)playURL:(NSURL *)url
{
    return [self playURL:url pauseAfterInit:false startTime:0];
}

-(void)stopInner
{
    [_audioFilePlayer stop];
    
    _state = playstate_stopped;
    
    postEvent(EventID_track_stopped, nil);
    postEvent(EventID_track_state_changed, nil);
}


-(void)stop
{
    [_audioFilePlayer pause];
    
    setPlaying(nil);
    
    postEvent(EventID_track_stopped, nil);
    postEvent(EventID_track_state_changed, nil);
}

-(PlayStateTime)close
{
    PlayStateTime st;
    st.time = _progressInfo.current;
    st.state = [self getPlayState];
    st.volume = self.volume;
    [self stopInner];
    return st;
}

- (void)setVolume:(float)volume
{
    _audioFilePlayer.volume = volume;
}

- (float)volume
{
    return _audioFilePlayer.volume;
}

@end



@implementation ProgressInfo



@end
