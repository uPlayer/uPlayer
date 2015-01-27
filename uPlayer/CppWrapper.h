//
//  AuTool.m
//  uPlayer
//
//  Created by liaogang on 15/1/22.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//


#import <Foundation/Foundation.h>




@interface TrackInfo: NSObject
-(NSString*)getArtist;
-(NSString*)getTitle;
-(NSString*)getAlbum;
-(NSString*)getGenre;
-(NSString*)getYear;
-(NSString*)getPath;
@end




@interface CppWrapper: NSObject

+(TrackInfo*) getId3Info:(NSString * )filename;

+(NSArray*)enumAudioFiles:(NSString*)path;

@end

enum PlayStatus
{
    playstatus_stopped,
    playstatus_playing,
    playstatus_paused
};


@interface PlayerCore: NSObject

- (void) windowWillClose:(NSNotification *)notification;

- (void) playPause:(id)sender;

- (void) seekForward:(id)sender;

- (void) seekBackward:(id)sender;

- (void) seek:(id)sender;

- (void) skipToNextTrack:(id)sender;

- (BOOL) playURL:(NSURL *)url;

- (BOOL) enqueueURL:(NSURL *)url;

@end


@interface PlayerLayout

@end

typedef enum : NSUInteger {
    a = 0
} PlayOrder;


@interface PlayerDocument
@property (nonatomic,strong) NSString *windowName;
@property (nonatomic) bool resumeAtReboot;
@property (nonatomic) int volume;
@property (nonatomic) PlayOrder playOrder;
@property (nonatomic) int playListIndex,trackIndex;
@property (nonatomic) enum PlayStatus playStatus;
@property (nonatomic) int listFontHeight,lyricsFontHeight;
@end

@interface MyPlayer : NSObject
@property (nonatomic,strong) PlayerDocument *document;
@property (nonatomic,strong) PlayerLayout *layout;
@property (nonatomic,strong) PlayerCore *core;
@end


