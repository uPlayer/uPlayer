//
//  PlayerList.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//


#import "PlayerList.h"
#import "PlayerMessage.h"
#import "ThreadJob.h"
#import "PlayerError.h"

@interface PlayerList()

/// should save to file if is drity
@property (nonatomic) BOOL isDirty;
@end


@implementation PlayerList

const char fileformat[] = "%08d.plist";

+(instancetype)instanceFromFileIndex:(int)index
{
    char path2[256];
    sprintf(path2, fileformat,index);
    
    NSString *playlistDirectory = [ ApplicationSupportDirectory()  stringByAppendingPathComponent: playlistDirectoryName ];
    
    NSString *listFile = [playlistDirectory stringByAppendingPathComponent: [NSString stringWithUTF8String:path2] ];
    
    PlayerList *list = [NSKeyedUnarchiver unarchiveObjectWithFile:listFile];
    if (list == nil)
        postEvent( EventID_play_error_happened, [PlayerError errorNoSuchFile:listFile]);
    else
        list.fileIndex = index;
    
    return list;
}



-(instancetype)initWithOwner:(PlayerlList*)llist
{
    self = [super init];
    if (self) {
        _llist = llist;
        _selectIndex = -1;
        _topIndex = 0;
        _fileIndex = -1;
        self.playerTrackList= [NSMutableArray array];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self  = [super init]) {
        
        int fileVersion = [aDecoder decodeIntForKey:@"version"];
        if ( fileVersion == Playlist_Version )
        {
            self.name = [aDecoder decodeObjectForKey:@"name"];
            self.type = (PlayerListType)[aDecoder decodeIntForKey:@"type"];;
            
            // is dirty?
            self.playerTrackList = [NSMutableArray arrayWithArray: [aDecoder decodeObjectForKey:@"playerTrackList"]];
            if ( self.playerTrackList == nil)
                self.playerTrackList = [NSMutableArray array];
            
            for (PlayerTrack *track in self.playerTrackList) {
                track.list = self;
            }
            
        }
        else
        {
            postEvent(EventID_play_error_happened, [PlayerError errorConfigVersionDismatch]);
        }
        
        self.isDirty = FALSE;
        
        self.fileIndex = -1;
    }
    
    return self;
}



-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt: Playlist_Version forKey:@"version"];
    
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeInt:self.type forKey:@"type"];
    [aCoder encodeObject:self.playerTrackList forKey:@"playerTrackList"];
}


-(void)save
{
    assert(self.fileIndex != -1);
    
    if (self.isDirty)
    {
        NSString *playlistDirectory = [ ApplicationSupportDirectory()  stringByAppendingPathComponent: playlistDirectoryName ];
        
        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:playlistDirectory isDirectory:nil];
        
        if (!isExist)
            [[NSFileManager defaultManager] createDirectoryAtPath:playlistDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        
        
        char path2[256];
        sprintf(path2, fileformat ,self.fileIndex);
        
        NSString *listFile = [playlistDirectory stringByAppendingPathComponent: [NSString stringWithUTF8String:path2] ];
        
        [NSKeyedArchiver archiveRootObject:self toFile:listFile];
        self.isDirty = FALSE;
    }
    
}

-(void)markSelected
{
    _llist.selectItem = self;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        _selectIndex = -1;
        _topIndex = 0;
        self.playerTrackList= [NSMutableArray array];
    }
    return self;
}

-(NSInteger)getIndex:(PlayerTrack*)track
{
    return [self.playerTrackList indexOfObject: track];
}

-(PlayerTrack*)getItem:(NSInteger)index
{
    assert(index>=0 && index < self.playerTrackList.count);
    
    return self.playerTrackList[index];
}

/*
-(PlayerTrack*)getSelectedItem
{
    return [self getItem: _selectIndex];
}
 */

-(size_t)count
{
    return self.playerTrackList.count;
}

-(NSArray*)addItems:(NSArray*)items
{
    int count = (int)items.count;
    if (count > 0) {
        assert( [items.firstObject isKindOfClass:[PlayerTrack class] ]);
        
        for (PlayerTrack *track in items) {
            track.list = self;
        }
        
        [self.playerTrackList addObjectsFromArray: items];
        self.isDirty = TRUE;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            postEvent(EventID_tracks_changed, self);
        });
        
        return items;
    }
    
    return nil;
}

-(NSArray*)addTrackInfoItems:(NSArray*)items
{
    int count = (int) items.count;
    if (count > 0)
    {
        assert( [items.firstObject isKindOfClass:[TrackInfo class] ]);
        
        NSMutableArray *arr = [NSMutableArray array];
        for (TrackInfo *info in items) {
            PlayerTrack *track = [[PlayerTrack alloc]init:self];
            track.info=info;
            [arr addObject:track];
        }
        
        [self.playerTrackList addObjectsFromArray: arr];
        
        self.isDirty = TRUE;
        dispatch_async(dispatch_get_main_queue(), ^{
            postEvent(EventID_tracks_changed, self);
        });

        
        return arr;
    }
    
    return nil;
}

-(void)removeTrack:(NSInteger)index
{
    [self.playerTrackList removeObjectAtIndex:index];
    self.isDirty = TRUE;
    postEvent(EventID_tracks_changed, self);
}

-(void)removeTracks:(NSIndexSet*)indexs
{
    [self.playerTrackList removeObjectsAtIndexes: indexs];
    self.isDirty = TRUE;
    postEvent(EventID_tracks_changed, self);
}

-(NSArray*)trackAtSets:(NSIndexSet*)sets
{
    NSMutableArray *arr = [NSMutableArray array];
    [sets enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [arr addObject: [self.playerTrackList objectAtIndex:idx]];
    }];
    
    return arr;
}

-(void)removeAll
{
    self.selectIndex = -1;
    self.topIndex = -1;
    
    [self.playerTrackList removeAllObjects];
    self.isDirty = TRUE;
    
    postEvent(EventID_tracks_changed, self);
}

-(int)indexInParent
{
    return [self.llist.playerlList indexOfObject:self];
}

@end



@interface PlayerlList ()
@property (nonatomic,strong) PlayerList *tempPlayerlist;
@end


@implementation PlayerlList

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        
        self.selectIndex = [aDecoder decodeIntForKey:@"selectIndex"];
        
        NSString *playlistDirectory = [ ApplicationSupportDirectory()  stringByAppendingPathComponent: playlistDirectoryName ];
        

        int count = [aDecoder decodeIntForKey:@"count"];
        
        
        NSArray *arr = [aDecoder decodeObjectForKey:@"playerlList"];
        self.playerlList = [NSMutableArray array];
        for (NSDictionary *d in arr) {
        
            NSNumber* selectIndex = d[@"selectIndex"];
            NSNumber* topIndex = d[@"topIndex"];
            NSNumber* fileIndex = d[@"fileIndex"];
           
            PlayerList *list = [PlayerList instanceFromFileIndex:fileIndex.intValue];
            list.selectIndex = selectIndex.intValue;
            list.topIndex = topIndex.intValue;
            if ( list != nil) {
                [self.playerlList addObject:list];
            }
        }
        
        
//        
//        NSMutableArray *array = [NSMutableArray array];
//        
//        for (int i = 0; i < count; i++)
//        {
//            int index = i + 1;
//            
//            char path2[256];
//            sprintf(path2,"%08d.upl",index);
//            
//            NSString *listFile = [playlistDirectory stringByAppendingPathComponent: [NSString stringWithUTF8String:path2] ];
//            
//            PlayerList *list = [NSKeyedUnarchiver unarchiveObjectWithFile:listFile];
//            [array addObject:list];
//        }
//        
//        self.playerlList = array;
        
    }
    
    return self;
}


-(void)encodeWithCoder:(NSCoder *)aCoder
{
    NSString *playlistDirectory = [ ApplicationSupportDirectory()  stringByAppendingPathComponent: playlistDirectoryName ];
    
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:playlistDirectory isDirectory:nil];
    
    if (!isExist)
        [[NSFileManager defaultManager] createDirectoryAtPath:playlistDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    [aCoder encodeInteger:self.selectIndex forKey:@"selectIndex"];
    
    
    
    NSMutableArray *arr = [NSMutableArray array];
    int count = self.playerlList.count;
    for (int i = 0; i < count; i++)
    {
        PlayerList *l = self.playerlList[i];
        [l save];
        
        NSDictionary *d =
        @{@"selectIndex":@(l.selectIndex),
          @"topIndex":@(l.topIndex),
          @"fileIndex":@(l.fileIndex)};
        
        [arr addObject:d];
    }
    
    [aCoder encodeObject:arr forKey:@"playerlList"];
    
    
//    for (int i = 0; i < count; i++)
//    {
//        int index = i + 1;
//        char path2[256];
//        sprintf(path2,"%08d.upl",index);
//        
//        NSString *listFile = [playlistDirectory stringByAppendingPathComponent: [NSString stringWithUTF8String:path2] ];
//        
//        [NSKeyedArchiver archiveRootObject:self.playerlList[i] toFile:listFile];
//    }
    
    
}

-(instancetype)init
{
    self = [super init];
    if (self) {
//        _selectIndex = -1;
        self.playerlList = [NSMutableArray array];
    }
    return self;
}

-(PlayerList*)getItem:(int)index
{
    
    
    ///TODO ,delete
    if (index == self.playerlList.count) {
        return nil;
    }
    
    assert(index>=0 && index < self.playerlList.count);
    
    return self.playerlList[index];
}

-(NSInteger)getIndex:(PlayerList*)list
{
    return [_playerlList indexOfObject:list];
}

/*
-(void)setSelectItem:(PlayerList*)list
{
    NSUInteger index = [self.playerlList indexOfObject:list];
    if ( index == NSNotFound) {
#ifdef DEBUG
        assert(false);
#endif
    }
    else
    {
        _selectIndex = (int)index;
    }
    
}

-(PlayerList*)getSelectedList
{
    if (_selectIndex == -1)
        return nil;
    
    return [self getItem:_selectIndex];
}
*/

/*
-(PlayerList*)getPlayList
{
    if (_playIndex == -1)
        return nil;
    
    return [self getItem:_playIndex];
}*/

-(size_t)count
{
    return self.playerlList.count;
}

-(PlayerList*)newPlayerListWithName:(NSString*)name
{
    PlayerList *list = [[PlayerList alloc]initWithOwner:self];
    list.name = name;
    [self.playerlList addObject:list];
    list.fileIndex = self.playerlList.count - 1;
//    _selectIndex = (int)self.playerlList.count-1;
    
    postEvent(EventID_list_changed, nil);
    
    return list;
}

-(PlayerList*)newPlayerList
{
    return [self newPlayerListWithName:@"unnamed playlist"];
}

-(PlayerList*)tempPlayerList
{
    if (!_tempPlayerlist)
    {
        self.tempPlayerlist = [self newPlayerListWithName:@"temporary playlist"];
        _tempPlayerlist.type = type_temporary;
    }
    
    return _tempPlayerlist;
}

-(void)setTempPlayerList:(PlayerList*)list
{
    self.tempPlayerlist = list;
    list.type = type_temporary;
}

-(PlayerList*)deleteItem:(NSInteger)index
{
    NSInteger count = self.playerlList.count;
    
    if(count == 1)
    {
        NSAssert( index == 0, @"");
        [self.playerlList removeObjectAtIndex:0];
        return nil;
    }
    else
    {
        NSAssert(-1 < index && index < count, @"index beyond ..");
        [self.playerlList removeObjectAtIndex:index];
        
        NSInteger r = index == count - 1? index - 1 : index;
        
        return [self getItem:(int)r];
    }
}

-(PlayerList*)getPreviousItem:(NSInteger)index
{
    NSInteger count = self.playerlList.count;
    if(count == 1)
        return nil;
    
    NSInteger prev = index - 1;
    if (prev == -1) {
        prev = count - 1;
    }
    
    return [self getItem:(int)prev];
}

-(PlayerList*)getNextItem:(NSInteger)index
{
    NSInteger count = self.playerlList.count;
    if(count == 1)
        return nil;
    
    NSInteger prev = index + 1;
    if (prev == count) {
        prev = 0;
    }
    
    return [self getItem:(int)prev];
}

@end
