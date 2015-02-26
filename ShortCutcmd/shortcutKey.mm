
#include "shortcutKey.h"

#include <json/json.h>
#include <iostream>
#include <fstream>

#import "ThreadJob.h"
#import <Carbon/Carbon.h>
#include "PlayerMessage.h"
#import <LLHotKeyRecorder-Functions.h>
using namespace std;


Json::Value root;
Json::Value rootLocal ;
Json::Value rootGlobal ;


NSString *filepath = nil;

/// return file loaded.
bool verifyLoadFileShortcutKey()
{
	static bool fileLoaded = false; 
	static bool loaded = false;

	if (loaded == false)
	{
		loaded = true;
	
		filepath = [ApplicationSupportDirectory() stringByAppendingPathComponent:@"keymaps.json"];


		Json::Reader reader;

		std::filebuf fb;
		if (fb.open( filepath.UTF8String , std::ios::in))
		{		
			fileLoaded = true;
			std::istream is(&fb);
			reader.parse(is, root);

			rootLocal = root["local"];
			rootGlobal = root["Global"];

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
	if (bGlobal)
		value = rootGlobal[shortcutKey];
	else
		value = rootLocal[shortcutKey];

	if (!value.isNull())
	{
        postEventByString( [NSString stringWithUTF8String: value.asString().c_str()] , nil);
//		performCommand(value.asString());
		return true;
	}

	return false;
}



///super: windows key or apple key
string msgKeytoString(bool ctrl, bool super, bool shift, bool alt, unsigned int vk)
{
	string r;

//    NSString *aa = LLHotKeyStringForKeyCode(vk);
    
	const int vkmapLen = 254;
	static const char *vkstrmap[vkmapLen];
	static bool vkStrMapInit = false;
	if (vkStrMapInit == false)
	{
		vkStrMapInit = true;

		vkstrmap[kVK_F1] = "f1";
		vkstrmap[kVK_F2] = "f2";
		vkstrmap[kVK_F3] = "f3";
		vkstrmap[kVK_F4] = "f4";
		vkstrmap[kVK_F5] = "f5";
		vkstrmap[kVK_F6] = "f6";
		vkstrmap[kVK_F7] = "f7";
		vkstrmap[kVK_F8] = "f8";
		vkstrmap[kVK_F9] = "f9";
		vkstrmap[kVK_F10] = "f10";
		vkstrmap[kVK_F11] = "f11";
		vkstrmap[kVK_F12] = "f12";

//		vkstrmap[kVK_OEM_PLUS] = "+";
//		vkstrmap[kVK_OEM_COMMA] = ",";
//		vkstrmap[kVK_OEM_MINUS] = "-";
//		vkstrmap[kVK_OEM_PERIOD] = ".";
	}

	if (ctrl)
		r += ("ctrl+");
	if (super)
		r += ("super+");
	if (shift)
		r += ("shift+");
	if (alt)
		r += ("alt+");

	/*
	* VK_0 - VK_9 are the same as ASCII '0' - '9' (0x30 - 0x39)
	* 0x40 : unassigned
	* VK_A - VK_Z are the same as ASCII 'A' - 'Z' (0x41 - 0x5A)
	*/
	if ('A' <= vk && vk <= 'Z')
		r += (char)vk - ('A' - 'a');
	else if (vk <= vkmapLen)
	{
		const char *p = vkstrmap[vk];
		if (p)
			r += p;
	}

	return r;
}

string msgKeytoString(bool ctrl, unsigned int vk)
{
	return msgKeytoString(ctrl, false, false, false, vk);
}
