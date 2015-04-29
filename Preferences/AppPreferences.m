//
//  AppPreferences.m
//  PrefsTest
//
//  Created by Dave Jewell on 13/12/2007.
//  Copyright 2007 Dave Jewell. All rights reserved.
//

#import "AppPreferences.h"
#import "GeneralPreferences.h"
#import "HotKeyPreferences.h"
#import "AccountPreferences.h"

@implementation AppPreferences

- (id) init
{	
	_nsBeginNSPSupport();			// MUST come before [super init]
	self = [super init];
    
	[self addPreferenceNamed: NSLocalizedString( @"General",nil) owner: [GeneralPreferences sharedInstance]];
	[self addPreferenceNamed: NSLocalizedString(@"Account",nil) owner: [AccountPreferences sharedInstance]];
	//[self addPreferenceNamed: NSLocalizedString(@"HotKeys",nil) owner: [HotKeyPreferences sharedInstance]];
	 return self;
}

- (BOOL) usesButtons
{
	return NO;
}

@end
