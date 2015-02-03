//
//  UPlayer.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayerEngine.h"
#import "PlayerMessage.h"

#import "UPlayer.h"

#include <atomic>
#include <SFBAudioEngine/AudioDecoder.h>
#include <SFBAudioEngine/AudioPlayer.h>
#include <SFBAudioEngine/AudioMetadata.h>

using namespace SFB::Audio;


enum ePlayerFlags : unsigned int {
    ePlayerFlagRenderingStarted			= 1u << 0,
    ePlayerFlagRenderingFinished		= 1u << 1
};

@interface PlayerEngine ()
{
    std::atomic_uint	_playerFlags;
    dispatch_source_t	_timer;
    Player::PlayerState _playState;
}
@property (nonatomic,assign) SFB::Audio::Player *player;
@end

@implementation PlayerEngine

-(void)needResumePlayAtBoot
{
    PlayerDocument *doc = player().document;
    if (doc.resumeAtReboot)
    {
        if ( 1) // isplaying
        {            playTrack( [doc.playerlList getPlayList], [[doc.playerlList getPlayList] getPlayItem]);
        }
    }
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        
        self.player = new SFB::Audio::Player();
        addObserverForEvent(self, @selector(playNext), EventID_track_stopped);
        addObserverForEvent(self, @selector(needResumePlayAtBoot), EventID_player_document_loaded);
        
        _playState = Player::PlayerState::Stopped;
        
        _playerFlags = 0;
        
        // This will be called from the realtime rendering thread and as such MUST NOT BLOCK!!
        _player->SetRenderingStartedBlock(^(const SFB::Audio::Decoder& /*decoder*/){
            _playerFlags.fetch_or(ePlayerFlagRenderingStarted);
        });
        
        // This will be called from the realtime rendering thread and as such MUST NOT BLOCK!!
        _player->SetRenderingFinishedBlock(^(const SFB::Audio::Decoder& /*decoder*/){
            _playerFlags.fetch_or(ePlayerFlagRenderingFinished);
        });
        
        // Update the UI 5 times per second
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, NSEC_PER_SEC / 5, NSEC_PER_SEC / 3);
        
        
        dispatch_source_set_event_handler(_timer, ^{
            
            // To avoid blocking the realtime rendering thread, flags are set in the callbacks and subsequently handled here
            auto flags = _playerFlags.load();
            
            if(ePlayerFlagRenderingStarted & flags) {
                _playerFlags.fetch_and(~ePlayerFlagRenderingStarted);
                
                //[self updateWindowUI];
                
                return;
            }
            else if(ePlayerFlagRenderingFinished & flags) {
                _playerFlags.fetch_and(~ePlayerFlagRenderingFinished);
                
                //[self updateWindowUI];
                
                return;
            }
            
            Player::PlayerState state = _player->GetPlayerState();
            
            if (_playState != state)
            {
                if( state == Player::PlayerState::Paused )
                    postEvent(EventID_track_paused, nil);
                else if (state == Player::PlayerState::Stopped)
                    postEvent(EventID_track_stopped, nil);
                else if ( state == Player::PlayerState::Playing)
                {
                    if (_playState == Player::PlayerState::Stopped)
                        postEvent(EventID_track_started, nil);
                    else if ( _playState == Player::PlayerState::Paused)
                        postEvent(EventID_track_resumed, nil);
                }
            }
            
            if (state != Player::PlayerState::Pending)
                _playState = state;
            
            
            SInt64 currentFrame, totalFrames;
            CFTimeInterval currentTime, totalTime;
            
            if(_player->GetPlaybackPositionAndTime(currentFrame, totalFrames, currentTime, totalTime)) {
                double fractionComplete = static_cast<double>(currentFrame) / static_cast<double>(totalFrames);
                
                ProgressInfo *info=[[ProgressInfo alloc]init];
                info.current=currentTime;
                info.total=totalTime;
                info.fractionComplete=fractionComplete;
             
                postEvent(EventID_track_progress_changed, info);
            }
            
        });
        
        // Start the timer
        dispatch_resume(_timer);
    }
    
    return self;
}



-(void)playNext
{
    PlayerDocument *d = player().document;
    
    PlayerList *list = [d.playerlList getPlayList];
    PlayerTrack *track = [list getPlayItem];
    
    assert(list);
    
    int count = (int)[list count];
    int indexNext =-1;
    PlayOrder order = d.playOrder;
    
    if (order == playorder_single) {
        
    }
    else if (order == playorder_default)
    {
        indexNext = track.index +1;
    }
    else if(order == playorder_random)
    {
        static int s=0;
        if(s++==0)
            srand((uint )time(NULL));
        
        indexNext =rand() % (count) - 1;
    }
    
    PlayerTrack* next = nil;
    
    if ( indexNext > 0 && indexNext < [list count] )
        next = [list getItem: indexNext ];
 
    playTrack(list,next);
    
}

-(void)dealloc
{
    removeObserver(self);
}


-(bool)isPlaying
{
    return _player->IsPlaying();
}

-(bool)isPaused
{
    return _player->IsPaused();
}

-(bool)isStopped
{
    return _player->IsStopped();
}

-(bool)isPending
{
    return _player->IsPending();
}


- (void) playPause
{
    _player->PlayPause();
}

- (void) seekForward
{
    _player->SeekForward();
}

- (void) seekBackward
{
    _player->SeekBackward();
}

- (void) seekToPos:(id)sender
{
    _player->SeekToPosition([sender floatValue]);
}

- (void) seekToTime:(id)sender
{
    _player->SeekToTime([sender floatValue]);
}

- (void) skipToNextTrack
{
    _player->SkipToNextTrack();
}

- (BOOL) playURL:(NSURL *)url
{
    return _player->Play((__bridge CFURLRef)url);
}

- (BOOL) enqueueURL:(NSURL *)url
{
    return _player->Enqueue((__bridge CFURLRef)url);
}

- (BOOL) stop
{
    return _player->Stop();
}



@end



@implementation ProgressInfo



@end