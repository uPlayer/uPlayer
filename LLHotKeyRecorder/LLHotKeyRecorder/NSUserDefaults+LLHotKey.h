//
//  NSUserDefaults+LLHotKey.h
//  LLHotKeyRecorder
//
//  Created by Damien DeVille on 5/4/14.
//  Copyright (c) 2014 Damien DeVille. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LLHotKeyRecorder/LLHotKey.h"

@interface NSUserDefaults (LLHotKey)

- (LLHotKey *)hotKeyForKey:(NSString *)key;
- (void)setHotKey:(LLHotKey *)hotKey forKey:(NSString *)key;

@end

@interface LLHotKey (Archiving)

- (NSData *)archivedRepresentation;
+ (LLHotKey *)hotKeyFromArchivedRepresentation:(NSData *)archivedRepresentation;

@end
