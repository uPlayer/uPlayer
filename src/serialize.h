//
//  Last.fm.h
//  Last.fm
//
//  Created by liaogang on 15/1/4.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//



#ifndef __seralize_h__
#define __seralize_h__

#import <Cocoa/Cocoa.h>
#include <cstdio>
#include <string>
#include <cstring>
#include <vector>
#import "PlayerList.h"
#import "PlayerTrack.h"
#import "PlayerDocument.h"
using namespace std;


    
/// int
FILE& operator<<(FILE& f,const int t);


FILE& operator>>(FILE& f,int& t);


/// char
//write zero terminated str array
FILE& operator<<(FILE& f,const char* str);


FILE& operator>>(FILE& f,char* str);


/// string
FILE& operator<<(FILE& f,const string &str);


FILE& operator>>(FILE& f,string &str);


/// time_t
FILE& operator<<(FILE& f,const time_t &t);


FILE& operator>>(FILE& f,time_t& t);


///  vector<T>
template <class T>
FILE& operator<<(FILE& f,const vector<T> &t);


template <class T>
FILE& operator>>(FILE& f,vector<T> &t);


@interface PlayerTrack (serialize)
-(void)saveTo:(FILE*)file;
-(void)loadFrom:(FILE*)file;
@end

@interface PlayerList (serialize)
-(void)saveTo:(FILE*)file;
-(void)loadFrom:(FILE*)file;
@end

@interface PlayerlList (serialize)
-(void)saveTo:(FILE*)file;
-(void)loadFrom:(FILE*)file;
@end


@interface PlayerDocument (serialize)
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



#endif