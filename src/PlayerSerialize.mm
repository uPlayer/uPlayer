//
//
//  Created by liaogang on 15/1/4.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import "PlayerSerialize.h"
#import "serialize.h"
#import "ThreadJob.h"
#import "PlayerTypeDefines.h"
#import "MAAssert.h"
#import "PlayerLayout.h"
#import "PlaylistViewController.h"


const int max_path = 256;




#ifdef DEBUG
#define assertBool(x) \
MAAssert( (x) == 0 || (x) == 1)
#else
#endif









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


FILE& operator<<(FILE& f,const NSString *t)
{
   return f << t.UTF8String;
}


#pragma mark -




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

void saveData(FILE &file , NSData *data)
{
    int length = (int)data.length;
    file << length;
    
    fwrite(data.bytes , 1, length , &file);
}

NSData *loadData(FILE &file)
{
    int length = 0;
    file >> length;
    
    void *buffer =malloc(length);
    
    fread( buffer, 1, length , &file);
    
    NSData *data = [[NSData alloc] initWithBytes:buffer length:length];
    
    free(buffer);
    
    return data;
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
    saveTrackInfo(*file, self.info);
}

-(void)loadFrom:(FILE*)file
{
    TrackInfo *info = loadTrackInfo(*file);
    self.info = info;
}
@end



@implementation PlayerList (serialize)
-(void)saveTo:(NSString*)path
{
    FILE *file = fopen(path.UTF8String, "w");
    if (file)
    {
//        saveString(*file, self.name);
        
        *file << self.selectIndex  << self.topIndex << (int)self.type;
        
        int count = (int) self.playerTrackList.count;
        *file << count;
        
        for (PlayerTrack *track in self.playerTrackList) {
            [track saveTo:file];
        }
        fclose(file);
    }
    
}


-(void)loadFrom:(NSString*)path
{
    FILE *file = fopen(path.UTF8String, "r");
    if (file)
    {
//        self.name = loadString(*file);
        int selectIndex,topIndex,type;
        *file >> selectIndex >> topIndex >>type;
        self.selectIndex=selectIndex;
        self.topIndex=topIndex;
        self.type = (enum PlayerListType)type;
        
        int count = 0;
        *file >> count;
        NSMutableArray *arr = [NSMutableArray array];
        while (count-- > 0) {
            PlayerTrack *track = [[PlayerTrack alloc]init:self];
            [track loadFrom:file];
            [arr addObject:track];
        }
        
        self.playerTrackList = arr;
        fclose(file);
    }
    
}
@end


@implementation PlayerlList (serialize)
-(void)save:(NSString*)applicationDirectory
{
    NSString *playlistDirectory = [applicationDirectory  stringByAppendingPathComponent: playlistDirectoryName ];
    
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:playlistDirectory isDirectory:nil];
    
    if (!isExist)
        [[NSFileManager defaultManager] createDirectoryAtPath:playlistDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *path = [playlistDirectory stringByAppendingPathComponent: playlistIndexFileName];
    
    FILE *file = fopen(path.UTF8String, "w");
    if (file)
    {
        *file << self.selectIndex ;
        
        int count = (int) self.playerlList.count;
        *file << count;
        
        for (int i = 0; i < count; i++)
        {
            int index = i + 1;
            
            char path2[max_path];
            
            sprintf(path2,"%08d.upl",index);
            
            PlayerList *list = self.playerlList[i];
            [list saveTo: [playlistDirectory stringByAppendingPathComponent: [NSString stringWithUTF8String:path2 ]] ];
            
            *file << index << list.name;
        }
        
        fclose(file);
    }
    
    
}

-(void)load:(NSString*)applicationDirectory
{
    NSString *playlistDirectory = [applicationDirectory  stringByAppendingPathComponent: playlistDirectoryName ];
    
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:playlistDirectory isDirectory:nil];
    
    if (!isExist)
        [[NSFileManager defaultManager] createDirectoryAtPath:playlistDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    
    NSString *path = [playlistDirectory stringByAppendingPathComponent: playlistIndexFileName];
    
    FILE *file = fopen(path.UTF8String, "r");
    if (file)
    {
        int si;
        *file >> si;
        self.selectIndex = si;
        
        // load all playlist indexs.
        int count = 0;
        *file >> count;
        
        NSMutableArray *arr = [NSMutableArray array];
        while (count-->0)
        {
            int index ;
            NSString *playlistName;
            *file >> index ;
            playlistName = loadString(*file);
            
            char path2[max_path];
            sprintf(path2,"%08d.upl",index);
            
            PlayerList *list = [[PlayerList alloc]init];
            list.name = playlistName;
            [list loadFrom:[playlistDirectory stringByAppendingPathComponent: [NSString stringWithUTF8String:path2] ]];
            [arr addObject: list];
            
            if (list.type == type_temporary)
                [self setTempPlayerList:list];
        }
        
        self.playerlList = arr;
        
        fclose(file);
    }
}

@end





@implementation PlayerDocument (serialize)

#ifdef DEBUG
-(void)assertMembers
{
    assertBool(self.resumeAtReboot);
    assertBool( self.resumeAtReboot );
    assertBool( self.trackSongsWhenPlayStarted );
    MAAssert( 0 <= self.volume && self.volume <= 1);
    MAAssert( self.playOrder < kPlayOrder.count );
    assertBool( self.lastFmEnabled );
}
#endif

-(bool)load
{
    NSString *appSupportDir = ApplicationSupportDirectory();
    
    
    NSString *fileName =  [appSupportDir  stringByAppendingPathComponent: docFileName ];
    
    /** the load protect system.
     Before load the config file,we create a lock file.
     After load complete,we delete lock file,and backup the config file.
     
     If anything happenned,load failed,the lock file is leaved there.
     */
    
    NSString *lockFilePath = [appSupportDir  stringByAppendingPathComponent: docFileNameLock ];
    
    FILE *loadConfigLockFile = fopen(lockFilePath.UTF8String, "r");
    
    
    self.needBackupConfigFile = true;
    
    NSString *_backupFileName = [appSupportDir  stringByAppendingPathComponent: docFileNameLastSuccessfullyLoaded ];
    const char *backupFileName =  _backupFileName.UTF8String;
    
    if (loadConfigLockFile) {
        // Last loading failed,load last file successfully saved yet.
        char cmdCP[256] = "cp \"";
        strcat(cmdCP, backupFileName);
        strcat(cmdCP, "\" \"");
        strcat(cmdCP, fileName.UTF8String);
        strcat(cmdCP, "\"");
        system(cmdCP);
        
        self.needBackupConfigFile = false;
    }
    else
    {
        //create one
        loadConfigLockFile = fopen(lockFilePath.UTF8String, "w");
    }
    
    
    
    FILE *file = fopen( fileName.UTF8String ,"r");
    if (file)
    {
        int resumeAtReboot , trackSongsWhenPlayStarted ;
        float volume ;
        int playOrder ,playState , fontHeight ,lastFmEnabled ;
        int playingIndexList,playingIndexTrack;
        NSTimeInterval playTime;
        
        *file >> resumeAtReboot  >> trackSongsWhenPlayStarted >> volume >> playOrder >>playState >> fontHeight >> lastFmEnabled >>playingIndexList >> playingIndexTrack >> playTime;
        
        self.resumeAtReboot=resumeAtReboot;
        self.trackSongsWhenPlayStarted = trackSongsWhenPlayStarted;
        self.volume=volume;
        self.playOrder=playOrder;
        self.playState=playState;
        self.fontHeight=fontHeight;
        self.lastFmEnabled = lastFmEnabled;
        
        self.playingIndexList = playingIndexList;
        self.playingIndexTrack = playingIndexTrack;
        
        self.playTime = playTime;
        
#ifdef DEBUG
        [self assertMembers];
#endif
        
        assert(self.playerlList);
        [self.playerlList load:appSupportDir];
        
        
        fclose(file);
        
        [self didLoad];
        
        //If load complete,delete the lock file.
        fclose(loadConfigLockFile);
        unlink(lockFilePath.UTF8String);
        
        if( self.needBackupConfigFile )
        {
            //backup config file.
            char cmdCP[256] = "cp \"";
            strcat(cmdCP, fileName.UTF8String);
            strcat(cmdCP, "\" \"");
            strcat(cmdCP, backupFileName);
            strcat(cmdCP, "\"");
            system(cmdCP);
            
            self.needBackupConfigFile = false;
        }
        
        _backupFileName = nil;
        
        
        return true;
    }
    
    
    return false;
}


-(bool)savePlaylist
{
    NSString *appSupportDir = ApplicationSupportDirectory();
    [self.playerlList willSave];
    [self.playerlList save:appSupportDir];
    return true;
}

-(bool)saveConfig
{
    [self willSaveConfig];
    
    NSString *appSupportDir = ApplicationSupportDirectory();
    NSString *_fileName = [appSupportDir stringByAppendingPathComponent: docFileName];
    const char * fileName = _fileName.UTF8String;
    
    NSString *_backupFileName = [appSupportDir  stringByAppendingPathComponent: docFileNameLastSuccessfullyLoaded ];
    const char *backupFileName =  _backupFileName.UTF8String;
    
    
    if( self.needBackupConfigFile )
    {
        //backup config file.
        char cmdCP[256] = "cp \"";
        strcat(cmdCP, fileName);
        strcat(cmdCP, "\" \"");
        strcat(cmdCP, backupFileName);
        strcat(cmdCP, "\"");
        system(cmdCP);
    }
    
    
    FILE *file = fopen( fileName , "w");
    
    if (file)
    {
#ifdef DEBUG
        [self assertMembers];
#endif
        
        NSLog(@"list: %d, index: %d",self.playingIndexList,self.playingIndexTrack);
        
        *file << self.resumeAtReboot << self.trackSongsWhenPlayStarted  << self.volume << self.playOrder << self.playState << self.fontHeight << self.lastFmEnabled <<self.playingIndexList << self.playingIndexTrack <<self.playTime ;
        
        
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
        int count = (int)self.dicObjects.count;
        *file << count;
        
        for (NSString *key in self.dicObjects.allKeys) {
            saveString(*file, key);
            NSData *data = self.dicObjects[key];
            saveData(*file, data);
        }
        
        
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
        int count = 0;
        *file >> count;
        
        for (int i = 0; i< count ; i++) {
            
            NSString *key = loadString(*file);
            
            NSData *data = loadData(*file);
            
            self.dicObjects[key]=data;
        }
        
        
        fclose(file);
        
        return true;
    }
    
    return false;
}
@end


@implementation PlaylistViewController (layout)

-(void)saveTo:(FILE*)file
{
    int count = (int)self.tableColumnWidths.count;
    *file << count;
    
    for (NSNumber *n in self.tableColumnWidths) {
        *file << n.floatValue;
    }
}

-(void)loadFrom:(FILE*)file
{
    int count = 0;
    *file >> count;
    
    self.tableColumnWidths = [NSMutableArray array];
    
    while (count-->0) {
        float v = 0;
        *file >> v;
        [self.tableColumnWidths addObject:@(v)];
    }
}

@end
