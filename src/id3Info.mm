//
//  id3Info.m
//
//  Created by liaogang on 6/20/14.
//
//


#import "id3Info.h"
#import <AVFoundation/AVFoundation.h>


BOOL getId3FromAudio(NSURL *audioFile, NSMutableData *image, NSMutableString *album, NSMutableString *artist,NSMutableString *title, NSMutableString *lyrics,NSMutableString *genre,NSMutableString *year)
{
    if (!audioFile)
        return FALSE;
    
    AVURLAsset *mp3Asset = [[AVURLAsset alloc] initWithURL:audioFile options:nil];
    
    if (!mp3Asset)
        return FALSE;
    
    const int thingsNeedFind = 7;

    BOOL n = 0;
    
    if (!image)
        n += 1;
    
    
    if ( [mp3Asset availableMetadataFormats].count > 0)
    {
        for (NSString *format in [mp3Asset availableMetadataFormats])
        {
            for (AVMetadataItem *metadataItem in [mp3Asset metadataForFormat:format])
            {
                NSString *commonKey = metadataItem.commonKey;
                
                
                if ([commonKey isEqualToString:AVMetadataCommonKeyAlbumName])
                {
                    [album setString:metadataItem.stringValue];
                    n++;
                }
                else if ([commonKey isEqualToString:AVMetadataCommonKeyTitle])
                {
                    [title setString:metadataItem.stringValue];
                    n++;
                }
                else if( [commonKey isEqualToString:AVMetadataCommonKeyArtist])
                {
                    [artist setString:metadataItem.stringValue];
                    n++;
                }
                else if( [commonKey isEqualToString: AVMetadataiTunesMetadataKeyLyrics])
                {
                    [lyrics setString:metadataItem.stringValue];
                    n++;
                }
                else if( [commonKey isEqualToString: AVMetadataQuickTimeUserDataKeyGenre])
                {
                    [lyrics setString:metadataItem.stringValue];
                    n++;
                }
                else if( [commonKey isEqualToString: AVMetadataQuickTimeMetadataKeyYear])
                {
                    [lyrics setString:metadataItem.stringValue];
                    n++;
                }
                else if (image &&[commonKey isEqualToString:AVMetadataCommonKeyArtwork])
                {
                    if ([metadataItem.value isKindOfClass:[NSDictionary class]])
                        [image appendData: [(NSDictionary*)metadataItem.value objectForKey:@"data"]];
                    else if([metadataItem.value isKindOfClass:[NSData class] ])
                        [image appendData: (NSData*)metadataItem.value];
                    
                    n++;
                }
                
                
                if (n==thingsNeedFind)
                    break;
                
            }
            
            if (n==thingsNeedFind)
                break;
        }
    }
    else
        return FALSE;
    
    //if no title find , use the file name.
    if ([title isEqualToString:@""]) {
        [title setString: audioFile.path.lastPathComponent.stringByDeletingPathExtension];
    }
    
    return TRUE;
}


NSData * getId3ImageFromAudio(NSURL *audioFile)
{
    NSData *result;
    
    AVURLAsset *mp3Asset = [[AVURLAsset alloc] initWithURL:audioFile options:nil];
    
    if (!mp3Asset)
        return nil ;
    
    for (NSString *format in [mp3Asset availableMetadataFormats])
    {
        for (AVMetadataItem *metadataItem in [mp3Asset metadataForFormat:format])
        {
            NSString *commonKey = metadataItem.commonKey;
            
            if ([commonKey isEqualToString:AVMetadataCommonKeyArtwork])
            {
                if ([metadataItem.value isKindOfClass:[NSDictionary class]])
                    result = [(NSDictionary*)metadataItem.value objectForKey:@"data"];
                else if([metadataItem.value isKindOfClass:[NSData class] ])
                    result = (NSData*)metadataItem.value;
            }
            
            if (result)
                break;
        }
        
        if (result)
            break;
        
    }
    
    return result;
}


