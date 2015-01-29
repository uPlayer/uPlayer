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
#import "serialize.h"


const char filePath[] = "/Users/liaogang/uPlayer.document";


@interface PlayerDocument ()
@end


@implementation PlayerDocument

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        self.windowName = NSLocalizedString(@"uPlayer windows name", nil);
        
    }
    
    return self;
}


-(bool)load
{
    FILE *file = fopen(filePath, "r");
    if (file)
    {
        *file >> _resumeAtReboot  >> _volume >> _playOrder >> _playListIndex >> _trackIndex >> _playStatus >> _fontHeight;
        
        _trackInfoList =  loadTrackInfoArray(*file);
        
        fclose(file);
        return true;
    }
    
    return false;
}

-(bool)save
{
    FILE *file = fopen(filePath, "w");
    if (file)
    {
        
        *file << _resumeAtReboot  << _volume << _playOrder << _playListIndex << _trackIndex << _playStatus << _fontHeight;
        
         saveTrackInfoArray(*file , _trackInfoList);
        
        fclose(file);
        return true;
    }
    
    return false;
}


@end

