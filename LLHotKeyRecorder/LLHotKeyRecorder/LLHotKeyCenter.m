//
//  LLHotKeyCenter.m
//  LLHotKeyRecorder
//
//  Created by Damien DeVille on 5/3/14.
//  Copyright (c) 2014 Damien DeVille. All rights reserved.
//

#import "LLHotKeyCenter.h"

#import <objc/message.h>
#import <Carbon/Carbon.h>

#import "LLHotKey.h"
#import "_LLHotKeyObserver.h"

@interface LLHotKeyCenter ()

@property (strong, nonatomic) NSMutableDictionary *carbonHotKeyIDToCarbonHotKeyMap;
@property (strong, nonatomic) NSMutableDictionary *carbonHotKeyIDToCocoaHotKeyMap;

@property (strong, nonatomic) NSMutableDictionary *cocoaHotKeyToObserversMap;

@end

@implementation LLHotKeyCenter

+ (instancetype)defaultCenter
{
	static LLHotKeyCenter *sharedCenter = nil;
	static dispatch_once_t onceToken = 0;
	dispatch_once(&onceToken, ^ {
		sharedCenter = [[self alloc] init];
	});
	return sharedCenter;
}

- (id)init
{
	self = [super init];
	if (self == nil) {
		return nil;
	}
	
	_carbonHotKeyIDToCarbonHotKeyMap = [NSMutableDictionary dictionary];
	_carbonHotKeyIDToCocoaHotKeyMap = [NSMutableDictionary dictionary];
	_cocoaHotKeyToObserversMap = [NSMutableDictionary dictionary];
	
	EventTypeSpec eventTypeSpec = {.eventClass = kEventClassKeyboard, .eventKind = kEventHotKeyPressed};
	InstallApplicationEventHandler(&_LLHotKeyCenterHotKeyEventHandler, 1, &eventTypeSpec, (__bridge void *)self, NULL);
	
	return self;
}

#pragma mark - Public

- (void)addObserver:(id)observer selector:(SEL)selector hotKey:(LLHotKey *)hotKey
{
	NSParameterAssert(hotKey != nil);
	
	NSMutableSet *observers = [NSMutableSet setWithSet:[self.cocoaHotKeyToObserversMap objectForKey:hotKey]];
	
	if (observers.count == 0) {
		[self _registerHotKey:hotKey];
	}
	
	[observers addObject:[_LLHotKeyObserver observerWithObject:observer selector:selector]];
	[self.cocoaHotKeyToObserversMap setObject:observers forKey:hotKey];
}

- (void)removeObserver:(id)observer hotKey:(LLHotKey *)hotKey
{
	NSParameterAssert(hotKey != nil);
	
	NSMutableSet *observers = [NSMutableSet setWithSet:[self.cocoaHotKeyToObserversMap objectForKey:hotKey]];
	[observers removeObject:[_LLHotKeyObserver observerWithObject:observer selector:NULL]];
	
	if (observers.count == 0) {
		[self _unregisterHotKey:hotKey];
	}
	
	[self.cocoaHotKeyToObserversMap setObject:observers forKey:hotKey];
}

#pragma mark - Private (Key registration)

- (void)_registerHotKey:(LLHotKey *)hotKey
{
	static UInt32 carbonHotKeyID = 0;
	
	EventHotKeyID eventHotKeyID = {.signature = 'htk1', .id = carbonHotKeyID};
	UInt32 carbonKeyCode = hotKey.keyCode;
	UInt32 carbonModifiers = _LLCocoaToCarbonFlagModifiers(hotKey.modifierFlags);
	
	EventHotKeyRef carbonHotKey;
	RegisterEventHotKey(carbonKeyCode, carbonModifiers, eventHotKeyID, GetEventDispatcherTarget(), 0, &carbonHotKey);
	
	[self.carbonHotKeyIDToCarbonHotKeyMap setObject:[NSValue valueWithPointer:carbonHotKey] forKey:@(carbonHotKeyID)];
	[self.carbonHotKeyIDToCocoaHotKeyMap setObject:hotKey forKey:@(carbonHotKeyID)];
	
	carbonHotKeyID++;
}

- (void)_unregisterHotKey:(LLHotKey *)hotKey
{
	__block UInt32 carbonHotKeyID = -1;
	
	[self.carbonHotKeyIDToCocoaHotKeyMap enumerateKeysAndObjectsUsingBlock:^ (NSNumber *hotKeyNumber, LLHotKey *cocoaHotKey, BOOL *stop) {
		if ([cocoaHotKey isEqual:hotKey]) {
			carbonHotKeyID = (UInt32)hotKeyNumber.unsignedIntegerValue;
		}
	}];
	
	if (carbonHotKeyID == -1) {
		return;
	}
	
	[self.carbonHotKeyIDToCocoaHotKeyMap removeObjectForKey:@(carbonHotKeyID)];
	
	EventHotKeyRef carbonHotKey = [[self.carbonHotKeyIDToCarbonHotKeyMap objectForKey:@(carbonHotKeyID)] pointerValue];
	
	if (carbonHotKey == NULL) {
		return;
	}
	
	UnregisterEventHotKey(carbonHotKey);
	
	[self.carbonHotKeyIDToCarbonHotKeyMap removeObjectForKey:@(carbonHotKeyID)];
}

#pragma mark - Private

- (void)_invokeObserversForHotKey:(LLHotKey *)hotKey
{
	NSSet *observers = [self.cocoaHotKeyToObserversMap objectForKey:hotKey];
	
	for (_LLHotKeyObserver *observer in  observers) {
		((void (*)(id, SEL, id))objc_msgSend)(observer.object, observer.selector, hotKey);
	}
}

static UInt32 _LLCocoaToCarbonFlagModifiers(NSUInteger cocoaFlags)
{
	UInt32 carbonFlags = 0;
	
	if ((cocoaFlags & NSAlphaShiftKeyMask) == NSAlphaShiftKeyMask) {
		carbonFlags |= alphaLock;
	}
	if ((cocoaFlags & NSShiftKeyMask) == NSShiftKeyMask) {
		carbonFlags |= shiftKey;
	}
	if ((cocoaFlags & NSControlKeyMask) == NSControlKeyMask) {
		carbonFlags |= controlKey;
	}
	if ((cocoaFlags & NSAlternateKeyMask) == NSAlternateKeyMask) {
		carbonFlags |= optionKey;
	}
	if ((cocoaFlags & NSCommandKeyMask) == NSCommandKeyMask) {
		carbonFlags |= cmdKey;
	}
	if ((cocoaFlags & NSFunctionKeyMask) == NSFunctionKeyMask) {
		carbonFlags |= NSFunctionKeyMask;
	}
	
	return carbonFlags;
}

#pragma mark - Handler

static OSStatus _LLHotKeyCenterHotKeyEventHandler(EventHandlerCallRef nextHandler, EventRef carbonEvent, void *userData)
{
	LLHotKeyCenter *self = (__bridge LLHotKeyCenter *)userData;
	
	EventHotKeyID hotKeyID;
	GetEventParameter(carbonEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hotKeyID), NULL, &hotKeyID);
	
	LLHotKey *hotKey = [self.carbonHotKeyIDToCocoaHotKeyMap objectForKey:@(hotKeyID.id)];
	[self _invokeObserversForHotKey:hotKey];
	
    return noErr;
}

@end
