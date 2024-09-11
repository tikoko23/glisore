module declarations;

public import std.path;

// BUILD SETTINGS
static immutable BuildPlatform CURRENT_TARGET = BuildPlatform.LINUX;
static immutable string GAME_NAME = "glisore";

// PATH SETTINGS
static immutable char HOME_DIR = '~';
static immutable char UNIX_ROOT = '/';

// ASSET SETTINGS
static immutable string ASSET_SUBDIR = "assets";

static if (CURRENT_TARGET == BuildPlatform.LINUX) {

    static immutable string MAIN_DIR = "~/.local/share/" ~ GAME_NAME;
    static immutable bool IS_UNIX = true;

} else static if (CURRENT_TARGET == BuildPlatform.WINDOWS) {

    static immutable string MAIN_DIR = "%LOCALAPPDATA%\\" ~ GAME_NAME;
    static immutable bool IS_UNIX = false;

} else static if (CURRENT_TARGET == BuildPlatform.MACOS) {

    static immutable string MAIN_DIR = "~/Library/Application Support/" ~ GAME_NAME;
    static immutable bool IS_UNIX = true;
    
}

alias dec = float;

enum BuildPlatform {
    LINUX,
    WINDOWS,
    MACOS
}

static immutable string SOUNDS_DIR = "sounds";
static immutable string MUSIC_DIR = "music";
static immutable string TEXTURES_DIR = "textures";
static immutable string IMAGES_DIR = "images";
static immutable string FONTS_DIR = "fonts";

static immutable int RAYLIB_LOG_LEVEL = 4;