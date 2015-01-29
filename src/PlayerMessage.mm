//
//  UPlayer.m
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//

#import "PlayerMessage.h"


void addObserverForEvent(id observer , SEL sel, enum EventID et)
{
    NSNotificationCenter *d =[NSNotificationCenter defaultCenter];
    
    [d addObserver:observer selector:sel name:arrEvent[et] object:nil];
}

void removeObserverForEvent(id observer , SEL sel, enum EventID et)
{
    NSNotificationCenter *d =[NSNotificationCenter defaultCenter];
    [d removeObserver:observer name:arrEvent[et] object:nil];
}

void removeObserver(id observer)
{
    NSNotificationCenter *d =[NSNotificationCenter defaultCenter];
    [d removeObserver:observer];
}


void postEvent(enum EventID et , id object)
{
    NSNotificationCenter *d =[NSNotificationCenter defaultCenter];
    [d postNotificationName:arrEvent[et] object:object];
}
