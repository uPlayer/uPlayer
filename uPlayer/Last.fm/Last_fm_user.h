//
//  Last.fm
//
//  Created by liaogang on 15/1/4.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//
#include <string>
#include <vector>

#ifndef __Last_fm__Last_fm_user__
#define __Last_fm__Last_fm_user__

using namespace std;

class LFUser
{
public:
    LFUser():isConnected(false){};
    
    string name;
    string sessionKey;
    
    bool isConnected;
};

void setUserProfilePath(const char* path);

bool authLocal(LFUser &user);

bool auth(LFUser &user, bool remote , bool &stop);

void clearSession(LFUser &user);

LFUser* lastFmUser();

#endif
