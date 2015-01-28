//
//  UPlayer.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface TrackInfo: NSObject
@property (nonatomic,strong) NSString *artist,*title,*album,*genre,*year;
@property (nonatomic,strong)NSString *path;
@end


#if defined(__cplusplus)
extern "C" {
#endif /* defined(__cplusplus) */
   
    
    TrackInfo* getId3Info(NSString *filename);
    
    NSArray* enumAudioFiles(NSString* path);
    
    
#if defined(__cplusplus)
}
#endif /* defined(__cplusplus) */


