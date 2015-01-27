//
//  AuTool.m
//  uPlayer
//
//  Created by liaogang on 15/1/22.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//


#import "CppWrapper.h"
#import "audioTag.h"
#import "fileCtrl.h"
#import "threadpool.h"

#include <AudioToolbox/AudioToolbox.h>


#include <SFBAudioEngine/AudioPlayer.h>
#include <SFBAudioEngine/AudioDecoder.h>
#include <SFBAudioEngine/AudioMetadata.h>

void* addJobIsFileAudio(const char * file ,void *arg);



@interface TrackInfo()
@property (nonatomic,strong) NSString *artist,*title,*album,*genre,*year;
@property (nonatomic,strong)NSString *path;
@end

@implementation TrackInfo
-(NSString*)getArtist{return self.artist;}
-(NSString*)getTitle{return self.title;}
-(NSString*)getAlbum{return self.album;}
-(NSString*)getGenre{return self.genre;}
-(NSString*)getYear{return self.year;}
-(NSString*)getPath{return self.path;}
@end




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

@end

@interface CppWrapper ()
@end



@implementation CppWrapper






+(TrackInfo*) getId3Info:(NSString * )filename;
{
    TrackInfo* at = [[TrackInfo alloc]init];
    char artist[256];
    char title[256];
    char album[256];
    char genre[256];
    char year[256];
    
    if( getId3Info(filename.UTF8String, artist, title, album,genre,year) )
    {
        at.artist=[NSString stringWithUTF8String:artist];
        at.title=[NSString stringWithUTF8String:title];
        at.album=[NSString stringWithUTF8String:album];
        at.genre=[NSString stringWithUTF8String:genre];
        
        if([at.genre isEqualToString:@"null"])
            at.genre=@"";
        
        at.year=[NSString stringWithUTF8String:year];
        
        return at;
    }
    
    return nil;
}



+(NSArray*)enumAudioFiles:(NSString*)path
{
    NSMutableArray *array = [NSMutableArray array];
    
    pool_init(8);
    
    IterFiles(std::string (path.UTF8String ), std::string (path.UTF8String ), addJobIsFileAudio, (__bridge void*)array );
    
    
    pool_destroy();
    
    
    return array;
}

@end


void* addJobIsFileAudio(const char * file ,void *arg)
{
    NSMutableArray *array = (__bridge NSMutableArray*)arg;
    
    TrackInfo *arti = [CppWrapper getId3Info: [NSString stringWithUTF8String:file]];
    
    if (arti) {
        arti.path = [NSString stringWithUTF8String:file];
        
        [array addObject:arti];
    }
    
    return nullptr;
}

