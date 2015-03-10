//
//  keycode.h
//  uPlayer
//
//  Created by liaogang on 15/3/10.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

#if defined(__cplusplus)
extern "C" {
#endif

NSString *keyStringFormKeyCode(CGKeyCode keyCode);

CGKeyCode keyCodeFormKeyString(NSString *keyString);
    
#if defined(__cplusplus)
}
#endif