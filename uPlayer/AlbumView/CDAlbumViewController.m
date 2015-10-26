//
//  CDAlbumViewController.m
//  uPlayer
//
//  Created by liaogang on 15/10/14.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import "CDAlbumViewController.h"
#import <Quartz/Quartz.h>

NSImage * maskImage(NSImage *image ,NSImage *maskImage );

void resumeLayer(CALayer* layer);

void pauseLayer(CALayer * layer);





@interface CDAlbumViewController ()
@property (strong, nonatomic) NSImageView *imageCDBackgound;
@property (strong, nonatomic) NSImageView *imageCDFront;
@property (strong, nonatomic) NSImageView *imageAlbum;

@property (nonatomic) BOOL suppressedByTouch;
@end

@implementation CDAlbumViewController


-(void)loadView
{
    self.view = [[NSView alloc]init];
    self.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

    
    self.view.layer = [CALayer layer];
    
    float r = (rand() % 255) / 255.0f;
    float g = (rand() % 255) / 255.0f;
    float b = (rand() % 255) / 255.0f;
    
    if(self.view.layer)
    {
        CGColorRef color = CGColorCreateGenericRGB(r, g, b, 1.0f);
        self.view.layer.backgroundColor = color;
        CGColorRelease(color);
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    NSRect b = self.view.bounds;
    
//    _imageCDBackgound = [[ NSImageView alloc]initWithFrame:b];
//    _imageCDFront =[[ NSImageView alloc]initWithFrame:b];
    _imageAlbum = [[ NSImageView alloc]initWithFrame:b];
    _imageAlbum.layer = [CALayer layer];
    
    [_imageAlbum setImageScaling:NSImageScaleProportionallyUpOrDown];
    
    _imageAlbum.autoresizingMask =
    _imageCDFront.autoresizingMask =
    _imageCDBackgound.autoresizingMask =
    NSViewWidthSizable | NSViewHeightSizable;
    
    
    [self.view addSubview:_imageCDBackgound];
    [self.view addSubview:_imageCDFront];
    [self.view addSubview:_imageAlbum];
    
    [self setAlbumImage:nil];
}




-(void)setAlbumFrame:(CGRect)frame
{
    CGFloat width = frame.size.width;
    CGFloat radius = width;
    
    self.imageAlbum.layer.cornerRadius = radius / 2.;
    self.imageCDFront.layer.cornerRadius = radius / 2.;
    self.imageCDBackgound.layer.cornerRadius = radius / 2.;
    
    self.imageCDFront.layer.masksToBounds = YES;
    self.imageAlbum.layer.masksToBounds = YES;
    self.imageCDBackgound.layer.masksToBounds = YES;
    
}

-(void)viewWillAppear
{
    [super viewWillAppear];
    [self adjustLayout];
}

-(void)adjustLayout
{
    NSAssert(self.view.superview, nil);
    
    [self.view setFrame: self.view.superview.bounds];
    [self setAlbumFrame:self.view.bounds];
    
}

-(void)addToView:(NSView*)parent
{
    [self.view setFrame:parent.bounds];
    [parent addSubview:self.view];
    [self setAlbumFrame:parent.bounds];
    
    [self startAlbumRotation];
}




-(void)setAlbumImage:(NSImage*)image
{
    if (image ) {
        self.imageCDFront.hidden = YES;
        
        self.imageAlbum.hidden = NO;
        
        NSImage *mask = [NSImage imageNamed:@"cd_mask"];
//        self.imageAlbum.image = maskImage(image , mask);
        [self.imageAlbum setImage:image];
    }
    else
    {
        self.imageCDFront.hidden = NO;
        
        self.imageAlbum.hidden = YES;
        self.imageAlbum.image = nil;
    }
}




-(BOOL)isRotating
{
    return self.imageAlbum.layer.speed > 0.0;
}

-(void)pauseAlbumRotation
{
    self.suppressedByTouch = false;
    pauseLayer(self.imageAlbum.layer);
}

-(void)stopAlbumRotation
{
    self.suppressedByTouch = false;
    [self.imageAlbum.layer removeAllAnimations];
}

-(void)_startAlbumRotation
{
    if(![self.imageAlbum.layer animationForKey:@"rotationAnimation"] )
    {
        CFTimeInterval duration = 100 * 10 * 60 ;
        CABasicAnimation* rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * 0.15  * duration ];
        rotationAnimation.duration = duration;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = 1;
        
        [self.imageAlbum.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    }
    
    resumeLayer(self.imageAlbum.layer);
}

-(void)startAlbumRotation
{
    if([self.imageAlbum.layer animationForKey:@"rotationAnimation"] )
        [self _startAlbumRotation];
    else
        [self performSelector:@selector(_startAlbumRotation) withObject:nil afterDelay:0.9];
}


#pragma mark - touches

-(void)imageTouchesEnded
{
    if (self.suppressedByTouch ) {
        [self _startAlbumRotation];
        self.suppressedByTouch = false;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(NSEvent *)event
{
    if ([self isRotating]) {
        [self pauseAlbumRotation];
        self.suppressedByTouch = true;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(NSEvent *)event
{
    [self imageTouchesEnded];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(NSEvent *)event
{
    [self imageTouchesEnded];
}



@end


void pauseLayer(CALayer * layer)
{
    if (layer.speed > 0.0)
    {
        CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
        layer.speed = 0.0;
        layer.timeOffset = pausedTime;
    }
}

void resumeLayer(CALayer* layer)
{
    if (layer.speed == 0.0)
    {
        CFTimeInterval pausedTime = [layer timeOffset];
        layer.speed = 1.0;
        layer.timeOffset = 0.0;
        layer.beginTime = 0.0;
        CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        layer.beginTime = timeSincePause;
    }
}

CGImageRef getCGImage(NSImage *image)
{
    return CGImageSourceCreateImageAtIndex(CGImageSourceCreateWithData((CFDataRef)[image TIFFRepresentation], NULL), 0, NULL);
}

NSImage * maskImage(NSImage *image ,NSImage *maskImage )
{
    CGImageRef maskRef = getCGImage(maskImage);
    
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef maskedImageRef = CGImageCreateWithMask( getCGImage(image), mask);
    NSImage *maskedImage = [[NSImage alloc]initWithCGImage:maskedImageRef size: maskImage.size];
    
    CGImageRelease(mask);
    CGImageRelease(maskedImageRef);
    
    // returns new image with mask applied
    return maskedImage;
}
