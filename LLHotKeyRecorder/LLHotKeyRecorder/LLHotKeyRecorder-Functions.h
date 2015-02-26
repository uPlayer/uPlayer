//
//  LLHotKeyRecorder-Functions.h
//  LLHotKeyRecorder
//
//  Created by Damien DeVille on 5/3/14.
//  Copyright (c) 2014 Damien DeVille. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class LLHotKey;

extern NSString *LLHotKeyStringForModifiers(NSUInteger modifiers);
extern NSString *LLHotKeyStringForKeyCode(unsigned short keyCode);
extern NSString *LLHotKeyStringForHotKey(LLHotKey *hotKey);

extern BOOL LLHotKeyIsHotKeyAvailable(LLHotKey *hotKey, NSEvent *event);
extern BOOL LLHotKeyIsHotKeyValid(LLHotKey *hotKey, NSEvent *event);
