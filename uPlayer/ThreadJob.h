//
//  ThreadJob.m
//  uPlayer
//
//  Created by liaogang on 15/2/16.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^JobBlock)();
typedef void (^JobBlockDone)();
void dojobInBkgnd(JobBlock job ,JobBlockDone done)
{
    dispatch_queue_t  _dispatchQueue  = dispatch_queue_create("uPlayer", DISPATCH_QUEUE_SERIAL);
    dispatch_async(_dispatchQueue, ^{
        job();
        dispatch_async(dispatch_get_main_queue(), ^{
            if (done)
                done();
        });
    });
    
}