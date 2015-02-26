//
//  LLHotKeyControl.m
//  LLHotKeyRecorder
//
//  Created by Damien DeVille on 5/3/14.
//  Copyright (c) 2014 Damien DeVille. All rights reserved.
//

#import "LLHotKeyControl.h"

#import <Carbon/Carbon.h>

#import "LLHotKey.h"

#import "LLHotKeyRecorder-Functions.h"

@interface LLHotKeyControl ()

@property (assign, getter = isHoveringAccessory, nonatomic) BOOL hoveringAccessory;
@property (assign, getter = isRecording, nonatomic) BOOL recording;

@property (copy, nonatomic) NSString *shortcutPlaceholder;
@property (strong, nonatomic) NSTrackingArea *accessoryArea;

@property (strong, nonatomic) id eventMonitor;
@property (strong, nonatomic) id resignObserver;

@end

@implementation LLHotKeyControl

+ (Class)cellClass
{
	return [NSButtonCell class];
}

static void _CommonInit(LLHotKeyControl *self)
{
	[self setFocusRingType:NSFocusRingTypeNone];
	
	NSButtonCell *cell = [[NSButtonCell alloc] init];
	[cell setButtonType:NSPushOnPushOffButton];
	cell.font = [[NSFontManager sharedFontManager] convertFont:cell.font toSize:11.0];
	cell.bezelStyle = NSRoundRectBezelStyle;
	cell.focusRingType = NSFocusRingTypeNone;
	self.cell = cell;
}

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	if (self == nil) {
		return nil;
	}
	_CommonInit(self);
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	if (self == nil) {
		return nil;
	}
	_CommonInit(self);
	return self;
}

- (void)dealloc
{
	[self teardownEventMonitoring];
	[self teardownResignObserver];
}

#pragma mark - View

- (void)viewWillMoveToWindow:(NSWindow *)window
{
	[super viewWillMoveToWindow:window];
	
	self.recording = NO;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event
{
	return YES;
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (BOOL)needsPanelToBecomeKey
{
	return YES;
}

- (BOOL)resignFirstResponder
{
	self.recording = NO;
	
	return YES;
}

#pragma mark - Public accessors

- (void)setHotKeyValue:(LLHotKey *)hotKeyValue
{
	_hotKeyValue = hotKeyValue;
	
	[self setNeedsDisplay];
	
	[self sendAction:self.action to:self.target];
}

- (void)setEnabled:(BOOL)enabled
{
	[super setEnabled:enabled];
	
	self.recording = NO;
	
	[self updateTrackingAreas];
	[self setNeedsDisplay];
}

- (void)setHoveringAccessory:(BOOL)hoveringAccessory
{
	_hoveringAccessory = hoveringAccessory;
	
	[self setNeedsDisplay];
}

- (void)setRecording:(BOOL)recording
{
	_recording = recording;
	
	if (recording && !self.enabled) {
		return;
	}
	
	if (recording) {
		[self setupEventMonitoring];
		[self setupResignObserver];
	}
	else {
		[self teardownEventMonitoring];
		[self teardownResignObserver];
	}
	
	self.shortcutPlaceholder = nil;
	
	[self setNeedsDisplay];
}

- (void)setShortcutPlaceholder:(NSString *)shortcutPlaceholder
{
	_shortcutPlaceholder = [shortcutPlaceholder copy];
	
	[self setNeedsDisplay];
}

#pragma mark - Geometry

static const CGFloat LLHotKeyControlAccessoryButtonWidth = 23.0;

- (CGRect)shortcutFrame
{
	CGRect shortcutFrame, accessoryFrame;
	CGRectDivide(self.bounds, &accessoryFrame, &shortcutFrame, LLHotKeyControlAccessoryButtonWidth, CGRectMaxXEdge);
	return shortcutFrame;
}

- (CGRect)accessoryFrame
{
	CGRect shortcutFrame, accessoryFrame;
	CGRectDivide(self.bounds, &accessoryFrame, &shortcutFrame, LLHotKeyControlAccessoryButtonWidth, CGRectMaxXEdge);
	return accessoryFrame;
}

#pragma mark - Drawing

- (void)drawInRect:(CGRect)frame withTitle:(NSString *)title alignment:(NSTextAlignment)alignment state:(NSInteger)state
{
	NSButtonCell *cell = self.cell;
	cell.title = title;
	cell.alignment = alignment;
	cell.state = state;
	cell.enabled = self.enabled;
	
	[cell drawWithFrame:frame inView:self];
}

- (void)drawRect:(CGRect)dirtyRect
{
	static NSString * const escape = @"\u238B";
	static NSString * const delete = @"\u232B";
	
	NSString *shortcutTitle = [self _currentShortcutTitle];
	
	if (!self.recording && self.hotKeyValue == nil) {
		[self drawInRect:self.bounds withTitle:shortcutTitle alignment:NSCenterTextAlignment state:NSOffState];
		return;
	}
	
	[self drawInRect:self.bounds withTitle:(self.recording ? escape : delete) alignment:NSRightTextAlignment state:NSOffState];
	[self drawInRect:self.shortcutFrame withTitle:shortcutTitle alignment:NSCenterTextAlignment state:(self.recording ? NSOnState : NSOffState)];
}

- (NSString *)_currentShortcutTitle
{
	if (self.hotKeyValue != nil) {
		if (self.recording) {
			if (self.hoveringAccessory) {
				return NSLocalizedString(@"Use Previous Shortcut", @"LLHotKeyControl user previous shortcut");
			}
			if (self.shortcutPlaceholder.length > 0) {
				return self.shortcutPlaceholder;
			}
			return NSLocalizedString(@"Type New Shortcut", @"LLHotKeyControl type new shortcut");
		}
		return LLHotKeyStringForHotKey(self.hotKeyValue);
	}
	
	if (self.recording) {
		if (self.hoveringAccessory) {
			return NSLocalizedString(@"Cancel", @"LLHotKeyControl cancel");
		}
		if (self.shortcutPlaceholder.length > 0) {
			return self.shortcutPlaceholder;
		}
		return NSLocalizedString(@"Type New Shortcut", @"LLHotKeyControl type new shortcut");
	}
	
	return NSLocalizedString(@"Record Shortcut", @"LLHotKeyControl record shortcut");
}

#pragma mark - Events

- (void)mouseDown:(NSEvent *)event
{
	if (!self.enabled) {
		return;
	}
	
	BOOL mousedAccessory = CGRectContainsPoint(self.accessoryFrame, [self convertPoint:event.locationInWindow fromView:nil]);
	
	if (self.recording && mousedAccessory) {
		self.recording = NO;
		return;
	}
	
	if (!self.recording && self.hotKeyValue != nil && mousedAccessory) {
		self.hotKeyValue = nil;
		return;
	}
	
	if (!self.recording) {
		self.recording = YES;
		return;
	}
}

- (void)mouseEntered:(NSEvent *)event
{
	self.hoveringAccessory = YES;
}

- (void)mouseExited:(NSEvent *)event
{
	self.hoveringAccessory = NO;
}

#pragma mark - Tracking areas

- (void)updateTrackingAreas
{
	[super updateTrackingAreas];
	
	if (self.accessoryArea != nil) {
		[self removeTrackingArea:self.accessoryArea];
		self.accessoryArea = nil;
	}
	
	if (!self.enabled) {
		return;
	}
	
	NSTrackingArea *accessoryArea = [[NSTrackingArea alloc] initWithRect:self.accessoryFrame options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingAssumeInside) owner:self userInfo:nil];
	self.accessoryArea = accessoryArea;
	[self addTrackingArea:accessoryArea];
}

#pragma mark - Monitoring

- (void)setupEventMonitoring
{
	if (self.eventMonitor != nil) {
		return;
	}
	
	__weak typeof (self) welf = self;
	id eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:(NSKeyDownMask | NSFlagsChangedMask) handler:^ NSEvent * (NSEvent *event) {
		__strong typeof (welf) strelf = welf;
		return [strelf _handleLocalEvent:event];
	}];
	self.eventMonitor = eventMonitor;
}

- (void)teardownEventMonitoring
{
	if (self.eventMonitor == nil) {
		return;
	}
	
	[NSEvent removeMonitor:self.eventMonitor];
	self.eventMonitor = nil;
}

- (void)setupResignObserver
{
	if (self.resignObserver != nil) {
		return;
	}
	
	__weak typeof (self) welf = self;
	id resignObserver = [[NSNotificationCenter defaultCenter] addObserverForName:NSWindowDidResignKeyNotification object:self.window queue:[NSOperationQueue mainQueue] usingBlock:^ (NSNotification *notification) {
		__strong typeof (welf) strelf = welf;
		strelf.recording = NO;
	}];
	self.resignObserver = resignObserver;
}

- (void)teardownResignObserver
{
	if (self.resignObserver == nil) {
		return;
	}
	
	[[NSNotificationCenter defaultCenter] removeObserver:self.resignObserver];
	self.resignObserver = nil;
}

#pragma mark - Private

- (NSEvent *)_handleLocalEvent:(NSEvent *)event
{
	LLHotKey *hotKey = [LLHotKey hotKeyWithEvent:event];
	
	unsigned short keyCode = hotKey.keyCode;
	NSUInteger modifierFlags = (hotKey.modifierFlags & (NSControlKeyMask | NSAlternateKeyMask | NSShiftKeyMask | NSCommandKeyMask));
	
	if (keyCode == kVK_Delete || keyCode == kVK_ForwardDelete) {
		self.hotKeyValue = nil;
		self.recording = NO;
		return nil;
	}
	
	if (keyCode == kVK_Escape) {
		self.recording = NO;
		return nil;
	}
	
	if (modifierFlags == NSCommandKeyMask && (keyCode == kVK_ANSI_W || keyCode == kVK_ANSI_Q)) {
		self.recording = NO;
		return event;
	}
	
	if (LLHotKeyStringForKeyCode(keyCode).length == 0) {
		self.shortcutPlaceholder = LLHotKeyStringForModifiers(modifierFlags);
		return nil;
	}
	
	if (!LLHotKeyIsHotKeyValid(hotKey, event)) {
		return nil;
	}
	
	if (!LLHotKeyIsHotKeyAvailable(hotKey, event)) {
		NSBeep();
		self.shortcutPlaceholder = nil;
		return nil;
	}
	
	self.hotKeyValue = hotKey;
	self.recording = NO;
	
	return nil;
}

@end
