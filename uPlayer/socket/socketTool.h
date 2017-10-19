/**
* lrcFch.h
* lyricsFetcher

*Created by liaogang on 7/7/14.
*Copyright (c) 2014 gang.liao. All rights reserved.
*/

#ifndef __HEADER_SOCKET_TOOL_H__
#define __HEADER_SOCKET_TOOL_H__


/**
 * is in unix or win-nt
 */
#ifndef _WINDOWS 
#include "stdio.h"
#include <unistd.h>
#include <sys/types.h>
#include <netinet/in.h>//sockaddr_in
typedef unsigned int UINT;
#define FALSE (0)
#define TRUE  (1)
#define BOOL INT
#define INT int
#define SOCKET int
#define HOSTENT hostent
#define INVALID_SOCKET  (-1)
#define SOCKET_ERROR    (-1)
#define SOCKADDR_IN sockaddr_in
#define closesocket(s) close(s)
#define _tcslen wcslen
#define _T(x) L##x
#else
#include "stdafx.h"
#endif

/// a block of memory data.
struct MemBuffer
{
    unsigned long length;
    unsigned char buffer[0];
};
MemBuffer *newMemBuffer(int len);
void deleteMemBuffer(MemBuffer *buffer);


int GetLastError();

BOOL CreateTcpSocketClient(const char *strHost , SOCKET *socketClient);

/**
 Send a block of data to server.@return: number of bytes sended.
 */
unsigned long sendDataToSocket(SOCKET socket , unsigned char *buffer , unsigned long bufLen);



/** 
 Create a socket client to receive data from server.
 @function: recvSocketData,the data cached in memory.
 @function: writeHttpContent,the data save to `savepath`.
 @function: writeHttpContent2,the data save to 'FILE`.
 @return: number of bytes sended.
 */
MemBuffer* recvSocketData(SOCKET socket );
int writeHttpContent(SOCKET httpResponse , const char *savepath );
int writeHttpContent2(SOCKET socketDownload, FILE *pFile );

/** 
 Send a http get request to curl `url` file from server.
 Receive data will be download to `savepath` gived.
 @return: number of bytes sended.
 */
int curlUrlFile(const char *url , const char *savepath);



#endif
