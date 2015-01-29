//
//  Last.fm.user
//  Last.fm
//
//  Created by liaogang on 15/1/4.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import "serialize.h"
#import "PlayerTrack.h"
#include <assert.h>

typedef char TCHAR;

/// int
FILE& operator<<(FILE& f,const int t)
{
    fwrite(&t,sizeof(int),1,&f);
    return f;
}

FILE& operator>>(FILE& f,int& t)
{
    fread(&t,sizeof(int),1,&f);
    return f;
}

/// char
//write zero terminated str array
FILE& operator<<(FILE& f,const TCHAR * str)
{
    int l=(int)strlen(str)+1;
    f<<l;
    fwrite(str,sizeof(TCHAR),l,&f);
    return f;
}

FILE& operator>>(FILE& f,TCHAR * str)
{
    int l=0;
    f>>l;
    fread(str,sizeof(TCHAR),l,&f);
    return f;
}

/// string
FILE& operator<<(FILE& f,const string &str)
{
    int l=(int)str.length();
    f<<l+1;
    fwrite(str.c_str(),sizeof(char),l,&f);
    char nullstr='\0';
    fwrite(&nullstr,sizeof(char),1,&f);
    return f;
}

FILE& operator>>(FILE& f,string &str)
{
    char buf[256];
    f>>buf;
    str=buf;
    return f;
}

/// time_t
FILE& operator<<(FILE& f,const time_t &t)
{
    fwrite(&t, sizeof(time_t), 1, &f);
    return f;
}

FILE& operator>>(FILE& f,time_t& t)
{
    fread(&t, sizeof(time_t), 1, &f);
    return f;
}

///  vector<T>
template <class T>
FILE& operator<<(FILE& f,const vector<T> &t)
{
    int length = (int)t.size();
    f<<length;
    for (int i = 0; i< length; i++)
    {
        f<<t[i];
    }
    return f;
}

template <class T>
FILE& operator>>(FILE& f,vector<T> &t)
{
    int length ;
    f>>length;
    
    for (int i = 0; i< length; i++)
    {
        T tt;
        f>>tt;
        t.push_back(tt);
    }
    
    return f;
}















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

