//
//  Last.fm
//
//  Created by liaogang on 15/1/4.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#ifndef __Last_fm__api__
#define __Last_fm__api__

#include <stdio.h>
#include <string>
#include "socketTool.h"
#include <assert.h>
#include "Last_fm.h"

#include "Last_fm_local_record.h"

using namespace std;


void setLastFmApiKey(const char *apikey);
void setLastFmSecret(const char *secret);



/**
 Get the metadata for an artist. Includes biography, truncated at 300 characters.
 */
bool artist_getInfo(string &artist ,LFArtist &lfArtist);


/**
 Get the metadata for a track on Last.fm using the artist/track name or a musicbrainz id.
 */
bool track_getInfo(string &artist , string & track, LFTrack &lfTrack);




bool track_love(string &sessionKey, string &artist , string & track );


bool track_updateNowPlaying(string &sessionKey, string &artist,string &track);





bool track_scrobble(string &sessionKey, string &artist,string &track,string &timestamp);
bool track_scrobble(string &sessionKey, string &artist,string &track,time_t timestamp);
bool track_scrobble(string &sessionKey, string &artist,string &track);
bool track_scrobble(string &sessionKey, LFTrackRecords &records);

/**
     Get a list of the recent tracks listened to by this user. Also includes the currently playing track with the nowplaying="true" attribute if the user is currently listening.
 */
bool user_getRecentTracks(const string &username , vector<LFTrack> &tracks);














// auth step 1
bool auth_getToken( string &token );
// auth step 2
void openWebInstance(const string &token);

// auth step 3
const int sessionKeyLength = 32;
bool auth_getSession(string &token,string &sessionKey,string &userName);


#endif /* defined(__Last_fm__Last_fm__) */
