//
//  ThreadJob.m
//  uPlayer
//
//  Created by liaogang on 15/2/16.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import "ThreadJob.h"

typedef void (^JobBlock)();
typedef void (^JobBlockDone)();

dispatch_queue_t  _dispatchQueue  = nil;

void dojobInBkgnd(JobBlock job ,JobBlockDone done)
{
    if(_dispatchQueue == nil)
       _dispatchQueue = dispatch_queue_create("uPlayer", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(_dispatchQueue, ^{
        job();
        if (done)
            dispatch_async(dispatch_get_main_queue(), ^{
                done();
        });
    });
    
}

/// ~/Library/Application Support/uPlayer
NSString *ApplicationSupportDirectory()
{
    NSString *path = NSSearchPathForDirectoriesInDomains( NSApplicationSupportDirectory, NSUserDomainMask, true ).firstObject;
    
    path = [path stringByAppendingPathComponent:@"uPlayer"];
    
    BOOL isExist;
    BOOL isDirectory;
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    
    if (isExist )
    {
        if (!isDirectory)
        {
           /// @todo: remove this file.
           // isExist = false;
        }
    }

    if (!isExist)
    {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error) {
            NSLog(@"%@",error);
            return nil;
        }
    }
    

    
    return path;
}
