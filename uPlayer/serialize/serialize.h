//
//  Last.fm.h
//  Last.fm
//
//  Created by liaogang on 15/1/4.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//



#ifndef __seralize_h__
#define __seralize_h__

#include <cstdio>
#include <string>
#include <cstring>
#include <vector>


using namespace std;

    
/// int
FILE& operator<<(FILE& f,const int t);
FILE& operator>>(FILE& f,int& t);

/// float
FILE& operator<<(FILE& f,const float t);
FILE& operator>>(FILE& f,float& t);

/// char
//write zero terminated str array
FILE& operator<<(FILE& f,const char* str);
FILE& operator>>(FILE& f,char* str);


/// string
FILE& operator<<(FILE& f,const string &str);
FILE& operator>>(FILE& f,string &str);


/// time_t
FILE& operator<<(FILE& f,const time_t &t);
FILE& operator>>(FILE& f,time_t& t);




///  vector
template <class T>
FILE& operator<<(FILE& f,const vector<T> &t)
{
    int length = (int)t.size();
    f<<length;
    for (int i = 0; i< length; i++)
    {
        f<<t[i];
    }
    return f;
}


template <class T>
FILE& operator>>(FILE& f,vector<T> &t)
{
    int length ;
    f>>length;
    
    for (int i = 0; i< length; i++)
    {
        T tt;
        f>>tt;
        t.push_back(tt);
    }
    
    return f;
}

#endif
