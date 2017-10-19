//
//  UPlayer.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import "PlayerTypeDefines.h"
#import "PlayerDocument.h"
#import <Foundation/Foundation.h>
//#import "serialize.h"
#include "PlayerDocument+ScreenSaver.h"
#include "ThreadJob.h"
#import "PlayerMessage.h"
#import "PlayerError.h"


@interface PlayerDocument ()

@end

@implementation PlayerDocument

+(NSString*)filePathForSearialize
{
    return [ApplicationSupportDirectory() stringByAppendingPathComponent: @"config.plist" ];
}

-(void)resetProperty
{
    self.windowName = NSLocalizedString(@"Smine windows name", nil);
    self.playerlList = [[PlayerlList alloc]init];
    self.resumeAtReboot = TRUE;
    self.playTime = -1;
    self.trackSongsWhenPlayStarted = FALSE;
    self.lastFmEnabled = FALSE;
    self.stopScrobblingWhenScreenSaverRunning = TRUE;
    self.volume = 1.0;
    self.playerQueue=[[PlayerQueue alloc]init];
    self.playingIndexList = -1;
    self.playingIndexTrack = -1;
}

-(instancetype)init
{
    self = [super init];
    if (self)
    {

        [self resetProperty];
        
#ifdef PlayerDocument_ScreenSaver
        [self monitorScreenSaverEvent];
#else
#warning "ScreenSaver not motiter enabled"
#endif
        
    }
    
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        
        [self resetProperty];
        
#ifdef PlayerDocument_ScreenSaver
        [self monitorScreenSaverEvent];
#else
#warning "ScreenSaver not motiter enabled"
#endif
        
        int fileVersion = [aDecoder decodeIntForKey:@"version"];
        if ( fileVersion == DocumentConfigFile_Version )
        {
            self.resumeAtReboot = [aDecoder decodeBoolForKey:@"resumeAtReboot"];
            self.trackSongsWhenPlayStarted = [aDecoder decodeBoolForKey:@"trackSongsWhenPlayStarted"];
            self.volume = [aDecoder decodeFloatForKey:@"volume"];
            self.playOrder = [aDecoder decodeIntForKey:@"playOrder"];
            self.playState = [aDecoder decodeIntForKey:@"playState"];
            self.fontHeight = [aDecoder decodeIntForKey:@"fontHeight"];
            self.lastFmEnabled = [aDecoder decodeIntForKey:@"lastFmEnabled"];
            self.playingIndexList = [aDecoder decodeIntForKey:@"playingIndexList"];
            self.playingIndexTrack = [aDecoder decodeIntForKey:@"playingIndexTrack"];
            self.playTime  = [aDecoder decodeDoubleForKey:@"playTime"];
            
            
            self.playerlList =[aDecoder decodeObjectForKey:@"playerlList"];
            
        }
        else
        {
            postEvent(EventID_play_error_happened, [PlayerError errorConfigVersionDismatch]);
        }
        
        [self didLoad];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [self willSaveConfig];
    
    [aCoder encodeInt: DocumentConfigFile_Version forKey:@"version"];
    
    [aCoder encodeBool:self.resumeAtReboot forKey:@"resumeAtReboot"];
    [aCoder encodeBool:self.trackSongsWhenPlayStarted forKey:@"trackSongsWhenPlayStarted"];
    [aCoder encodeFloat:self.volume forKey:@"volume"];
    [aCoder encodeInt:self.playOrder forKey:@"playOrder"];
    [aCoder encodeInt:self.playState forKey:@"playState"];
    [aCoder encodeInt:self.fontHeight forKey:@"fontHeight"];
    [aCoder encodeInt:self.lastFmEnabled forKey:@"lastFmEnabled"];
    [aCoder encodeInt:self.playingIndexList forKey:@"playingIndexList"];
    [aCoder encodeInt:self.playingIndexTrack forKey:@"playingIndexTrack"];
    [aCoder encodeDouble:self.playTime forKey:@"playTime"];
    
    [aCoder encodeObject:self.playerlList forKey:@"playerlList"];
}


-(BOOL)shouldScrobbleToLastFm
{
    if( self.lastFmEnabled)
    {
         if (self.stopScrobblingWhenScreenSaverRunning )
         {
             if (self.screenSaverRunning) {
                 return FALSE;
             }
         }
        
        return TRUE;
    }
    else
        return FALSE;
}

@end
