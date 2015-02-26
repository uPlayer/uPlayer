//
//  LLHotKey.h
//  LLHotKeyRecorder
//
//  Created by Damien DeVille on 5/3/14.
//  Copyright (c) 2014 Damien DeVille. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LLHotKey : NSObject <NSCopying, NSCoding, NSSecureCoding>

+ (instancetype)hotKeyWithKeyCode:(unsigned short)keyCode modifierFlags:(NSUInteger)modifierFlags;
+ (instancetype)hotKeyWithEvent:(NSEvent *)event;

@property (readonly, assign, nonatomic) unsigned short keyCode;
@property (readonly, assign, nonatomic) NSUInteger modifierFlags;

@end

@interface LLHotKey (NullHotKey)

+ (instancetype)nullHotKey;

@end
