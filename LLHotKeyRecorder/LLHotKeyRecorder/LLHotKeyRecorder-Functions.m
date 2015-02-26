//
//  LLHotKeyRecorder-Functions.m
//  LLHotKeyRecorder
//
//  Created by Damien DeVille on 5/3/14.
//  Copyright (c) 2014 Damien DeVille. All rights reserved.
//

#import "LLHotKeyRecorder-Functions.h"

#import <Carbon/Carbon.h>

#import "LLHotKey.h"

NSString *LLHotKeyStringForModifiers(NSUInteger modifiers)
{
	NSMutableString *modifiersString = [NSMutableString string];
	
	void (^addKey)(unichar) = ^ void (unichar key) {
		[modifiersString appendString:[NSString stringWithFormat:@"%C", key]];
	};
	
	if ((modifiers & NSControlKeyMask) == NSControlKeyMask) {
		addKey(kControlUnicode);
	}
	if ((modifiers & NSAlternateKeyMask) == NSAlternateKeyMask) {
		addKey(kOptionUnicode);
	}
	if ((modifiers & NSShiftKeyMask) == NSShiftKeyMask) {
		addKey(kShiftUnicode);
	}
	if ((modifiers & NSCommandKeyMask) == NSCommandKeyMask) {
		addKey(kCommandUnicode);
	}
	
	return modifiersString ? : @"";
}

NSString *LLHotKeyStringForKeyCode(unsigned short keyCode)
{
	switch (keyCode) {
		case kVK_F1: return @"F1";
		case kVK_F2: return @"F2";
		case kVK_F3: return @"F3";
		case kVK_F4: return @"F4";
		case kVK_F5: return @"F5";
		case kVK_F6: return @"F6";
		case kVK_F7: return @"F7";
		case kVK_F8: return @"F8";
		case kVK_F9: return @"F9";
		case kVK_F10: return @"F10";
		case kVK_F11: return @"F11";
		case kVK_F12: return @"F12";
		case kVK_F13: return @"F13";
		case kVK_F14: return @"F14";
		case kVK_F15: return @"F15";
		case kVK_F16: return @"F16";
		case kVK_F17: return @"F17";
		case kVK_F18: return @"F18";
		case kVK_F19: return @"F19";
		case kVK_Space: return @"\u23B5";
		case kVK_Escape: return @"\u238B";
		case kVK_Delete: return @"\u232B";
		case kVK_ForwardDelete: return @"\u2326";
		case kVK_LeftArrow: return @"\u2190";
		case kVK_RightArrow: return @"\u2192";
		case kVK_UpArrow: return @"\u2191";
		case kVK_DownArrow: return @"\u2193";
		case kVK_PageUp: return @"\u21DE";
		case kVK_PageDown: return @"\u21DF";
		case kVK_Tab: return @"\u21E5";
		case kVK_Return: return @"\u21A9";
		case kVK_ANSI_Keypad0: return @"0";
		case kVK_ANSI_Keypad1: return @"1";
		case kVK_ANSI_Keypad2: return @"2";
		case kVK_ANSI_Keypad3: return @"3";
		case kVK_ANSI_Keypad4: return @"4";
		case kVK_ANSI_Keypad5: return @"5";
		case kVK_ANSI_Keypad6: return @"6";
		case kVK_ANSI_Keypad7: return @"7";
		case kVK_ANSI_Keypad8: return @"8";
		case kVK_ANSI_Keypad9: return @"9";
		case kVK_ANSI_KeypadDecimal: return @".";
		case kVK_ANSI_KeypadMultiply: return @"*";
		case kVK_ANSI_KeypadPlus: return @"+";
		case kVK_ANSI_KeypadClear: return @"\u2327";
		case kVK_ANSI_KeypadDivide: return @"/";
		case kVK_ANSI_KeypadEnter: return @"\u2305";
		case kVK_ANSI_KeypadMinus: return @"–";
		case kVK_ANSI_KeypadEquals: return @"=";
		case 119: return @"\u2198";
		case 115: return @"\u2196";
	}
	
	NSString *keystroke = nil;
	
	TISInputSourceRef inputSource = TISCopyCurrentKeyboardLayoutInputSource();
	if (inputSource != NULL) {
		CFDataRef layoutData = TISGetInputSourceProperty(inputSource, kTISPropertyUnicodeKeyLayoutData);
		UCKeyboardLayout *keyboardLayout = (UCKeyboardLayout *)CFDataGetBytePtr(layoutData);
		UniCharCount length = 0;
		UniChar chars[256] = {};
		UInt32 deadKeyState = 0;
		OSStatus status = UCKeyTranslate(keyboardLayout, (UInt16)keyCode, kUCKeyActionDisplay, 0, LMGetKbdType(), kUCKeyTranslateNoDeadKeysMask, &deadKeyState, sizeof(chars) / sizeof(UniChar), &length, chars);
		CFRelease(inputSource);
		
		if (length > 0 && status == noErr) {
			keystroke = [NSString stringWithCharacters:chars length:length];
		}
	}
	
	return [keystroke uppercaseString] ? : @"";
}

NSString *LLHotKeyStringForHotKey(LLHotKey *hotKey)
{
	return [NSString stringWithFormat:@"%@%@", LLHotKeyStringForModifiers([hotKey modifierFlags]), LLHotKeyStringForKeyCode([hotKey keyCode])];
}

static BOOL _LLHotKeyCanUseKeyEquivalent(NSEvent *event, NSMenu *menu)
{
	static NSButton *button = nil;
	static dispatch_once_t onceToken = 0;
	dispatch_once(&onceToken, ^ {
		button = [[NSButton alloc] initWithFrame:CGRectZero];
	});
	
	for (NSMenuItem *currentMenuItem in [menu itemArray]) {
		if ([currentMenuItem hasSubmenu]) {
			if (!_LLHotKeyCanUseKeyEquivalent(event, [currentMenuItem submenu])) {
				return NO;
			}
		}
		
		[button setKeyEquivalent:[currentMenuItem keyEquivalent]];
		[button setKeyEquivalentModifierMask:[currentMenuItem keyEquivalentModifierMask]];
		
		if ([button performKeyEquivalent:event]) {
			return NO;
		}
	}
	return YES;
}

BOOL LLHotKeyIsHotKeyAvailable(LLHotKey *hotKey, NSEvent *event)
{
	CFArrayRef hotKeys = NULL;
	OSStatus copied = CopySymbolicHotKeys(&hotKeys);
	
	if (copied != 0) {
		return NO;
	}
	
	for (CFIndex idx = 0; idx < CFArrayGetCount(hotKeys); idx++) {
		NSDictionary *hotKeyInfo = (__bridge NSDictionary *)CFArrayGetValueAtIndex(hotKeys, idx);
		
		unsigned short keyCode = (unsigned short)[hotKeyInfo[(id)kHISymbolicHotKeyCode] unsignedIntegerValue];
		NSUInteger modifierFlags = [hotKeyInfo[(id)kHISymbolicHotKeyModifiers] unsignedIntegerValue];
		
		if ([hotKey keyCode] == keyCode && [hotKey modifierFlags] == modifierFlags) {
			return NO;
		}
	}
	
	CFRelease(hotKeys);
	
	if (!_LLHotKeyCanUseKeyEquivalent(event, [[NSApplication sharedApplication] mainMenu])) {
		return NO;
	}
	
	return YES;
}

BOOL LLHotKeyIsHotKeyValid(LLHotKey *hotKey, NSEvent *event)
{
	unsigned short keyCode = [hotKey keyCode];
	NSUInteger modifierFlags = [hotKey modifierFlags];
	
	BOOL includesFunctionKey = ((keyCode == kVK_F1) || (keyCode == kVK_F2) || (keyCode == kVK_F3) || (keyCode == kVK_F4) || (keyCode == kVK_F5) || (keyCode == kVK_F6) || (keyCode == kVK_F7) || (keyCode == kVK_F8) || (keyCode == kVK_F9) || (keyCode == kVK_F10) || (keyCode == kVK_F11) || (keyCode == kVK_F12) || (keyCode == kVK_F13) || (keyCode == kVK_F14) || (keyCode == kVK_F15) || (keyCode == kVK_F16) || (keyCode == kVK_F17) || (keyCode == kVK_F18) || (keyCode == kVK_F19) || (keyCode == kVK_F20));
	if (includesFunctionKey) {
		return YES;
	}
	
	BOOL hasModifierFlags = (modifierFlags > 0);
	if (!hasModifierFlags) {
		return NO;
	}
	
	BOOL includesCommand = ((modifierFlags & NSCommandKeyMask) > 0);
	BOOL includesControl = ((modifierFlags & NSControlKeyMask) > 0);
	if (includesCommand || includesControl) {
		return YES;
	}
	
	BOOL includesOption = ((modifierFlags & NSAlternateKeyMask) > 0);
	if (includesOption && ((keyCode == kVK_Space) || (keyCode == kVK_Escape))) {
		return YES;
	}
	
	return NO;
}