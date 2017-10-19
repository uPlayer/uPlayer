//
//  Last.fm
//
//  Created by liaogang on 15/1/4.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//



#include "Last_fm_local_record.h"

#ifndef __last_fm_seralize_h__
#define __last_fm_seralize_h__


/// LFTrackRecord

FILE& operator<<(FILE& f,const LFTrackRecord &t);

FILE& operator>>(FILE& f,LFTrackRecord& t);

/// LFTrackRecords

FILE& operator<<(FILE& f,const LFTrackRecords &t);

FILE& operator>>(FILE& f,LFTrackRecords& t);


#endif

