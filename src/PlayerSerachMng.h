//
//  UPlayer.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "PlayerList.h"




@interface PlayerSearchMng : NSObject
@property (nonatomic,strong) NSString *searchKey;
@property (nonatomic,strong) PlayerList *playerlistOriginal,*playerlistFilter;
@property (nonatomic,strong) NSMutableDictionary *dicFilterToOrginal;//index

-(void)search:(NSString*)key;

-(PlayerTrack*)getOrginalByIndex:(int)index;
@end





#if defined(__cplusplus)
extern "C" {
#endif
   
    
   
    
#if defined(__cplusplus)
}
#endif
