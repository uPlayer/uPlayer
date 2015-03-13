//
//  PlayerError.m
//  uPlayer
//
//  Created by liaogang on 15/3/13.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import "PlayerError.h"

NSString *const NSPlayerErrorDomain = @"com.uPlayer";

@implementation PlayerError

+(instancetype)errorNoSuchFile:(NSString*)path
{
    NSDictionary *userInfo = @{
NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"File %@ no found.", nil) , path],
NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"File is deleted since last added.", nil) ,
NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Relocation it in Finder.", nil)
                               };
    
    return  [PlayerError errorWithDomain:NSPlayerErrorDomain code:PlayerNoSuchFileError userInfo:userInfo];
}

@end
