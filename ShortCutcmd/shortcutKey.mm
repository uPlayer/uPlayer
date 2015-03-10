
#import "shortcutKey.h"

#include <json/json.h>
#include <iostream>
#include <fstream>

#import "ThreadJob.h"
#import "PlayerMessage.h"
#import "PlayerTypeDefines.h"
#import "keycode.h"

using namespace std;

#define kCtrl "ctrl"
#define kSuper "super"
#define kShift "shift"
#define kAlt "alt"

void copyDefaultKeymapsToIfNotExists(NSString *dstPath)
{
    if( ![[NSFileManager defaultManager] fileExistsAtPath: dstPath] )
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"keymaps" ofType:@"json"];
        
        NSError *error;
        
        [[NSFileManager defaultManager] copyItemAtPath:path toPath:dstPath error:&error];
        
        if ( error ) {
            NSLog(@"%@",error);
        }
    }
    
}


Json::Value root;


NSString *filepath = nil;

/// return file loaded.
bool verifyLoadFileShortcutKey()
{
	static bool fileLoaded = false; 
	static bool loaded = false;

	if (loaded == false)
	{
		loaded = true;
	
		filepath = [ApplicationSupportDirectory() stringByAppendingPathComponent: keyblindingFileName ];
        
        copyDefaultKeymapsToIfNotExists(filepath);

        
		Json::Reader reader;

		std::filebuf fb;
		if (fb.open( filepath.UTF8String , std::ios::in))
		{		
			fileLoaded = true;
			std::istream is(&fb);
			reader.parse(is, root);


			fb.close();
		}
		else
		{
			//@todo generate a error message.

		}

	}

	return fileLoaded;
}

void saveFileShortcutKey()
{
	std::filebuf fb;
    if (fb.open ( filepath.UTF8String ,std::ios::out))
    {
        std::ostream out(&fb);
            
        Json::StyledStreamWriter writer;
        writer.write( out , root);
        
        fb.close();
    }
    else
    {
    	//generate a error message.

    }

}


/**
 *	perfrom command if the right shortcut key is pressed.
 *  @return: wether shortcut key is valid.
 */
bool shortcutKeyPressed(string shortcutKey, bool bGlobal)
{
	//shortcutKey to `command`
	verifyLoadFileShortcutKey();


	Json::Value value;

    value = root[shortcutKey];


	if (!value.isNull())
	{
        postEventByString( [NSString stringWithUTF8String: value.asString().c_str()] , nil);

		return true;
	}

	return false;
}

///super: windows key or apple key
string msgKeytoString(bool ctrl, bool super, bool shift, bool alt, unsigned int vk)
{
	string r;
	if (ctrl)
		r += ("ctrl+");
	if (super)
		r += ("super+");
	if (shift)
		r += ("shift+");
	if (alt)
		r += ("alt+");

    NSString *key = keyStringFormKeyCode(vk);
    
    r += key.UTF8String;

	return r;
}

string msgKeytoString(bool ctrl, unsigned int vk)
{
	return msgKeytoString(ctrl, false, false, false, vk);
}

NSArray* hotKeysLoaded(Json::Value &_root)
{
    int size = _root.size();
    if (size > 0) {
        NSMutableArray *hotkeyArr= [NSMutableArray array];
        
        auto members = _root.getMemberNames();
        for (int i = 0; i < size ; i++) {

            const char* keyString = members[i].c_str();
            
            unsigned short keycode;
            NSUInteger modifierFlags = 0;
            
            if( strstr(keyString, kCtrl) )
                modifierFlags |= NSControlKeyMask;
            
            if( strstr(keyString, kSuper) )
                modifierFlags |= NSCommandKeyMask;
            
            if( strstr(keyString, kAlt) )
                modifierFlags |= NSAlternateKeyMask;
            
            if( strstr(keyString, kShift) )
                modifierFlags |= NSShiftKeyMask;
            

            int len = (int)strlen(keyString);
            char l = keyString[len-1];
            

            keycode = keyCodeFormKeyString( [NSString stringWithFormat:@"%c",l] );
            
            
            LLHotKey *hotkey=[LLHotKey hotKeyWithKeyCode:keycode modifierFlags:modifierFlags];
            [hotkeyArr addObject:hotkey];
        }

        return hotkeyArr;
    }
    
    return nil;
}


NSArray* globalHotKeysLoaded()
{
    return hotKeysLoaded(root);
}

