//
//  Last.fm
//
//  Created by liaogang on 15/1/4.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#ifndef __Last_fm__Last_fm___
#define __Last_fm__Last_fm___

#include <string>
#include <json/json.h>
#include "socketTool.h"
#include <assert.h>

using namespace std;


struct LFBio
{
    string links,published,summary;
    LFBio(){}
    LFBio(Json::Value &parent)
    {
        Json::Value v = parent["bio"];
        assert(v.type() == Json::objectValue);
        published = v["published"].asString();
        summary = v["summary"].asString();
    }
};

struct LFStats
{
    string listeners,playcount;
    
    LFStats(){}
    
    LFStats(Json::Value &parent)
    {
        Json::Value jv = parent["stats"];
        
        assert(jv.type() == Json::objectValue);
        
        listeners = jv["listeners"].asString();
        
        playcount = jv["playcount"].asString();
        
    }
};



struct LFTag
{
    string name;
    string url;
    LFTag()
    {
        
    }
    
    LFTag(Json::Value &v)
    {
        assert(v.type() == Json::objectValue);
        
        name = v["name"].asString();
        
        url = v["url"].asString();
    }
};


struct LFTags
{
    vector<LFTag> tags;
    
    LFTags()
    {
        
    }
    
    LFTags(Json::Value &parent)
    {
        Json::Value jv = parent["tags"];
        
        //assert(jv.type() == Json::arrayValue);
        
        Json::Value arr = jv["tag"];
        
        for( auto i = arr.begin() ; i != arr.end(); i++ )
        {
            Json::Value v = *i;
            LFTag tag(v);
            tags.push_back(tag);
        }
        
    }
};


struct LFImage
{
    string imageSmall,imageMedium,imageLarge,imageExtraLarge,imageMega;
    
    LFImage(){}
    LFImage(Json::Value &parent)
    {
        Json::Value jvImage = parent["image"];
        
        if(jvImage.type() == Json::arrayValue)
        {
            int length = jvImage.size();
            for( int i =0; i < length; i++)
            {
                string size = jvImage[i]["size"].asString();
                string image = jvImage[i]["#text"].asString();
                
                if( size == "small")
                    imageSmall = image;
                else if( size == "medium")
                    imageMedium = image;
                else if( size == "large")
                    imageLarge = image;
                else if( size == "extralarge")
                    imageExtraLarge = image;
                else if( size == "mega")
                    imageMega = image;
            }
        }
    }
};


struct LFArtistBasic
{
    string name,mbid,url;
    LFImage image;
    
    LFArtistBasic(){}
    LFArtistBasic(Json::Value &v)
    {
        name = v["name"].asString();
        mbid = v["mbid"].asString();
        url = v["url"].asString();
        
        image = LFImage(v);
    }
};

struct LFSimilarArtist
{
    vector<LFArtistBasic> artists;
    LFSimilarArtist(){}
    LFSimilarArtist(Json::Value &parent)
    {
        Json::Value v = parent["similar"]["artist"];
        
        int length = v.size();
        for(int i=0; i< length; i++)
        {
            Json::Value v2 = v[i];
            LFArtistBasic ab(v2);
            artists.push_back(ab);
        }
    }
};



struct LFArtist:public LFArtistBasic
{
    string text,mbid;
    
    LFStats stats;
    LFSimilarArtist similarArtist;
    LFTags tags;
    LFBio bio;
    
    LFArtist();
    LFArtist(Json::Value &parent, bool complete);
};

struct LFAlbum
{
    string text,mbid;
    LFAlbum(){}
    LFAlbum(Json::Value &v)
    {
        text = v["#text"].asString();
        mbid = v["mbid"].asString();
    }
};

struct LFTrack
{
    string id,name,mbid,url,duration,streamable,listeners,playcount;
    string loved;
    LFArtist artist;
    string toptags;
    
    LFImage image;
    
    LFTrack();
    LFTrack(Json::Value &jvTrack);
};




#endif
