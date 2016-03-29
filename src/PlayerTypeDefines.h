//
//  PlayerTypeDefines.h
//  uPlayer
//
//  Created by liaogang on 15/1/27.
//  Copyright (c) 2015年 liaogang. All rights reserved.
//


#import <Foundation/Foundation.h>


typedef NS_ENUM(int, PlayOrder)
{
    playorder_default ,
    playorder_random ,
    playorder_repeat_single ,
    playorder_repeat_list ,
    playorder_shuffle,
    playorder_single
};


#define kPlayOrder (  @[ \
NSLocalizedString(@"default", nil),\
NSLocalizedString(@"random" ,nil),\
NSLocalizedString(@"repeat-single" ,nil),\
NSLocalizedString(@"repeat-list" ,nil),\
NSLocalizedString(@"shuffle",nil),\
NSLocalizedString(@"single",nil),\
])


enum PlayState
{
    playstate_stopped,
    playstate_playing,
    playstate_paused,
    playstate_pending
};


struct PlayStateTime
{
    enum PlayState state;
    NSTimeInterval time;
    CGFloat volume;
};



#define docFileName  @"config.plist"
//#define docFileNameLastSuccessfullyLoaded @"core_last.cfg"
//#define docFileNameLock @"loadConfig.lock"

#define layoutFileName  @"ui.cfg"
#define layoutFileNameLastSuccessfullyLoaded  @"ui_last.cfg"
#define layoutFileNameLock  @"ui.cfg.lock"


//几个配置文件的版本，当程序修改之后与之前的不兼容时，把版本号加一
enum
{
    DocumentConfigFile_Version = 1,
    LayoutFile_Version = 1,
    Playlist_Version = 1
};


#define keyblindingFileName @"keymaps.json"
#define playlistDirectoryName @"playlist"



enum PlayerListType
{
    type_normal,
    type_temporary
};

