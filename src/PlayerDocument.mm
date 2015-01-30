//
//  UPlayer.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import "PlayerTypeDefines.h"
#import "PlayerDocument.h"
#import <Foundation/Foundation.h>
#import "serialize.h"




@interface PlayerDocument ()
@end


@implementation PlayerDocument

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        self.windowName = NSLocalizedString(@"uPlayer windows name", nil);
        self.playerlList = [[PlayerlList alloc]init];
        self.resumeAtReboot = 1;
        
    }
    
    return self;
}




@end

