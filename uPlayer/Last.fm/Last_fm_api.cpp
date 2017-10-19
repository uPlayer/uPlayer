//
//  Last.fm
//
//  Created by liaogang on 15/1/4.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#include "Last_fm_api.h"
#include <cstdio> //sprintf
#include <cstring> // strcat
#include <assert.h>
#include <iostream>
#include "md5.h"

#ifdef _WINDOWS
#include "time.h"
#include <algorithm>
#endif


using namespace std;

const char lastFmPath[]="/2.0/";
const char lastFmHost[] = "ws.audioscrobbler.com" ;
const char lastFmLang[10] ="zh";

const int klen = 32 + sizeof('\0');
char lastFmApiKey[klen] = "6ef0a182fcb172b557c0ca096594f288";
char lastFmSecret[klen] = "3b1a4e1e970ed3a30c28cd65bb88579c";

void setLastFmApiKey(const char *apikey)
{
    strncpy(lastFmApiKey, apikey, 32);
}

void setLastFmSecret(const char *secret)
{
    strncpy(lastFmSecret, secret, 32);
}

/// a param and it's value.
struct paramPair
{
    string param;
    string value;
    paramPair(string p , string v):param(p),value(v)
    {
        
    }
};

enum httpMethod
{
    httpMethod_post,
    httpMethod_get
};

const char *arrHttpMethod[] = {"POST","GET"};

bool cmp(paramPair a,paramPair b)
{
    return strcmp( a.param.c_str() ,b.param.c_str() ) < 0;
}


MemBuffer* lastFmSendRequest(vector<paramPair> arrParamPairs, httpMethod  method , bool mkMd5, bool useJsonFormat );


bool artist_getInfo(string &artist ,LFArtist &lfArtist)
{
    bool result = false;
    
    vector<paramPair> arrParamPair
    (
     {
         {"artist", artist},
         {"autocorrect","1"},
         {"lang",lastFmLang},
         {"method","artist.getInfo"}
     }
     );
    
    MemBuffer *buffer = lastFmSendRequest(arrParamPair ,httpMethod_get ,false,  true );
    
    if (buffer)
    {
        Json::Reader reader;
        Json::Value root;
        
        reader.parse((const char*)buffer->buffer, (const char*)buffer->buffer+buffer->length , root);
        
        lfArtist = LFArtist( root , true);
        
        result = true;
        
        deleteMemBuffer(buffer);
    }
    
    return result;
}



bool track_getInfo(string &artist , string & track, LFTrack &lfTrack)
{
    vector<paramPair> arrParamPair
    (
     {
        {"artist", artist},
        {"autocorrect","1"},
        {"method","track.getInfo"},
        {"lang",lastFmLang},
        {"track", track}
     }
     );
    
   
    MemBuffer *buffer = lastFmSendRequest(arrParamPair , httpMethod_get ,false,  true);
    
    if (buffer)
    {
#ifdef DEBUG
        printf("%s\n",buffer->buffer);
#endif
        
        //parse it by json.
        Json::Reader reader;
        Json::Value root;
        reader.parse((const char*)buffer->buffer, (const char*)buffer->buffer+buffer->length , root);
        
        lfTrack = LFTrack(root["track"]);
        
        deleteMemBuffer(buffer);
        
        return true;
    }
    
    return false;
}


bool auth_getToken( string &token )
{    vector<paramPair> arrParamPair
    (
     {

        {"method","auth.gettoken"},
     }
     );
 
   
    MemBuffer *buffer = lastFmSendRequest( arrParamPair ,httpMethod_get ,true, true);
    
    if (buffer)
    {
#ifdef DEBUG
        printf("%s\n",buffer->buffer);
#endif
        
        //parse it by json.
        Json::Reader reader;
        Json::Value root;
        reader.parse((const char*)buffer->buffer, (const char*)buffer->buffer+buffer->length , root);
        
        token = root["token"].asString();
        
        deleteMemBuffer(buffer);
        
        return true;
    }
    
    return false;
}


void openWebInstance(const string &token)
{
    //    http://www.last.fm/api/auth/?api_key=xxxxxxxxxx&token=yyyyyy
    
    string url="open \"http://www.last.fm/api/auth/?api_key=";
    url+=lastFmApiKey;
    url+="&token=";
    url+=token;
    url+="\"";
    
    system(url.c_str());
}

bool auth_getSession(string &token,string &sessionKey,string &userName)
{    vector<paramPair> arrParamPair
    (
     {
        {"method","auth.getSession"},
        {"token",token}
     }
     );
 
    
    /// this api has a bug , if using json format.
    /// @see http://cn.last.fm/group/Last.fm+Web+Services/forum/21604/_/428269
    
    MemBuffer *buffer = lastFmSendRequest(arrParamPair ,httpMethod_get , true ,  false);
    
    if (buffer)
    {
#ifdef DEBUG
        printf("%s\n",buffer->buffer);
#endif
        
        //parse it by json.
        Json::Reader reader;
        Json::Value root;
        reader.parse((const char*)buffer->buffer, (const char*)buffer->buffer+buffer->length , root);
        
        Json::Value v = root["session"];
        
        sessionKey = v["key"].asString();
        
        userName = v["name"].asString();
        
        deleteMemBuffer(buffer);
        
    }
    
    
    bool sessionCreated = (sessionKey.length() == sessionKeyLength) && userName.length() > 0;
    
    return sessionCreated;
}

bool track_love(string &sessionKey, string &artist , string & track )
{
    bool result = false;
    
    vector<paramPair> arrParamPair
    (
     {
        {"artist", artist},
        {"method","track.love"},
        {"sk", sessionKey},
        {"track", track }
     }
     );
    
    MemBuffer *buffer = lastFmSendRequest(arrParamPair ,httpMethod_post ,true ,  true);
    
    if (buffer)
    {
#ifdef DEBUG
        printf("%s\n",buffer->buffer);
#endif
        
        //parse it by json.
        Json::Reader reader;
        Json::Value root;
        reader.parse((const char*)buffer->buffer, (const char*)buffer->buffer+buffer->length , root);
        
        
        // check error now
        if (root["error"].isNull())
        {
            result = true;
        }
        
        
        deleteMemBuffer(buffer);
    }
    
    return result;
}



bool track_updateNowPlaying(string &sessionKey, string &artist,string &track)
{
    bool result = false;
    
    vector<paramPair> arrParamPair
    (
     {
         {"artist", artist},
         {"method","track.updateNowPlaying"},
         {"sk", sessionKey},
         {"track", track }
     }
     );
    
    MemBuffer *buffer = lastFmSendRequest(arrParamPair ,httpMethod_post ,true ,  true);
    
    if (buffer)
    {
#ifdef DEBUG
        printf("%s\n",buffer->buffer);
#endif
        
        result = true;
        deleteMemBuffer(buffer);
    }
    
    
    return result;
}

bool track_scrobble(vector<paramPair> &arrParamPair)
{
    bool result = false;
    MemBuffer *buffer = lastFmSendRequest(arrParamPair ,httpMethod_post ,true ,  true);
    
    if (buffer)
    {
#ifdef DEBUG
        printf("%s\n",buffer->buffer);
#endif
        
        Json::Reader reader;
        Json::Value root;
        reader.parse((const char*)buffer->buffer, (const char*)buffer->buffer+buffer->length , root);
        
        root = root["scrobbles"];
        
        if (root != Json::nullValue)
            result = true;
        
        deleteMemBuffer(buffer);
    }
    
    
    return result;
}

bool track_scrobble(string &sessionKey, LFTrackRecords &records)
{
    size_t size = records.records.size();
    
    if(size==0)
    {
        return 1;
    }
    else if (size==1)
    {
        track_scrobble(sessionKey,records.records[0].artist,records.records[0].track,records.records[0].time);
    }
    else if(size>50)
    {
        size = 50;
    }
    
    vector<paramPair> arrParamPair
    ({
        {"method","track.scrobble"},
        {"sk", sessionKey},
    });
    
    for (size_t i = 0; i < size; i++)
    {
        LFTrackRecord record= records.records[i];
        
        string paramArtist="artist[";
        string paramTrack="track[";
        string paramTimestamp="timestamp[";
        
        char num[2]={0};
        sprintf(num, "%d" , (int)i);
        
        paramArtist+=num;
        paramTrack+=num;
        paramTimestamp+=num;
        
        
        paramArtist+="]";
        paramTrack+="]";
        paramTimestamp+="]";
        
        arrParamPair.push_back({paramArtist,record.artist});
        arrParamPair.push_back({paramTrack,record.track});
        char tmp[20]={0};
        sprintf(tmp, "%ld",record.time);
        arrParamPair.push_back({paramTimestamp,string(tmp)});
    }
    
    if(size>50)
    {
        auto beg = records.records.begin();
        auto end = records.records.end();
        records.records=vector<LFTrackRecord>(beg+50,end);
    }

    return track_scrobble(arrParamPair);
}

bool track_scrobble(string &sessionKey, string &artist,string &track,time_t timestamp)
{
    time_t t;
    time(&t);
    char tmp[20]={0};
    sprintf(tmp, "%ld",t);
    
    string strTime=tmp;
    return track_scrobble(sessionKey, artist, track, strTime);
}

bool track_scrobble(string &sessionKey, string &artist,string &track,string &timestamp)
{
    vector<paramPair> arrParamPair
    ({
        {"artist", artist},
        {"method","track.scrobble"},
        {"sk", sessionKey},
        {"timestamp", timestamp},
        {"track", track },
    });
    
    return track_scrobble(arrParamPair);
}

bool track_scrobble(string &sessionKey, string &artist,string &track)
{
    time_t t;
    time(&t);

    return track_scrobble(sessionKey,artist,track,t);
}

bool user_getRecentTracks(const string &username , vector<LFTrack> &tracks)
{
    bool result = false;
    
    vector<paramPair> arrParamPair
    ({
        {"extended","1"},
        {"limit","200"},
        {"method","user.getRecentTracks"},
        {"user", username}
    });
    
    MemBuffer *buffer = lastFmSendRequest(arrParamPair ,httpMethod_get , false,  true);
    
    if (buffer)
    {
#ifdef DEBUG
        printf("%s\n",buffer->buffer);
#endif
        
        Json::Reader reader;
        Json::Value root;
        reader.parse((const char*)buffer->buffer, (const char*)buffer->buffer+buffer->length , root);
        
        Json::Value arr = root["recenttracks"]["track"];
        
        int arrLength = arr.size();
        
        for (int i= 0; i < arrLength; i++) {
            Json::Value v = arr[i];
            LFTrack t(v);
            
            tracks.push_back( t );
        }
        
        
        result = true;
        deleteMemBuffer(buffer);
    }
    
    
    return result;
}




string utf8code(string &str)
{
    unsigned char buffer2[256]={0};
    
    size_t length = str.length();
    int ii=0;
    for ( size_t i = 0; i < length; i++)
    {
        unsigned char a = str[i];
        
        if (isalnum(a) || ispunct(a) )
        {
            buffer2[ii++]=a;
        }
        else
        {
            buffer2[ii++]='%';
            sprintf((char*)buffer2+ii,"%X",a);
            ii+=2;
        }
    }
    
    return string((const char*)buffer2,(size_t)strlen((const char*)buffer2));
}

/** return server's response content if have. else nullptr is returned.
 */
MemBuffer* lastFmSendRequest(vector<paramPair> arrParamPairs, httpMethod  method , bool mkMd5, bool useJsonFormat )
{
    size_t numParamPairs = arrParamPairs.size();
    
    assert(numParamPairs>=1);
    
    string strParams;
    
    arrParamPairs.insert(arrParamPairs.begin(), {"api_key",lastFmApiKey});
    numParamPairs++;
    
    sort(arrParamPairs.begin(), arrParamPairs.end(), cmp);
    
    if (mkMd5)
    {
        string strMD5;
        for( int i = 0; i< numParamPairs; i++)
        {
            paramPair pPP = arrParamPairs[i];
            
            strMD5+=pPP.param;
            strMD5+=pPP.value;
        }
        
        strMD5+= lastFmSecret;
        
        arrParamPairs.push_back({"api_sig",md5(strMD5)});
        numParamPairs++;
        sort(arrParamPairs.begin(), arrParamPairs.end(), cmp);
    }
    
    
    arrParamPairs.push_back( {"format","json"} );
    numParamPairs++;
    sort(arrParamPairs.begin(), arrParamPairs.end(), cmp);
    

    for( int i = 0; i< numParamPairs; i++)
    {
        paramPair pPP = arrParamPairs[i];
        
        if(i!=0)
            strParams+='&';
        
        strParams+=pPP.param;
        strParams+='=';
        /// convert param value from utf8 to utf8 code (eaaf --> %ea%af)
        strParams+=utf8code( pPP.value );
    }
    
    
    const int senderHeaderLenMax = 2048;
    
    unsigned char senderHeader[senderHeaderLenMax];
const char senderHeaderFormatter[] =
"%s %s?%s HTTP/1.1\r\n\
Connection: Keep-Alive\r\n\
Accept-Language: zh-CN,en,*\r\n\
Host: %s\r\n\
\r\n";
    
    
    sprintf( (char*) senderHeader, senderHeaderFormatter ,arrHttpMethod[method]  , lastFmPath , strParams.c_str() , lastFmHost );
    
    size_t senderHeaderLen = strlen((char*)senderHeader);
    
#ifdef DEBUG
    printf("%s\n",senderHeader);
#endif
    
    int socketClient;
    if(CreateTcpSocketClient(lastFmHost  , &socketClient) )
    {
        if(  sendDataToSocket(socketClient, senderHeader, senderHeaderLen) == senderHeaderLen )
        {
            MemBuffer *socketBuf = recvSocketData(socketClient);
            closesocket(socketClient);
            return socketBuf;
        }
        
    }
    
    return nullptr;
}


