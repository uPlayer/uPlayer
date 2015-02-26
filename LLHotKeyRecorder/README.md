# LLHotKeyRecorder

### A very simple framework to set up hot keys in a Cocoa application

## Use

`LLHotKeyRecorder` works very similarly to `NSNotificationCenter`. Following is a simple example of how to add (and remove) and observer for a given hot key.

```
- (void)setup
{
	LLHotKey *hotKey = [LLHotKey hotKeyWithKeyCode:kVK_ANSI_K modifierFlags:(NSControlKeyMask | NSCommandKeyMask)];
	[[LLHotKeyCenter defaultCenter] addObserver:self selector:@selector(hotKeyTriggered):) hotKey:hotKey];
}

- (void)hotKeyTriggered:(LLHotKey *)hotKey
{
	[[LLHotKeyCenter defaultCenter] removeObserver:self hotKey:hotKey];
}

```

## UI

`LLHotKeyRecorder` comes with an `NSControl` subclass that can be used to record a hot key. It is very simple to use and behaves just like a normal `NSControl`. You can add a target and action and it will be notified every time the `hotKeyValue` changed.

## User Defaults

`LLHotKeyRecorder` also comes with a couple of convenience methods so that storing and retrieving a `LLHotKey` from the user defaults is easy. Here is a simple example.

```
LLHotKey *hotKey = [LLHotKey hotKeyWithKeyCode:kVK_ANSI_B modifierFlags:(NSControlKeyMask | NSCommandKeyMask)];
[[NSUserDefaults standardUserDefaults] setHotKey:hotKey forKey:@"HotKey"];

LLHotKey *restoredHotKey = [[NSUserDefaults standardUserDefaults] hotKeyForKey:@"HotKey"];
```

## Installation

You can simply drag the `LLHotKeyRecorder` project as a subproject in your application main project. You will then have to add the framework as a Target Dependency in the Build Phases, link to the framework by adding it to the Link Binary with Libraries in the target Build Phases. Finally you will have to copy the framework to the final product by adding a custom copy Build Phase to the Frameworks directory.

The framework uses `@rpath` as its install name so the host application will need to specify the framework location, usually by adding `@loader_path/../Frameworks` to the Runpath Search Paths in the Build Settings.
