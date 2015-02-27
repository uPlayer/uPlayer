
#import "shortcutKey.h"

#include <json/json.h>
#include <iostream>
#include <fstream>

#import "ThreadJob.h"
#import "PlayerMessage.h"

using namespace std;

#define kCtrl "ctrl"
#define kSuper "super"
#define kShift "shift"
#define kAlt "alt"


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

		return true;
	}

	return false;
}

/* Returns string representation of key, if it is printable.
 * Ownership follows the Create Rule; that is, it is the caller's
 * responsibility to release the returned object. */
CFStringRef createStringForKey(CGKeyCode keyCode)
{
    TISInputSourceRef currentKeyboard = TISCopyCurrentKeyboardInputSource();
    CFDataRef layoutData =
    (CFDataRef)TISGetInputSourceProperty(currentKeyboard,
                              kTISPropertyUnicodeKeyLayoutData);
    const UCKeyboardLayout *keyboardLayout =
    (const UCKeyboardLayout *)CFDataGetBytePtr(layoutData);
    
    UInt32 keysDown = 0;
    UniChar chars[4];
    UniCharCount realLength;
    
    UCKeyTranslate(keyboardLayout,
                   keyCode,
                   kUCKeyActionDisplay,
                   0,
                   LMGetKbdType(),
                   kUCKeyTranslateNoDeadKeysBit,
                   &keysDown,
                   sizeof(chars) / sizeof(chars[0]),
                   &realLength,
                   chars);
    CFRelease(currentKeyboard);
    
    return CFStringCreateWithCharacters(kCFAllocatorDefault, chars, 1);
}


/* Returns key code for given character via the above function, or UINT16_MAX
 * on error. */
CGKeyCode keyCodeForChar(const char c)
{
    static CFMutableDictionaryRef charToCodeDict = NULL;
    CGKeyCode code;
    UniChar character = c;
    CFStringRef charStr = NULL;
    
    /* Generate table of keycodes and characters. */
    if (charToCodeDict == NULL) {
        size_t i;
        charToCodeDict = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                                   128,
                                                   &kCFCopyStringDictionaryKeyCallBacks,
                                                   NULL);
        if (charToCodeDict == NULL) return UINT16_MAX;
        
        /* Loop through every keycode (0 - 127) to find its current mapping. */
        for (i = 0; i < 128; ++i) {
            CFStringRef string = createStringForKey((CGKeyCode)i);
            if (string != NULL) {
                CFDictionaryAddValue(charToCodeDict, string, (const void *)i);
                CFRelease(string);
            }
        }
    }
    
    charStr = CFStringCreateWithCharacters(kCFAllocatorDefault, &character, 1);
    
    /* Our values may be NULL (0), so we need to use this function. */
    if (!CFDictionaryGetValueIfPresent(charToCodeDict, charStr,
                                       (const void **)&code)) {
        code = UINT16_MAX;
    }
    
    CFRelease(charStr);
    return code;
}

///super: windows key or apple key
string msgKeytoString(bool ctrl, bool super, bool shift, bool alt, unsigned int vk)
{

    
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

	string r;
	if (ctrl)
		r += ("ctrl+");
	if (super)
		r += ("super+");
	if (shift)
		r += ("shift+");
	if (alt)
		r += ("alt+");

    NSString *key = (__bridge NSString *) createStringForKey( vk );
    r += key.UTF8String;

	return r;
}

string msgKeytoString(bool ctrl, unsigned int vk)
{
	return msgKeytoString(ctrl, false, false, false, vk);
}

NSArray* hotKeysLoaded(Json::Value root)
{
    int size = root.size();
    if (size > 0) {
        NSMutableArray *hotkeyArr= [ NSMutableArray array];
        
        for (int i = 0; i < size ; i++) {
            Json::Value v = root[i];
            const char* keyString = v.asCString();
            
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
            keycode = l;
            
            LLHotKey *hotkey=[LLHotKey hotKeyWithKeyCode:keycode modifierFlags:modifierFlags];
            [hotkeyArr addObject:hotkey];
        }
        return hotkeyArr;
    }
    
    return nil;
}

NSArray* localHotKeysLoaded()
{
    return hotKeysLoaded(rootLocal);
}

NSArray* globalHotKeysLoaded()
{
    return hotKeysLoaded(rootGlobal);
}
