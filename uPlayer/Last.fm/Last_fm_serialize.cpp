//
//  Last.fm
//
//  Created by liaogang on 15/1/4.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//
#include "Last_fm_serialize.h"
#include "Last_fm_local_record.h"


#include "serialize.h"

/// LFTrackRecord

FILE& operator<<(FILE& f,const LFTrackRecord &t)
{
    return f<<t.artist<<t.track<<t.time;
}

FILE& operator>>(FILE& f,LFTrackRecord& t)
{
    return f>>t.artist>>t.track>>t.time;
}

/// LFTrackRecords

FILE& operator<<(FILE& f,const LFTrackRecords &t)
{
    return f<<t.records;
}

FILE& operator>>(FILE& f,LFTrackRecords& t)
{
    return f>>t.records;
}





