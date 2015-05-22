//
//  MemoryFileBuffer.h
//  uPlayer
//
//  Created by liaogang on 15/4/9.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#ifndef __uPlayer__MemoryFileBuffer__
#define __uPlayer__MemoryFileBuffer__

#include <stdlib.h>
#include <assert.h>
#include <stdio.h>
#include <string.h>

class MemoryFileBuffer
{
private:
    unsigned char *bytes;
    unsigned char *currRead;
    unsigned char *currWrite;
    int length;
    int maxSize;
public:
    MemoryFileBuffer(int maxSize);
    MemoryFileBuffer(unsigned char *bytes , int length);
    
    
    ~MemoryFileBuffer()
    {
        free(bytes);
    }
    
    const void *getBytes()
    {
        return bytes;
    }
    
    int getLength()
    {
        return length;
    }
    
    /// Read a object on current position to t.
    template<class T>
    void read(T &t)
    {
        t = ((T*)currRead)[0];
        
        currRead += sizeof(T);
        
        assert(currRead <=bytes+length);
    }
    
    /// Write t to current posiiton.
    template<class T>
    void write(T t)
    {
        if ( sizeof(T) > maxSize - length)
        {
            int newMaxSize = maxSize + maxSize/2;
            unsigned char* newBytes = (unsigned char*)malloc(newMaxSize);
            
            memcpy(newBytes,bytes,length);
            
            currWrite = currWrite - bytes + newBytes;
            currRead = currRead - bytes + newBytes;
            
            free(bytes);
        }
        
        
        ((T*)currWrite)[0] = t;
        
        currWrite += sizeof(T);
        
        length += sizeof(T);
    }
};



template <class T>
MemoryFileBuffer& operator<<(MemoryFileBuffer& mfb,T &t) {
    mfb.read<T>(t);
    return mfb;
}


template <class T>
MemoryFileBuffer& operator>>(MemoryFileBuffer& mfb,double t) {
    mfb.write<double>(t);
    return mfb;
}


#endif /* defined(__uPlayer__MemoryFileBuffer__) */
