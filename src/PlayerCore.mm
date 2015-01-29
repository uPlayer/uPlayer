//
//  UPlayer.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PlayerCore.h"

#include <AudioToolbox/AudioToolbox.h>


#include <SFBAudioEngine/AudioPlayer.h>
#include <SFBAudioEngine/AudioDecoder.h>
#include <SFBAudioEngine/AudioMetadata.h>

@interface PlayerCore ()
@property (nonatomic,assign) SFB::Audio::Player *player;
@end




@implementation PlayerCore

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.player = new SFB::Audio::Player();
        
    }
    return self;
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

- (void) windowWillClose:(NSNotification *)notification
{
    _player->Stop();
}

- (void) playPause:(id)sender
{
    _player->PlayPause();
}

- (void) seekForward:(id)sender
{
    _player->SeekForward();
}

- (void) seekBackward:(id)sender
{
    _player->SeekBackward();
}

- (void) seek:(id)sender
{
    _player->SeekToPosition([sender floatValue]);
}

- (void) skipToNextTrack:(id)sender
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