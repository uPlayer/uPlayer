//
//  PlayerLayout+MemoryFileBuffer.cpp
//  uPlayer
//
//  Created by liaogang on 15/4/9.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#include "PlayerLayout+MemoryFileBuffer.h"

NSData *dataFromMemoryFileBufferNoCopy(MemoryFileBuffer * buffer)
{
    return [[NSData alloc] initWithBytesNoCopy:(void*)buffer->getBytes() length:buffer->getLength()];
}

NSData *dataFromMemoryFileBuffer(MemoryFileBuffer * buffer)
{
    return [[NSData alloc] initWithBytes:(void*)buffer->getBytes() length:buffer->getLength()];
}

MemoryFileBuffer* newMemoryFileBufferFromData(NSData *data)
{
    return new MemoryFileBuffer((unsigned char*)data.bytes,(int)data.length);
}
