//
//  CDAlbumViewController.h
//  uPlayer
//
//  Created by liaogang on 15/10/14.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CDAlbumViewController : NSViewController

-(void)setAlbumImage:(NSImage*)image;

-(void)adjustLayout;

-(void)clearAlbumImage;

-(void)pauseAlbumRotation;

-(void)startAlbumRotation;

-(BOOL)isRotating;

@end
