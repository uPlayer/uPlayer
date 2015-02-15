//
//  AppPreferences.m
//  PrefsTest
//
//  Created by Dave Jewell on 13/12/2007.
//  Copyright 2007 Dave Jewell. All rights reserved.
//

#import "AppPreferences.h"
#import "GeneralPreferences.h"
//#import "HotKeyPreferences.h"
#import "AccountPreferences.h"

@implementation AppPreferences

- (id) init
{	
	_nsBeginNSPSupport();			// MUST come before [super init]
	self = [super init];
    
	[self addPreferenceNamed: @"General" owner: [GeneralPreferences sharedInstance]];
	[self addPreferenceNamed: @"Account" owner: [AccountPreferences sharedInstance]];
	//[self addPreferenceNamed: @"HotKeys" owner: [HotKeyPreferences sharedInstance]];
	 return self;
}

- (BOOL) usesButtons
{
	return NO;
}

@end
