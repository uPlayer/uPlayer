//
//  PlayerError.h
//  uPlayer
//
//  Created by liaogang on 15/3/13.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PlayerTypeDefines.h"

extern NSString *const NSPlayerErrorDomain;

enum PlayErrorEnum
{
    PlayerNoSuchFileError,
    PlayerConfigVersionDismatchError,
};


@interface PlayerError : NSError

+(instancetype)errorNoSuchFile:(NSString*)path;

+(instancetype)errorConfigVersionDismatch;

@end
