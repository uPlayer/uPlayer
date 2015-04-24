//
//  id3Info.h
//
//  Created by liaogang on 6/20/14.
//
//

#import <Cocoa/Cocoa.h>


/**
 *  get audio file's id3 info.
 *  @param audioFile: input
 *  @param album,artist,title: output info
 *  @return audio's album image.(封面图)
 */
void getId3FromAudio(NSURL *audioFile, NSMutableData *image, NSMutableString *album, NSMutableString *artist,NSMutableString *title, NSMutableString *lyrics,NSMutableString *genre,NSMutableString *year);







