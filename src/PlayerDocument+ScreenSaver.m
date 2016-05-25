//
//  PlayerDocument_ScreenSaver.m
//  uPlayer
//
//  Created by liaogang on 16/3/28.
//  Copyright © 2016年 liaogang. All rights reserved.
//

#import "PlayerDocument+ScreenSaver.h"

@implementation PlayerDocument (ScreenSaver)

-(void)monitorScreenSaverEvent
{
    
    [[NSDistributedNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(screensaverStarted:)
     name:@"com.apple.screensaver.didstart"
     object:nil];
    
     [[NSDistributedNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(screensaverStopped:)
     name:@"com.apple.screensaver.didstop"
     object:nil];   
}

-(void)screensaverStarted:(NSNotification*)n
{
    NSLog(@"screensaverStarted");
    self.screenSaverRunning = TRUE;
}

-(void)screensaverStopped:(NSNotification*)n
{
    NSLog(@"screensaverStopped");
    self.screenSaverRunning = FALSE;
}

@end
