//
//  LLHotKey.m
//  LLHotKeyRecorder
//
//  Created by Damien DeVille on 5/3/14.
//  Copyright (c) 2014 Damien DeVille. All rights reserved.
//

#import "LLHotKey.h"

#import "LLHotKeyRecorder-Functions.h"

@interface LLHotKey ()

@property (readwrite, assign, nonatomic) unsigned short keyCode;
@property (readwrite, assign, nonatomic) NSUInteger modifierFlags;

@property (strong, nonatomic) NSValue *carbonHotKey;

@end

@implementation LLHotKey

+ (instancetype)hotKeyWithKeyCode:(unsigned short)keyCode modifierFlags:(NSUInteger)modifierFlags
{
	LLHotKey *hotKey = [[self alloc] init];
	hotKey.keyCode = keyCode;
	hotKey.modifierFlags = modifierFlags;
	return hotKey;
}

+ (instancetype)hotKeyWithEvent:(NSEvent *)event
{
	return [self hotKeyWithKeyCode:event.keyCode modifierFlags:event.modifierFlags];
}

#pragma mark - NSObject

- (NSString *)description
{
	NSMutableString *description = [NSMutableString stringWithString:super.description];
	[description appendString:@" – "];
	[description appendFormat:@"%@", LLHotKeyStringForHotKey(self)];
	return description;
}

- (BOOL)isEqual:(LLHotKey *)object
{
	if (![object isKindOfClass:[self class]]) {
		return NO;
	}
	
	if (self->_keyCode != object->_keyCode) {
		return NO;
	}
	
	if (self->_modifierFlags != object->_modifierFlags) {
		return NO;
	}
	
	return YES;
}

- (NSUInteger)hash
{
	return (self->_keyCode ^ self->_modifierFlags);
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
	LLHotKey *hotKey = [[[self class] alloc] init];
	hotKey->_keyCode = self->_keyCode;
	hotKey->_modifierFlags = self->_modifierFlags;
	return hotKey;
}

#pragma mark - NSCoding

static NSString * const LLHotKeyKeyCode = @"keyCode";
static NSString * const LLHotKeyModifierFlags = @"modifierFlags";

+ (BOOL)supportsSecureCoding
{
	return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:@(self.keyCode) forKey:LLHotKeyKeyCode];
	[coder encodeObject:@(self.modifierFlags) forKey:LLHotKeyModifierFlags];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [self init];
	if (self == nil) {
		return nil;
	}
	
	_keyCode = (unsigned short)[[decoder decodeObjectOfClass:[NSNumber class] forKey:LLHotKeyKeyCode] unsignedIntegerValue];
	_modifierFlags = [[decoder decodeObjectOfClass:[NSNumber class] forKey:LLHotKeyModifierFlags] unsignedIntegerValue];
	
	return self;
}

@end

@implementation LLHotKey (NullHotKey)

+ (instancetype)nullHotKey
{
	static LLHotKey *nullHotKey = nil;
	static dispatch_once_t onceToken = 0;
	dispatch_once(&onceToken, ^ {
		nullHotKey = [LLHotKey hotKeyWithKeyCode:-1 modifierFlags:0];
	});
	return nullHotKey;
}

@end
