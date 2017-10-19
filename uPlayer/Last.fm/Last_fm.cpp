//
//  Last.fm
//
//  Created by liaogang on 15/1/4.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#include "Last_fm.h"
#include <cstring> // strcat
#include <assert.h>
#include <json/json.h>



using namespace std;



LFArtist::LFArtist(){}
LFArtist::LFArtist(Json::Value &parent, bool complete):LFArtistBasic(parent["artist"])
{
    Json::Value jvArtist = parent["artist"];
    
    assert(jvArtist.type() == Json::objectValue );
    
    text = jvArtist["#text"].asString();
    mbid = jvArtist["mbid"].asString();
    
    if (complete)
    {
        stats = LFStats(jvArtist);
        
        similarArtist = LFSimilarArtist(jvArtist);
        
        tags = LFTags(jvArtist);
        
        bio = LFBio(jvArtist);
    }
}



LFTrack::LFTrack(){}

LFTrack::LFTrack(Json::Value &parent)
{
    Json::Value dicTrack = parent;
    
    id = dicTrack["id"].asString();
    name = dicTrack["name"].asString();
    mbid = dicTrack["mbid"].asString();
    url = dicTrack["url"].asString();
    duration = dicTrack["duration"].asString();
    //streamable = dicTrack["streamable"].asString();
    listeners = dicTrack["listeners"].asString();
    playcount = dicTrack["playcount"].asString();
    artist = LFArtist(dicTrack,false) ;
    //toptags = dicTrack["toptags"].asString();
    loved = dicTrack["loved"].asString();
    image = LFImage(dicTrack);
};


