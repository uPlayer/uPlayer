//
//  UPlayer.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

<<<<<<< HEAD
=======
#import <Foundation/Foundation.h>
>>>>>>> eb33dbd211f0a9a2aaa5c588b10c9e76795eb186

@interface PlayerCore: NSObject

-(bool)isPlaying ;

-(bool)isPaused;

<<<<<<< HEAD
-(bool)isPending;

=======
/*!
 * @brief Determine if the player is pending
 * @return \c true if a \c Decoder has started decoding but not yet started rendering, \c false otherwise
 */
-(bool)isPending;

/*!
 * @brief Determine if the player is stopped
 * @return \c true if a \c Decoder has not started decoding or the decoder queue is empty, \c false otherwise
 */
>>>>>>> eb33dbd211f0a9a2aaa5c588b10c9e76795eb186
-(bool)isStopped;

- (void) windowWillClose:(NSNotification *)notification;

- (void) playPause:(id)sender;

- (void) seekForward:(id)sender;

- (void) seekBackward:(id)sender;

- (void) seek:(id)sender;

- (void) skipToNextTrack:(id)sender;

- (BOOL) playURL:(NSURL *)url;

- (BOOL) enqueueURL:(NSURL *)url;

@end
