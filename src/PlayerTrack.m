//
//  PlayerTrack.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//


#import "PlayerTrack.h"
#import "PlayerList.h"

#define BOOKMARK_UTI @"com.smine.trackinfo"

@interface TrackInfo()
@end

@implementation TrackInfo
#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_path forKey:@"path"];
    
    [aCoder encodeObject:_artist forKey:@"artist"];
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeObject:_album forKey:@"album"];
    [aCoder encodeObject:_genre forKey:@"genre"];
    [aCoder encodeObject:_year forKey:@"year"];
    
    [aCoder encodeObject:_image forKey:@"image"];
    [aCoder encodeObject:_imageSmall forKey:@"imageSmall"];
    [aCoder encodeObject:_lyrics forKey:@"lyrics"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        _path = [aDecoder decodeObjectForKey:@"path"];
        
        _artist = [aDecoder decodeObjectForKey:@"artist"];
        _title = [aDecoder decodeObjectForKey:@"title"];
        _album = [aDecoder decodeObjectForKey:@"album"];
        _genre = [aDecoder decodeObjectForKey:@"genre"];
        _year = [aDecoder decodeObjectForKey:@"year"];
        
        _image = [aDecoder decodeObjectForKey:@"image"];
        _imageSmall = [aDecoder decodeObjectForKey:@"imageSmall"];
        _lyrics = [aDecoder decodeObjectForKey:@"lyrics"];
    }
    
    return self;
}

#pragma mark - NSPasteboardReading
+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    static NSArray *readableTypes = nil;
    if (!readableTypes) {
        readableTypes = [[NSArray alloc] initWithObjects:BOOKMARK_UTI, (NSString *)kUTTypeURL, nil];
    }
    
    return readableTypes;
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pboard {
    
    if ([type isEqualToString:BOOKMARK_UTI]) {
        /*
         This means you don't need to implement code for this
         type from initWithPasteboardPropertyList:ofType:
         */
        return NSPasteboardReadingAsKeyedArchive;
    }
    else if ([type isEqualToString: (NSString *)kUTTypeFileURL]) {
        return [NSURL readingOptionsForType:type pasteboard:pboard];
    }
    
    
    if (pboard.name == NSDragPboard) {
        if ([type isEqualToString: (NSString *)kUTTypeFileURL]) {
            return [NSURL readingOptionsForType:type pasteboard:pboard];
        }
    }
    
    return 0;
}

- (id)initWithPasteboardPropertyList:(id)propertyList ofType:(NSString *)type
{
    if (self = [self init]) {
        
        if ([type isEqualToString:(NSString *)kUTTypeFileURL]) {
            
            NSURL *url = [[NSURL alloc] initWithPasteboardPropertyList:propertyList ofType:type];
            
            _path = url.absoluteString;
            
            // todo
            
        } else {
            return nil;
        }
        
    }
    
    return self;
}



#pragma mark - NSPasteboardWriting
- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    static NSArray *writableTypes = nil;
    if (!writableTypes) {
        writableTypes = [[NSArray alloc] initWithObjects:BOOKMARK_UTI,
                         (NSString *)kUTTypeURL, NSPasteboardTypeString, nil];
    }
    return writableTypes;
}

- (id)pasteboardPropertyListForType:(NSString *)type
{
    if ([type isEqualToString:BOOKMARK_UTI]) {
        return [NSKeyedArchiver archivedDataWithRootObject:self];
    }
    
    /*
    if ([type isEqualToString:(NSString *)kUTTypeURL]) {
        return [url pasteboardPropertyListForType:(NSString *)kUTTypeURL];
    }
    
    if ([type isEqualToString:NSPasteboardTypeString]) {
        return [NSString stringWithFormat:@"<a href=\"%@\">%@</a>",
                [url absoluteString], title];
    }
    */
    
    return nil;
}

@end



@implementation PlayerTrack

-(NSInteger)getIndex
{
    return [self.list getIndex:self];
}

-(instancetype)init
{
    NSAssert(false, nil);
    return nil;
}

-(instancetype)init:(PlayerList*)list
{
    self =[ super init];
    if (self) {
        self.list=list;
    }
    return self;
}

-(void)markSelected
{
    _list.selectIndex = (int) self.index;
}

@end

NSString* compressTitle(TrackInfo *info)
{
    if (info.artist.length > 0)
        return  [NSString stringWithFormat:@"%@ - %@", info.artist, info.title];
    else
        return  info.title;
}
