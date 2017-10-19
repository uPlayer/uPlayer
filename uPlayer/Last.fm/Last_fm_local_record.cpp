//
//  Last.fm
//
//  Created by liaogang on 15/1/4.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#include "Last_fm_local_record.h"
#include "Last_fm_serialize.h"


const char localRecord[] = "localRecords.cfg";
static  LFTrackRecords records;
static bool recordsDirty = false;

LFTrackRecords& loadTrackRecords()
{
    FILE *file = fopen(localRecord, "r");
    if (file)
    {
        (*file)>>records;
        fclose(file);
    }
    
    return records;
}

void addScrobbleLocal(string &artist,string &track)
{
    time_t t;
    time(&t);
    
    records.records.push_back(LFTrackRecord(artist,track,t));
    
    recordsDirty = true;
}

void saveTrackRecords()
{
    if (recordsDirty)
    {
        FILE *file = fopen(localRecord, "w");
        if (file)
        {
            (*file)<<records;
            fclose(file);
        }
    }
    
}


