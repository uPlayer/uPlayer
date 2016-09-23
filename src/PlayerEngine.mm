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

static void *AVPlayerDemoPlaybackViewControllerRateObservationContext = &AVPlayerDemoPlaybackViewControllerRateObservationContext;

@interface PlayerEngine ()
{
    PlayState _state;
    dispatch_source_t	_timer;
}
@property (atomic,strong) AVPlayer *player;

@end

@implementation PlayerEngine

-(void)needResumePlayAtBoot
{
    PlayerDocument *doc = player().document;
    if (doc.resumeAtReboot && doc.playState != playstate_stopped )
    {
        PlayerTrack *track = Playing();
        PlayerList *list = track.list;
        
        if ( doc.playState == playstate_playing )
            playTrack( track );
        else
            playTrackPauseAfterInit( list, track );
        
        if (doc.playTime > 0)
            [self seekToTime:doc.playTime];
    }
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        
        _state = playstate_stopped;
        
        self.player = [[AVPlayer alloc]init];
        self.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        
        
        addObserverForEvent(self, @selector(playNext), EventID_track_stopped_playnext);
        
        addObserverForEvent(self, @selector(actionPlayNext), EventID_to_play_next);
        
        addObserverForEvent(self, @selector(needResumePlayAtBoot), EventID_player_document_loaded);
       
        addObserverForEvent(self, @selector(stop), EventID_to_stop);
        
        addObserverForEvent(self, @selector(playPause), EventID_to_play_pause_resume);
        
        addObserverForEvent(self, @selector(actionPlayRandom), EventID_to_play_random);
        

        /* Observe the AVPlayer "rate" property to update the scrubber control. */
        [self.player addObserver:self
                      forKeyPath:@"rate"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:AVPlayerDemoPlaybackViewControllerRateObservationContext];
        
        
        NSNotificationCenter *d =[NSNotificationCenter defaultCenter];
        
        [d addObserver:self selector:@selector(DidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        
        // Update the UI 5 times per second
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, NSEC_PER_SEC / 2, NSEC_PER_SEC / 3);
        
        dispatch_source_set_event_handler(_timer, ^{
            
                if ( [self getPlayState] != playstate_stopped)
                {
                    ProgressInfo *info=[[ProgressInfo alloc]init];
                    info.current =  [self currentTime];
                    info.total = CMTimeGetSeconds( _player.currentItem.duration );
                    
                    postEvent(EventID_track_progress_changed, info);
                }
        });
        
        // Start the timer
        dispatch_resume(_timer);
    }
    
    return self;
}






-(void)DidPlayToEndTime:(NSNotification*)n
{
    [self stopInner];
    
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
    removeObserver(self);
}

-(PlayState)getPlayState
{
    return _state;
}

-(BOOL)isPlaying
{
//    NSLog(@"isPlaying");
    return _state == playstate_playing;
//    return  (_player.currentItem != nil) && (_player.rate != 0.f ) ;
}

-(bool)isPaused
{
//    NSLog(@"isPaused");
    return _state == playstate_paused;
//    return _player.rate == 0.0;
}

-(bool)isStopped
{
//    NSLog(@"isStopped");
    return  _state == playstate_stopped;
//    return _player.currentItem == nil;
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
        [_player pause];
        _state = playstate_paused ;
        postEvent(EventID_track_paused, nil);
    }
    else if (self.isPaused)
    {
        [_player play];
        _state = playstate_playing ;
        postEvent(EventID_track_resumed, nil);
    }
    
    
    postEvent(EventID_track_state_changed, nil);
}


-(void)seekToTime:(NSTimeInterval)time
{
    [_player seekToTime: CMTimeMakeWithSeconds( time , 1) ];
}

-(NSTimeInterval)currentTime
{
   	CMTime time = _player.currentTime;
    return CMTimeGetSeconds(time);
}

-(BOOL)playURL:(NSURL *)url pauseAfterInit:(BOOL)pfi
{
    AVURLAsset *asset = [AVURLAsset assetWithURL: url];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset: asset automaticallyLoadedAssetKeys:@[@"playable",@"duration"]];
    
    @try {
        [_player replaceCurrentItemWithPlayerItem: item ];
    } @catch (NSException *exception) {
        NSLog(@"replaceCurrentItemWithPlayerItem: %@",exception);
    } @finally {
    }
    
    if (pfi == false)
        [_player play];
    
    ProgressInfo *info = [[ProgressInfo alloc]init];
    info.total = CMTimeGetSeconds( item.duration);
    
    postEvent(EventID_track_started, info);
    
    postEvent(EventID_track_state_changed, nil);
    
    return 1;
}


- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    /* AVPlayer "rate" property value observer. */
    if (context == AVPlayerDemoPlaybackViewControllerRateObservationContext)
    {
        [self syncPlayerRate];
    }
}

-(void)syncPlayerRate
{
    float rate = _player.rate;
    if (rate == 0.f) {
        _state = playstate_paused;
    }
    else
    {
        _state = playstate_playing;
    }
    
}

-(BOOL)playURL:(NSURL *)url
{
    return [self playURL:url pauseAfterInit:false];
}

-(void)stopInner
{
    [_player pause];
    [_player replaceCurrentItemWithPlayerItem:nil];
    
    _state = playstate_stopped;
    
    postEvent(EventID_track_stopped, nil);
    postEvent(EventID_track_state_changed, nil);
}


-(void)stop
{
    [_player pause];
    [_player replaceCurrentItemWithPlayerItem:nil];
    
    setPlaying(nil);
    
    postEvent(EventID_track_stopped, nil);
    postEvent(EventID_track_state_changed, nil);
}

-(PlayStateTime)close
{
    PlayStateTime st;
    st.time =[self currentTime];
    st.state = [self getPlayState];
    st.volume = self.volume;
    [self stopInner];
    return st;
}

- (void)setVolume:(float)volume
{
    _player.volume = volume;
}

- (float)volume
{
    return  _player.volume;
}

@end



@implementation ProgressInfo



@end
