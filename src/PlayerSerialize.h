//
//
//  Created by liaogang on 15/1/4.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//




#import <Cocoa/Cocoa.h>
#include <cstdio>
#include <string>
#include <cstring>
#include <vector>
#import "PlayerList.h"
#import "PlayerTrack.h"
#import "PlayerDocument.h"
#import "PlayerLayout.h"

using namespace std;


   


@interface PlayerTrack (serialize)
-(void)saveTo:(FILE*)file;
-(void)loadFrom:(FILE*)file;
@end

@interface PlayerList (serialize)
-(void)saveTo:(NSString*)path;
-(void)loadFrom:(NSString*)path;
@end

@interface PlayerlList (serialize)
-(void)save:(NSString*)applicationDirectory;
-(void)load:(NSString*)applicationDirectory;
@end


@interface PlayerDocument (serialize)
-(bool)save;
-(bool)load;
@end

@interface PlayerLayout (serialize)
-(bool)save;
-(bool)load;
@end



@class TrackInfo;

#if defined(__cplusplus)
extern "C" {
#endif
    
    NSString *loadString(FILE &file);
    
    void saveString(FILE &file , NSString* value);
    
    void saveTrackInfo(FILE &file , TrackInfo *info);
    
    TrackInfo *loadTrackInfo(FILE &file);
    
    NSArray *loadTrackInfoArray(FILE &file);
    
    void saveTrackInfoArray( FILE &file , NSArray *array  );
    
    void saveStringArray( FILE &file , NSArray *array  );
    
    NSArray *loadStringArray(FILE &file);
   
    
    
#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */
