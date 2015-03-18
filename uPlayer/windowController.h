//
//  windowController.h
//  uPlayer
//
//  Created by liaogang on 15/1/28.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface WindowController : NSWindowController

@property (weak) IBOutlet NSToolbar *toolBar;

/// active and reload the search field key words.
-(void)activeSearchControl;

@end
