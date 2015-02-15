//
//  Last.fm.user
//  Last.fm
//
//  Created by liaogang on 15/1/4.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import "PlayerSerialize.h"
#import "serialize.h"
#import "UPlayer.h"

FILE& operator<<(FILE& f,const NSTimeInterval &t)
{
    fwrite(&t, sizeof(NSTimeInterval), 1, &f);
    return f;
}

FILE& operator>>(FILE& f,NSTimeInterval& t)
{
    fread(&t, sizeof(NSTimeInterval), 1, &f);
    return f;
}

#pragma mark -

#define docFileName  @"core.cfg"
#define layoutFileName  @"ui.cfg"


void saveTrackInfo(FILE &file , TrackInfo *info)
{
    saveString(file, info.artist);
    saveString(file, info.title);
    saveString(file, info.album);
    saveString(file, info.genre);
    saveString(file, info.year);
    saveString(file, info.path);
}

TrackInfo *loadTrackInfo(FILE &file)
{
    TrackInfo *info = [[TrackInfo alloc]init];
    info.artist = loadString(file);
    info.title= loadString(file);
    info.album= loadString(file);
    info.genre= loadString(file);
    info.year= loadString(file);
    info.path= loadString(file);
    
    return info;
}

NSString *loadString(FILE &file)
{
    char buf[256];
    file >> buf;
    return [NSString stringWithUTF8String:buf];
}

void saveString(FILE &file , NSString* value)
{
    file << value.UTF8String;
}

NSArray *loadStringArray(FILE &file)
{
    NSMutableArray *array;
    
    
    int count = -1;
    file >> count;
    
    while (count-->0) {
        [array addObject: loadString(file) ];
    } ;
    
    return array;
}

void saveStringArray( FILE &file , NSArray *array  )
{
    int count = (int)array.count;
    if (count > 0)
    {
        assert( [array.firstObject isKindOfClass:[NSString class]]);
        
        file << count;
        
        for (NSString *value in array)
        {
            saveString(file,value);
        }
        
    }
    
}


void saveTrackInfoArray( FILE &file , NSArray *array  )
{
    int count = (int)array.count;
    if (count > 0)
    {
        assert( [array.firstObject isKindOfClass:[TrackInfo class]] );
        
        file << count;
        
        for (TrackInfo *value in array)
        {
            saveTrackInfo(file,value);
        }
        
    }
    
}

NSArray *loadTrackInfoArray(FILE &file)
{
    NSMutableArray *array = [NSMutableArray array];
    
    int count = -1;
    file >> count;
    
    while (count-->0) {
        [array addObject: loadTrackInfo(file) ];
    } ;
    
    return array;
}

#pragma mark -

@implementation PlayerTrack (serialize)

-(void)saveTo:(FILE*)file
{
    *file << self.index;
    saveTrackInfo(*file, self.info);
}

-(void)loadFrom:(FILE*)file
{
    int index;
    *file >> index;
    self.index = index;
    
    TrackInfo *info = loadTrackInfo(*file);
    self.info = info;
    
}
@end



@implementation PlayerList (serialize)
-(void)saveTo:(FILE*)file
{
    saveString(*file, self.name);
    
    *file << self.selectIndex << self.playIndex << self.topIndex;
    
    int count = (int) self.playerTrackList.count;
    *file << count;
    
    for (PlayerTrack *track in self.playerTrackList) {
        [track saveTo:file];
    }
}


-(void)loadFrom:(FILE*)file
{
    self.name = loadString(*file);
    int selectIndex,playIndex,topIndex;
    *file >> selectIndex >> playIndex >> topIndex;
    self.selectIndex=selectIndex;
    self.playIndex = playIndex;
    self.topIndex=topIndex;
    
    int count = -1;
    *file >> count;
    NSMutableArray *arr = [NSMutableArray array];
    while (count-- > 0) {
        PlayerTrack *track = [[PlayerTrack alloc]init];
        [track loadFrom:file];
        [arr addObject:track];
    }
    
    self.playerTrackList = arr;
    
}
@end


@implementation PlayerlList (serialize)
-(void)saveTo:(FILE*)file
{
    *file << self.selectIndex << self.playIndex ;
    
    int count = (int) self.playerlList.count;
    *file << count;
    
    for ( PlayerList *list in self.playerlList) {
        [list saveTo:file];
    }
    
}

-(void)loadFrom:(FILE*)file
{
    int si,pi;
    *file >> si >> pi;
    self.selectIndex = si;
    self.playIndex = pi;
    
    int count = -1;
    *file >> count;
    
    NSMutableArray *arr = [NSMutableArray array];
    while (count-- > 0) {
        PlayerList *list = [[PlayerList alloc]init];
        [list loadFrom:file];
        [arr addObject: list];
    }
    
    self.playerlList = arr;
}

@end





@implementation PlayerDocument (serialize)

-(bool)load
{
    
    FILE *file = fopen([ApplicationSupportDirectory()  stringByAppendingPathComponent: docFileName ].UTF8String, "r");
    
    if (file)
    {
        int resumeAtReboot , trackSongsWhenPlayStarted, volume ,playOrder ,playState , fontHeight ,lastFmEnabled ;
        NSTimeInterval playTime;
        
        *file >> resumeAtReboot  >> trackSongsWhenPlayStarted >> volume >> playOrder >>playState >> fontHeight >> lastFmEnabled >> playTime;
        
        self.resumeAtReboot=resumeAtReboot;
        self.trackSongsWhenPlayStarted = trackSongsWhenPlayStarted;
        self.volume=volume;
        self.playOrder=playOrder;
        self.playState=playState;
        self.fontHeight=fontHeight;
        self.lastFmEnabled = lastFmEnabled;
        self.playTime = playTime;
        
        
        assert(self.playerlList);
        [self.playerlList loadFrom:file];
        
        
        fclose(file);
        
        return true;
    }
    
    return false;
}

-(bool)save
{
    FILE *file = fopen([ApplicationSupportDirectory() stringByAppendingPathComponent: docFileName].UTF8String, "w");
    
    if (file)
    {
        *file << self.resumeAtReboot << self.trackSongsWhenPlayStarted  << self.volume << self.playOrder << self.playState << self.fontHeight << self.lastFmEnabled <<self.playTime ;
        
        [self.playerlList saveTo:file];
        
        fclose(file);
        return true;
    }
    
    return false;
}

@end

#pragma mark -

@implementation PlayerLayout (serialize)
-(bool)save
{
    FILE *file = fopen([ApplicationSupportDirectory() stringByAppendingPathComponent: layoutFileName].UTF8String, "w");
    
    if (file)
    {
        
        fclose(file);
        return true;
    }
    
    return false;
}

-(bool)load
{
    FILE *file = fopen([ApplicationSupportDirectory()  stringByAppendingPathComponent: layoutFileName ].UTF8String, "r");
    
    if (file)
    {

        
        
        fclose(file);
        
        return true;
    }
    
    return false;
}
@end
