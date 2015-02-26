//
//  LLHotKeyCenter.h
//  LLHotKeyRecorder
//
//  Created by Damien DeVille on 5/3/14.
//  Copyright (c) 2014 Damien DeVille. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class LLHotKey;

@interface LLHotKeyCenter : NSObject

+ (instancetype)defaultCenter;

- (void)addObserver:(id)observer selector:(SEL)selector hotKey:(LLHotKey *)hotKey;
- (void)removeObserver:(id)observer hotKey:(LLHotKey *)hotKey;

@end
