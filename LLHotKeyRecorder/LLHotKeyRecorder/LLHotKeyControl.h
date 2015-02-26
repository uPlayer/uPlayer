//
//  LLHotKeyControl.h
//  LLHotKeyRecorder
//
//  Created by Damien DeVille on 5/3/14.
//  Copyright (c) 2014 Damien DeVille. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class LLHotKey;

@interface LLHotKeyControl : NSControl

@property (strong, nonatomic) LLHotKey *hotKeyValue;

@end
