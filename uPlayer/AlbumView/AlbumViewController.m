//
//  AlbumViewController.m
//  uPlayer
//
//  Created by liaogang on 15/10/14.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import "AlbumViewController.h"
#import "keycode.h"
#import "CDAlbumViewController.h"

@interface AlbumViewController ()

@property (weak) IBOutlet NSView *cdAlbumView;

@property (nonatomic,strong) CDAlbumViewController *cdAlbumViewController;
@end

@implementation AlbumViewController

+(instancetype)instanceFromStoryboard
{
    return  [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"AlbumViewControllerID"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cdAlbumViewController = [[CDAlbumViewController alloc]init];
    [self.cdAlbumView addSubview:self.cdAlbumViewController.view];
    
}

-(void)setAlbumImage:(NSImage*)image
{
    [self.cdAlbumViewController setAlbumImage:image];
    [self.cdAlbumViewController adjustLayout];
    [self.cdAlbumViewController startAlbumRotation];
}

-(void)keyDown:(NSEvent *)theEvent
{
    printf("key pressed: %s\n", [[theEvent description] UTF8String]);
    
    NSString *keyString = keyStringFormKeyCode(theEvent.keyCode);
    
    
    if([keyString isEqualToString:@"ESCAPE"])
    {
        [self.w switchViewMode];
    }
   
}




@end



