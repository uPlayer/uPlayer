//
//  _LLHotKeyObserver.m
//  LLHotKeyRecorder
//
//  Created by Damien DeVille on 5/3/14.
//  Copyright (c) 2014 Damien DeVille. All rights reserved.
//

#import "_LLHotKeyObserver.h"

@implementation _LLHotKeyObserver

+ (instancetype)observerWithObject:(id)object selector:(SEL)selector
{
	_LLHotKeyObserver *observer = [[_LLHotKeyObserver alloc] init];
	observer.object = object;
	observer.selector = selector;
	return observer;
}

- (BOOL)isEqual:(_LLHotKeyObserver *)object
{
	if (![object isKindOfClass:[self class]]) {
		return NO;
	}
	if (![object.object isEqual:self.object]) {
		return NO;
	}
	return YES;
}

- (NSUInteger)hash
{
	return [self.object hash];
}

@end
