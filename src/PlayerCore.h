//
//  UPlayer.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//


@interface PlayerCore: NSObject

-(bool)isPlaying ;

-(bool)isPaused;

/*!
 * @brief Determine if the player is pending
 * @return \c true if a \c Decoder has started decoding but not yet started rendering, \c false otherwise
 */
-(bool)isPending;

/*!
 * @brief Determine if the player is stopped
 * @return \c true if a \c Decoder has not started decoding or the decoder queue is empty, \c false otherwise
 */
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
