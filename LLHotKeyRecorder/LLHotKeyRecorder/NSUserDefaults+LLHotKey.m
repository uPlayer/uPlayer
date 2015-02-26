//
//  NSUserDefaults+LLHotKey.m
//  LLHotKeyRecorder
//
//  Created by Damien DeVille on 5/4/14.
//  Copyright (c) 2014 Damien DeVille. All rights reserved.
//

#import "NSUserDefaults+LLHotKey.h"

@implementation NSUserDefaults (LLHotKey)

- (LLHotKey *)hotKeyForKey:(NSString *)key
{
	return [LLHotKey hotKeyFromArchivedRepresentation:[self objectForKey:key]];
}

- (void)setHotKey:(LLHotKey *)hotKey forKey:(NSString *)key
{
	[self setObject:[hotKey archivedRepresentation] forKey:key];
}

@end

@implementation LLHotKey (Archiving)

- (NSData *)archivedRepresentation
{
	return [NSKeyedArchiver archivedDataWithRootObject:self];
}

+ (LLHotKey *)hotKeyFromArchivedRepresentation:(NSData *)archivedRepresentation
{
	if (archivedRepresentation == nil) {
		return nil;
	}
	
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:archivedRepresentation];
	[unarchiver setRequiresSecureCoding:YES];
	
	NSSet *allowedClasses = [NSSet setWithObject:[LLHotKey class]];
	
	@try {
		LLHotKey *hotKey = [unarchiver decodeObjectOfClasses:allowedClasses forKey:@"root"];
		return hotKey;
	}
	@catch (NSException *exception) {
		// nop
	}
	@finally {
		[unarchiver finishDecoding];
	}
	
	return nil;
}

@end
