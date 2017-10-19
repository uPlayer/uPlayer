//
//  Last.fm
//
//  Created by liaogang on 15/1/4.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#include "Last_fm_user.h"
#include "Last_fm_api.h"

#ifdef _WINDOWS
#include "serializeBase.h"
#else
#include "serialize.h"
#endif



char userProfile[256] ="lastFmUser.cfg";

void setUserProfilePath(const char* path)
{
    strcpy( userProfile, path );
}

/// load it from cached file if has, else create a new session again.
bool auth(LFUser &user , bool remote , bool &stop)
{
    bool userProfileLoaded = false;
    
    FILE *file = fopen(userProfile, "r");
    if (file)
    {
        fseek(file, 0, SEEK_END );
        if(ftell(file)>sessionKeyLength)
        {
            fseek(file, 0, SEEK_SET);
            
            *file >> user.name >> user.sessionKey;
    
            userProfileLoaded = true;
        }
        fclose(file);
    }
    
    
    if ( remote && userProfileLoaded == false)
    {
        string token;
        if(auth_getToken( token ) )
        {
            openWebInstance(token);
            
            while ( !stop  )
            {
                if(auth_getSession(token,user.sessionKey ,user.name))
                {
                    userProfileLoaded = true;
                    
                    // save sessionKey and userName to file.
                    
                    FILE *file = fopen(userProfile, "w");
                    if (file)
                    {
                        *file << user.name << user.sessionKey;
                        
                        fclose(file);
                    }
                    
                    
                    
                    break;
                }
                else
                {
#ifdef DEBUG
                    printf("please press auth in the web broswer after login in or wait a minute\n\n");
#endif
                }
#ifdef _WINDOWS
		::Sleep(50000);
#else
                sleep(5);
#endif // _WINDOWS

            }
        }
    }
    
    user.isConnected = userProfileLoaded;
    
    return userProfileLoaded;
}

bool authLocal(LFUser &user)
{
    bool stop = false;
    return auth(user, false, stop);
}

void clearSession(LFUser &user)
{
    user.isConnected = false;
    FILE *file = fopen(userProfile, "w");
    if (file)
    {
        fclose(file);
    }
    
}

LFUser lfUser;

LFUser* lastFmUser()
{
    return &lfUser;
}

