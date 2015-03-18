//
//  PlayerSerachMng.h
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "PlayerList.h"




@interface PlayerSearchMng : NSObject
@property (nonatomic,strong) PlayerList *playerlistOriginal,*playerlistFilter;
@property (nonatomic,strong) NSMutableDictionary *dicFilterToOrginal;//index

-(void)search:(NSString*)key;

///Refresh search result if the original playlist content is changed.
-(void)research;

-(PlayerTrack*)getOrginalByIndex:(NSInteger)index;

@end





#if defined(__cplusplus)
extern "C" {
#endif
   
    
   
    
#if defined(__cplusplus)
}
#endif
