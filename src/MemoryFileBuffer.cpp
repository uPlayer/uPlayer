//
//  MemoryFileBuffer.cpp
//  uPlayer
//
//  Created by liaogang on 15/4/9.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#include "MemoryFileBuffer.h"
#include <string.h>
#include <assert.h>
#include <stdio.h>

MemoryFileBuffer::MemoryFileBuffer(int maxSize):length(0),maxSize(maxSize)
{
    bytes = (unsigned char*)malloc(maxSize);
    currWrite = currRead = bytes;
}


MemoryFileBuffer::MemoryFileBuffer(unsigned char *_bytes , int _length)
{
    maxSize = length = _length;
    
    bytes = (unsigned char*)malloc(length);;
    memcpy(bytes, _bytes, length);
    currWrite = currRead = bytes;
}













