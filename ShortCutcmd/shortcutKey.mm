#include "stdafx.h"
#include "shortcutKey.h"
#include "funcCmd.h"
#include <json/json.h>
#include <iostream>
#include <fstream>
#include "Util1.h"

#pragma once

using namespace std;


Json::Value root;
Json::Value rootLocal ;
Json::Value rootGlobal ;

char filepath[MAX_PATH];
//const char *filepath = NULL ;

/// return file loaded.
bool verifyLoadFileShortcutKey()
{
	static bool fileLoaded = false; 
	static bool loaded = false;

	if (loaded == false)
	{
		loaded = true;
	
		const char *mpath = ChangeCurDir2ModulePathA();

		strcpy(filepath,mpath);
		strcat(filepath,"\\keymaps.cfg");


		Json::Reader reader;


		std::filebuf fb;
		if (fb.open( filepath , std::ios::in))
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
    if (fb.open ( filepath ,std::ios::out))
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
		performCommand(value.asString());
		return true;
	}

	return false;
}



///super: windows key or apple key
string msgKeytoString(bool ctrl, bool super, bool shift, bool alt, unsigned int vk)
{
	string r;

	const int vkmapLen = 254;
	static const char *vkstrmap[vkmapLen];
	static bool vkStrMapInit = false;
	if (vkStrMapInit == false)
	{
		vkStrMapInit = true;

		vkstrmap[VK_F1] = "f1";
		vkstrmap[VK_F2] = "f2";
		vkstrmap[VK_F3] = "f3";
		vkstrmap[VK_F4] = "f4";
		vkstrmap[VK_F5] = "f5";
		vkstrmap[VK_F6] = "f6";
		vkstrmap[VK_F7] = "f7";
		vkstrmap[VK_F8] = "f8";
		vkstrmap[VK_F9] = "f9";
		vkstrmap[VK_F10] = "f10";
		vkstrmap[VK_F11] = "f11";
		vkstrmap[VK_F12] = "f12";

		vkstrmap[VK_OEM_PLUS] = "+";
		vkstrmap[VK_OEM_COMMA] = ",";
		vkstrmap[VK_OEM_MINUS] = "-";
		vkstrmap[VK_OEM_PERIOD] = ".";
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
