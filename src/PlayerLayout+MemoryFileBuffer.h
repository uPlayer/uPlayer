//
//  PlayerLayout+MemoryFileBuffer.h
//  uPlayer
//
//  Created by liaogang on 15/4/9.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#ifndef __uPlayer__PlayerLayout_MemoryFileBuffer__
#define __uPlayer__PlayerLayout_MemoryFileBuffer__

#import <Cocoa/Cocoa.h>

#import "MemoryFileBuffer.h"

NSData *dataFromMemoryFileBuffer(MemoryFileBuffer * buffer);
NSData *dataFromMemoryFileBufferNoCopy(MemoryFileBuffer * buffer);
MemoryFileBuffer* newMemoryFileBufferFromData(NSData *data);


#endif /* defined(__uPlayer__PlayerLayout_MemoryFileBuffer__) */
