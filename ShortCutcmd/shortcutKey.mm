
#import "shortcutKey.h"

#include <json/json.h>
#include <iostream>
#include <fstream>

#import "ThreadJob.h"
#import "PlayerMessage.h"
#import "PlayerTypeDefines.h"

using namespace std;

#define kCtrl "ctrl"
#define kSuper "super"
#define kShift "shift"
#define kAlt "alt"


NSString *keyStringFormKeyCode(CGKeyCode keyCode)
{
    // Proper key detection seems to want a switch statement, unfortunately
    switch (keyCode)
    {
        case 0: return @"a";
        case 1: return @"s";
        case 2: return @"d";
        case 3: return @"f";
        case 4: return @"h";
        case 5: return @"g";
        case 6: return @"z";
        case 7: return @"x";
        case 8: return @"c";
        case 9: return @"v";
            // what is 10?
        case 11: return @"b";
        case 12: return @"q";
        case 13: return @"w";
        case 14: return @"e";
        case 15: return @"r";
        case 16: return @"y";
        case 17: return @"t";
        case 18: return @"1";
        case 19: return @"2";
        case 20: return @"3";
        case 21: return @"4";
        case 22: return @"6";
        case 23: return @"5";
        case 24: return @"=";
        case 25: return @"9";
        case 26: return @"7";
        case 27: return @"-";
        case 28: return @"8";
        case 29: return @"0";
        case 30: return @"]";
        case 31: return @"o";
        case 32: return @"u";
        case 33: return @"[";
        case 34: return @"i";
        case 35: return @"p";
        case 36: return @"RETURN";
        case 37: return @"l";
        case 38: return @"j";
        case 39: return @"'";
        case 40: return @"k";
        case 41: return @";";
        case 42: return @"\\";
        case 43: return @",";
        case 44: return @"/";
        case 45: return @"n";
        case 46: return @"m";
        case 47: return @".";
        case 48: return @"TAB";
        case 49: return @"SPACE";
        case 50: return @"`";
        case 51: return @"DELETE";
        case 52: return @"ENTER";
        case 53: return @"ESCAPE";
            
            // some more missing codes abound, reserved I presume, but it would
            // have been helpful for Apple to have a document with them all listed
            
        case 65: return @".";
            
        case 67: return @"*";
            
        case 69: return @"+";
            
        case 71: return @"CLEAR";
            
        case 75: return @"/";
        case 76: return @"ENTER";   // numberpad on full kbd
            
        case 78: return @"-";
            
        case 81: return @"=";
        case 82: return @"0";
        case 83: return @"1";
        case 84: return @"2";
        case 85: return @"3";
        case 86: return @"4";
        case 87: return @"5";
        case 88: return @"6";
        case 89: return @"7";
            
        case 91: return @"8";
        case 92: return @"9";
            
        case 96: return @"F5";
        case 97: return @"F6";
        case 98: return @"F7";
        case 99: return @"F3";
        case 100: return @"F8";
        case 101: return @"F9";
            
        case 103: return @"F11";
            
        case 105: return @"F13";
            
        case 107: return @"F14";
            
        case 109: return @"F10";
            
        case 111: return @"F12";
            
        case 113: return @"F15";
        case 114: return @"HELP";
        case 115: return @"HOME";
        case 116: return @"PGUP";
        case 117: return @"DELETE";  // full keyboard right side numberpad
        case 118: return @"F4";
        case 119: return @"END";
        case 120: return @"F2";
        case 121: return @"PGDN";
        case 122: return @"F1";
        case 123: return @"LEFT";
        case 124: return @"RIGHT";
        case 125: return @"DOWN";
        case 126: return @"UP";
            
        default:
            
            return @"Unknown key";
            // Unknown key, bail and note that RUI needs improvement
            //fprintf(stderr, "%ld\tKey\t%c (DEBUG: %d)\n", currenttime, keyCode;
            //exit(EXIT_FAILURE;
    }
}

CGKeyCode keyCodeFormKeyString(NSString *keyString)
{
    if ([keyString isEqualToString:@"a"]) return 0;
    if ([keyString isEqualToString:@"s"]) return 1;
    if ([keyString isEqualToString:@"d"]) return 2;
    if ([keyString isEqualToString:@"f"]) return 3;
    if ([keyString isEqualToString:@"h"]) return 4;
    if ([keyString isEqualToString:@"g"]) return 5;
    if ([keyString isEqualToString:@"z"]) return 6;
    if ([keyString isEqualToString:@"x"]) return 7;
    if ([keyString isEqualToString:@"c"]) return 8;
    if ([keyString isEqualToString:@"v"]) return 9;
    // what is 10?
    if ([keyString isEqualToString:@"b"]) return 11;
    if ([keyString isEqualToString:@"q"]) return 12;
    if ([keyString isEqualToString:@"w"]) return 13;
    if ([keyString isEqualToString:@"e"]) return 14;
    if ([keyString isEqualToString:@"r"]) return 15;
    if ([keyString isEqualToString:@"y"]) return 16;
    if ([keyString isEqualToString:@"t"]) return 17;
    if ([keyString isEqualToString:@"1"]) return 18;
    if ([keyString isEqualToString:@"2"]) return 19;
    if ([keyString isEqualToString:@"3"]) return 20;
    if ([keyString isEqualToString:@"4"]) return 21;
    if ([keyString isEqualToString:@"6"]) return 22;
    if ([keyString isEqualToString:@"5"]) return 23;
    if ([keyString isEqualToString:@"="]) return 24;
    if ([keyString isEqualToString:@"9"]) return 25;
    if ([keyString isEqualToString:@"7"]) return 26;
    if ([keyString isEqualToString:@"-"]) return 27;
    if ([keyString isEqualToString:@"8"]) return 28;
    if ([keyString isEqualToString:@"0"]) return 29;
    if ([keyString isEqualToString:@"]"]) return 30;
    if ([keyString isEqualToString:@"o"]) return 31;
    if ([keyString isEqualToString:@"u"]) return 32;
    if ([keyString isEqualToString:@"["]) return 33;
    if ([keyString isEqualToString:@"i"]) return 34;
    if ([keyString isEqualToString:@"p"]) return 35;
    if ([keyString isEqualToString:@"RETURN"]) return 36;
    if ([keyString isEqualToString:@"l"]) return 37;
    if ([keyString isEqualToString:@"j"]) return 38;
    if ([keyString isEqualToString:@"'"]) return 39;
    if ([keyString isEqualToString:@"k"]) return 40;
    if ([keyString isEqualToString:@";"]) return 41;
    if ([keyString isEqualToString:@"\\"]) return 42;
    if ([keyString isEqualToString:@","]) return 43;
    if ([keyString isEqualToString:@"/"]) return 44;
    if ([keyString isEqualToString:@"n"]) return 45;
    if ([keyString isEqualToString:@"m"]) return 46;
    if ([keyString isEqualToString:@"."]) return 47;
    if ([keyString isEqualToString:@"TAB"]) return 48;
    if ([keyString isEqualToString:@"SPACE"]) return 49;
    if ([keyString isEqualToString:@"`"]) return 50;
    if ([keyString isEqualToString:@"DELETE"]) return 51;
    if ([keyString isEqualToString:@"ENTER"]) return 52;
    if ([keyString isEqualToString:@"ESCAPE"]) return 53;
    
    // some more missing codes abound, reserved I presume, but it would
    // have been helpful for Apple to have a document with them all listed
    
    if ([keyString isEqualToString:@"."]) return 65;
    
    if ([keyString isEqualToString:@"*"]) return 67;
    
    if ([keyString isEqualToString:@"+"]) return 69;
    
    if ([keyString isEqualToString:@"CLEAR"]) return 71;
    
    if ([keyString isEqualToString:@"/"]) return 75;
    if ([keyString isEqualToString:@"ENTER"]) return 76;  // numberpad on full kbd
    
    if ([keyString isEqualToString:@"="]) return 78;
    
    if ([keyString isEqualToString:@"="]) return 81;
    if ([keyString isEqualToString:@"0"]) return 82;
    if ([keyString isEqualToString:@"1"]) return 83;
    if ([keyString isEqualToString:@"2"]) return 84;
    if ([keyString isEqualToString:@"3"]) return 85;
    if ([keyString isEqualToString:@"4"]) return 86;
    if ([keyString isEqualToString:@"5"]) return 87;
    if ([keyString isEqualToString:@"6"]) return 88;
    if ([keyString isEqualToString:@"7"]) return 89;
    
    if ([keyString isEqualToString:@"8"]) return 91;
    if ([keyString isEqualToString:@"9"]) return 92;
    
    if ([keyString isEqualToString:@"F5"]) return 96;
    if ([keyString isEqualToString:@"F6"]) return 97;
    if ([keyString isEqualToString:@"F7"]) return 98;
    if ([keyString isEqualToString:@"F3"]) return 99;
    if ([keyString isEqualToString:@"F8"]) return 100;
    if ([keyString isEqualToString:@"F9"]) return 101;
    
    if ([keyString isEqualToString:@"F11"]) return 103;
    
    if ([keyString isEqualToString:@"F13"]) return 105;
    
    if ([keyString isEqualToString:@"F14"]) return 107;
    
    if ([keyString isEqualToString:@"F10"]) return 109;
    
    if ([keyString isEqualToString:@"F12"]) return 111;
    
    if ([keyString isEqualToString:@"F15"]) return 113;
    if ([keyString isEqualToString:@"HELP"]) return 114;
    if ([keyString isEqualToString:@"HOME"]) return 115;
    if ([keyString isEqualToString:@"PGUP"]) return 116;
    if ([keyString isEqualToString:@"DELETE"]) return 117;
    if ([keyString isEqualToString:@"F4"]) return 118;
    if ([keyString isEqualToString:@"END"]) return 119;
    if ([keyString isEqualToString:@"F2"]) return 120;
    if ([keyString isEqualToString:@"PGDN"]) return 121;
    if ([keyString isEqualToString:@"F1"]) return 122;
    if ([keyString isEqualToString:@"LEFT"]) return 123;
    if ([keyString isEqualToString:@"RIGHT"]) return 124;
    if ([keyString isEqualToString:@"DOWN"]) return 125;
    if ([keyString isEqualToString:@"UP"]) return 126;
    
    return 0;
    //fprintf(stderr, "keyString %s Not Found. Aborting...\n", keyString);
    //exit(EXIT_FAILURE);
}


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
	
		filepath = [ApplicationSupportDirectory() stringByAppendingPathComponent: keyblindingFileName ];


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

//CGKeyCode keyCodeForChar(const char c)
//{
//    static CFMutableDictionaryRef charToCodeDict = NULL;
//    CGKeyCode code;
//    UniChar character = c;
//    CFStringRef charStr = NULL;
//    
//    /* Generate table of keycodes and characters. */
//    if (charToCodeDict == NULL) {
//        size_t i;
//        charToCodeDict = CFDictionaryCreateMutable(kCFAllocatorDefault,
//                                                   128,
//                                                   &kCFCopyStringDictionaryKeyCallBacks,
//                                                   NULL);
//        if (charToCodeDict == NULL) return UINT16_MAX;
//        
//        /* Loop through every keycode (0 - 127) to find its current mapping. */
//        for (i = 0; i < 128; ++i) {
//            CFStringRef string = createStringForKey((CGKeyCode)i);
//            if (string != NULL) {
//                CFDictionaryAddValue(charToCodeDict, string, (const void *)i);
//                CFRelease(string);
//            }
//        }
//    }
//    
//    charStr = CFStringCreateWithCharacters(kCFAllocatorDefault, &character, 1);
//    
//    /* Our values may be NULL (0), so we need to use this function. */
//    if (!CFDictionaryGetValueIfPresent(charToCodeDict, charStr,
//                                       (const void **)&code)) {
//        code = UINT16_MAX;
//    }
//    
//    CFRelease(charStr);
//    return code;
//}

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
            
//            NSLog(@"%c",l);
//            NSLog(@"%s", ((__bridge NSString*)createStringForKey(keycode)).UTF8String );
            
            LLHotKey *hotkey=[LLHotKey hotKeyWithKeyCode:keycode modifierFlags:modifierFlags];
            [hotkeyArr addObject:hotkey];
        }
        
//        NSLog(@"%@",hotkeyArr);
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
