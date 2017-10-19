//
//  lrcFch.cpp
//  lyricsFetcher
//
//  Created by liaogang on 7/7/14.
//  Copyright (c) 2014 gang.liao. All rights reserved.
//

#include "socketTool.h"

#include <string.h> //memset strcpy

#include <assert.h>
#include <stdlib.h>
#include <stdio.h>//fopen

#define  HTTP_PORT 80

/**
 * is in unix or win-nt
 */
#ifdef _WINDOWS
#include <winsock2.h> 
#pragma comment(lib,"WS2_32.lib") 
#else
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

#include <arpa/inet.h>
#include <errno.h>
#include <sys/socket.h>
#include <netdb.h>//gethostbyname
#include <unistd.h>//close

int GetLastError()
{
    return errno;
}
#endif


#ifdef _WINDOWS
BOOL MakeSureSocketStartUp()
{
	static BOOL bInit = FALSE;

	if (!bInit)
	{
		WSADATA data;
		int error;
		error = WSAStartup(MAKEWORD(2, 2), &data);
		if (error)
			bInit = FALSE;
		else
			bInit = TRUE;
	}
	return bInit;
}
#endif




BOOL CreateTcpSocketClient(const char *strHost , SOCKET *socketClient)
{
    BOOL bRet = FALSE ;
    
#ifdef _WINDOWS
	if (!MakeSureSocketStartUp())
	{
		return FALSE;
	}
#endif
    
    //fill socket addr struct
    SOCKADDR_IN sockaddrClient;
    memset((void*)&sockaddrClient,0,sizeof(sockaddrClient));
    sockaddrClient.sin_family=AF_INET;
    sockaddrClient.sin_port=htons(HTTP_PORT);
    
    
    //get host's ip address
    HOSTENT *host=gethostbyname(strHost);
    if (host)
    {
        if(host->h_addrtype == AF_INET)
        {
            sockaddrClient.sin_addr.s_addr=(in_addr_t)(*(u_long *) host->h_addr_list[0]);
            
            //create client socket
            *socketClient=socket(AF_INET,SOCK_STREAM,0);
            if (*socketClient!=INVALID_SOCKET )
            {

                //connect
                if(SOCKET_ERROR==connect(*socketClient,(const struct sockaddr*)&sockaddrClient,sizeof(sockaddrClient)))
                {
                    printf("connect error : %d \n", GetLastError() );
                }
                else
                {
                    bRet = TRUE;
                }
            }
            else
            {
                printf("create socket failed.\n");
                //DWORD error=GetLastError();
            }
        }
    }
    else
    {
        printf("can not find the host's address.\n");
    }
    
    return  bRet;
}



unsigned long sendDataToSocket(SOCKET socket , unsigned char *buffer , unsigned long bufLen)
{
    unsigned long send=0,totalsend=0;
    for (;(send=::send(socket,(const char*)buffer+totalsend,bufLen-totalsend,0))>0;totalsend+=send);
    return totalsend;
}



///return bytes writed to file.
int writeHttpContent2(SOCKET socketDownload, FILE *pFile )
{
    int  bytesWrited = 0 ;
    //recv data
    char *buf = NULL;
    const int RECV_BUF_LEN =2600;
    buf=(char*)malloc(RECV_BUF_LEN);
    if (buf)
    {
        size_t byteRecv=0;
        byteRecv=recv(socketDownload,buf,RECV_BUF_LEN,0);
        if(recv>0)
        {
            const char find1[]="HTTP/1.";//1.1 or 1.0
            const char find2[]=" 200 OK";
            const char constContentLength[] = "\r\nContent-Length: ";
            const char constBreakLine[] = "\r\n\r\n";
            
            int iContentLength=0;
            const int  find1Len = sizeof(find1)/sizeof(find1[0])-1;
            const int find2Len =sizeof(find2)/sizeof(find2[0])-1;
            if (strncmp(buf, find1, find1Len ) == 0 &&
                strncmp(buf + find1Len + 1, find2, find2Len ) == 0
                )
            {
                ////find Content-Length and \r\n\r\n
                char *contentLength = strstr(buf, constContentLength);
                char *breakLine = strstr(buf, constBreakLine);
                
                if (contentLength)
                {
                    contentLength += sizeof(constContentLength)/sizeof(constContentLength[0]) -1;
                    
                    
                    char *p = strchr(contentLength, '\r');
                    
                    char tmp [20] = {0};
                    strncpy(tmp, contentLength , (int) (p - contentLength)) ;
                    iContentLength = atoi(tmp);
                    
                    if (breakLine)
                    {
                        breakLine+=sizeof(constBreakLine)/sizeof(constBreakLine[0])-1;
                        
                        int contentLengthRecv = (int)(buf + byteRecv - breakLine);
                        fwrite( breakLine , sizeof(buf[0]) ,  contentLengthRecv ,pFile);
                        
                        while (contentLengthRecv < iContentLength )
                        {
                            byteRecv=recv(socketDownload , buf  , iContentLength - contentLengthRecv , 0 );
                            
                            contentLengthRecv += byteRecv ;
			
			    fwrite( buf  , sizeof(buf[0]) ,  byteRecv , pFile );
                        }
                        
                        
                        bytesWrited = iContentLength ;
                    }
                    else
                    {
                        printf("http error ,haven't find \"\r\n\r\n\" \n");
                    }
                }
                else
                {
                    printf("http error, haven't find \"Content-Length\"\n");
                }
            }
            else
            {
                printf("http error.\n");
            }
        }
        else
        {
            printf ("recv nothing from server.\n " );
        }
        
        free(buf);
    }
    else
    {
        printf("malloc error \n ");
    }
    
    return bytesWrited;
}

MemBuffer *newMemBuffer(int len)
{
    MemBuffer *buffer=(MemBuffer*)malloc( sizeof(MemBuffer) + len);
    buffer->length = len;
    return buffer;
}

void deleteMemBuffer(MemBuffer *buffer)
{
    free(buffer);
}

MemBuffer* recvSocketData(SOCKET socketDownload )
{
    MemBuffer * resultBuffer = nullptr;
    
    char *buf = NULL;
    const int RECV_BUF_LEN = 8000;
    buf=(char*)malloc(RECV_BUF_LEN);
    if (buf)
    {
        size_t byteRecv=0;
        byteRecv=recv(socketDownload,buf,RECV_BUF_LEN,0);
        if(byteRecv>0)
        {
            /**
             When an Entity-Body is included with a message, the length of that body may be determined in one of two ways. If a Content-Length header field is present, its value in bytes represents the length of the Entity-Body. Otherwise, the body length is determined by the closing of the connection by the server.
             */
            
            const char find1[]="HTTP/1.";//1.1 or 1.0
            const char find2[]=" 200 OK";
            const char constContentLength[] = "\r\nContent-Length: ";
            const char constBreakLine[] = "\r\n\r\n";
            
            int iContentLength=0;
            const int  find1Len = sizeof(find1)/sizeof(find1[0])-1;
            const int find2Len =sizeof(find2)/sizeof(find2[0])-1;
            if (strncmp(buf, find1, find1Len ) == 0 )
            {
                if(strncmp(buf + find1Len + 1, find2, find2Len ) == 0
                   )
                {
                    ////find Content-Length and \r\n\r\n
                    char *contentLength = strstr(buf, constContentLength);
                    char *breakLine = strstr(buf, constBreakLine);
                    
                    if (contentLength)
                    {
                        contentLength += sizeof(constContentLength)/sizeof(constContentLength[0]) -1;
                        
                        
                        char *p = strchr(contentLength, '\r');
                        
                        char tmp [20] = {0};
                        strncpy(tmp, contentLength , (int) (p - contentLength)) ;
                        iContentLength = atoi(tmp);
                        
                        if (breakLine)
                        {
                            breakLine+=sizeof(constBreakLine)/sizeof(constBreakLine[0])-1;
                            
                            resultBuffer= newMemBuffer(iContentLength);
                            
                            int contentLengthRecv = (int)(buf + byteRecv - breakLine);
                            memcpy(resultBuffer->buffer, breakLine , contentLengthRecv * sizeof(buf[0]) );
                            
                            
                            while (contentLengthRecv < iContentLength )
                            {
                                byteRecv=recv(socketDownload ,(char*) resultBuffer->buffer + contentLengthRecv , iContentLength - contentLengthRecv , 0 );
                                
                                contentLengthRecv += byteRecv ;
                            }
                            
                            
                        }
                        else
                        {
                            printf("http error ,haven't find \"\r\n\r\n\" \n");
                        }
                    }
                    else
                    {
                        if (breakLine)
                        {
                            breakLine+=sizeof(constBreakLine)/sizeof(constBreakLine[0])-1;
                            // read till the end.
                            const int bufferLength = 90000;
                            resultBuffer = newMemBuffer(bufferLength);
                            
                            int contentLengthRecv = (int)(buf + byteRecv - breakLine);
                            memcpy(resultBuffer->buffer, breakLine , contentLengthRecv * sizeof(buf[0]) );
                            
                            int contentBytesRecvTotal = contentLengthRecv;
                            for(int contentBytesRecv= 1 ; contentBytesRecv > 0 && contentBytesRecvTotal <= bufferLength;  )
                            {
                                contentBytesRecv = (int)recv(socketDownload ,(char*) resultBuffer->buffer + contentBytesRecvTotal , bufferLength - contentBytesRecvTotal , 0 );
                                contentBytesRecvTotal += contentBytesRecv;
                            }
                            
                            printf("http 1.0, bytes received: %zd \n",contentBytesRecvTotal);
                            
                            if (bufferLength == contentBytesRecvTotal)
                                printf("but response is too long , some was skipped. \n");
                            
                        }
                    }
                }
                else
                {
                    char tmp[4]={0};
                    strncpy(tmp,  buf + find1Len + 2, 3);
                    printf("http error. error code: %s\n",tmp);
                }
            }
            else
            {
                printf("http error.can not find `http header`.\n");
            }
        }
        else
        {
            printf ("recv nothing from server.\n " );
        }
        
        free(buf);
    }
    else
    {
        printf("malloc error \n ");
    }
    
    
    return resultBuffer;
}


int writeHttpContent(SOCKET httpResponse , const char *savepath )
{
    int bytesWrited= 0;
    
    FILE * pFile;
    pFile = fopen( savepath , ("w") );
    if (pFile)
    {
        bytesWrited=  writeHttpContent2(httpResponse, pFile) ;
        fclose(pFile);
    }
    else
    {
        printf("can not open file to write. %s",savepath);
    }
    
    
    return bytesWrited;
}



const char curlUrlFileHeaderFormat[] =
"GET %s HTTP/1.1\r\n"
"Connection: Keep-Alive\r\n"
"Host: %s\r\n"
"\r\n\r\n";

const size_t curlUrlFileHeaderFormatLen = sizeof(curlUrlFileHeaderFormat)/sizeof(curlUrlFileHeaderFormat[0]) -1;
const size_t curlUrlFileHeaderFormatSLen = 4; //lenght of %s in above.

int curlUrlFile(const char *url , const char *savepath)
{
    int bytesWrited= 0;
    const char protocol[] = "http://";
    const size_t protocolLen = (sizeof(protocol)/sizeof(protocol[0])-1) ;
    char host[40] = {0};
    const char *path = 0 ;
    
    if (strstr(url, protocol))
    {
        //sub string host
        const char *hostBegin,*hostEnd;
        hostBegin=url + protocolLen  ;
        
        if (hostBegin)
        {
            hostEnd = strchr(hostBegin, '/');
            if (hostEnd)
            {
                strncpy(host, hostBegin, hostEnd-hostBegin);
                path = hostEnd;
                if (path)
                {
                    SOCKET socketClient;
                    if(CreateTcpSocketClient(host, &socketClient) )
                    {
                        size_t strLen=curlUrlFileHeaderFormatLen - curlUrlFileHeaderFormatSLen + strlen(url) - protocolLen ;
                        void *sendStr=malloc(strLen);
                        sprintf((char*)sendStr,curlUrlFileHeaderFormat,path,host);
                        
                        //send data
                        size_t bytesSend=0,totalsend=0;
                        for (;(bytesSend=send(socketClient,(char*)sendStr+totalsend,strLen-totalsend,0))>0;totalsend+=bytesSend);
                        
                        if (totalsend)
                        {
                            bytesWrited = writeHttpContent (socketClient , savepath );
                        }
                        
                        free(sendStr);
                    }
                }
            }
        }
    }
    else
    {
        printf("protocol error.");
    }
    

    return bytesWrited;
}




