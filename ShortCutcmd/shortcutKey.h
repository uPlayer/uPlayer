
#include <string>
#import <Carbon/Carbon.h>
#import <LLHotKey.h>

using namespace std;

void saveFileShortcutKey();

bool verifyLoadFileShortcutKey();

/**
 *	perform command if the right shortcut key is pressed.
 *  @return: whether shortcut key is valid.
 */
bool shortcutKeyPressed(string shortcutKey, bool bGlobal);

///super: windows key or apple key
std::string msgKeytoString(bool ctrl, bool super, bool shift, bool alt, unsigned int vk);
std::string msgKeytoString(bool ctrl, unsigned int vk);

/// LLHotKey
NSArray * localHotKeysLoaded();
NSArray * globalHotKeysLoaded();
