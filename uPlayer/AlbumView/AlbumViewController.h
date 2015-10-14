//
//  AlbumViewController.h
//  uPlayer
//
//  Created by liaogang on 15/10/14.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "windowController.h"

@interface AlbumViewController : NSViewController

+(instancetype)instanceFromStoryboard;

@property (nonatomic,strong) WindowController *w;

-(void)setAlbumImage:(NSImage*)image;

@end
