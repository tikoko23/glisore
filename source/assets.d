module assets;

import std.file;
import std.path;
import std.exception;
import std.string : indexOf;

import raylib;

import declarations;
import path_utils;
import string_utils;
import dbg;

AssetRegistry!Sound SOUNDS;
AssetRegistry!Music MUSIC;
AssetRegistry!Texture TEXTURES;
AssetRegistry!Image IMAGES;
AssetRegistry!Font FONTS;

class AssetRegistry(T) {
    T[string] assets;

    string defaultNamespace;

    this(string defaultNamespace = prettify(GAME_NAME, CapsOptions.NONE)) {
        this.defaultNamespace = defaultNamespace;
    }

    ref T opIndex(string index) {
        if (parseId(index, defaultNamespace) in this.assets)
            return this.assets[parseId(index, defaultNamespace)];
        
        if (index in this.assets)
            return this.assets[index];

        throw new Exception("Index not found: " ~ index);
    }

    T opIndexAssign(T)(T value, string index) {
        size_t res = index.indexOf(':');

        if (res == index.length)
            this.assets[parseId(index, defaultNamespace)] = value;
        else {
            this.assets[index] = value;
        }

        return value;
    }
}

private void initialiseDefault() {
    SOUNDS = new AssetRegistry!Sound();
    MUSIC = new AssetRegistry!Music();
    TEXTURES = new AssetRegistry!Texture();
    IMAGES = new AssetRegistry!Image();
    FONTS = new AssetRegistry!Font();
}

enum AssetType {
    SOUND,
    MUSIC,
    TEXTURE,
    IMAGE,
    FONT
}

void loadAssets(const string namespace) {
    Logger dbg = new Logger("ASSET_LOADER");

    dbg.log("Initialising default registeries");
    initialiseDefault();

    immutable string assetDir = getAbsolutePath(MAIN_DIR ~ dirSeparator ~ ASSET_SUBDIR ~ dirSeparator ~ namespace);
    dbg.logf("Loading assets from: %s", assetDir);

    immutable string soundsDir = assetDir ~ dirSeparator ~ SOUNDS_DIR;
    immutable string musicDir = assetDir ~ dirSeparator ~ MUSIC_DIR;
    immutable string texturesDir = assetDir ~ dirSeparator ~ TEXTURES_DIR;
    immutable string imagesDir = assetDir ~ dirSeparator ~ IMAGES_DIR;
    immutable string fontsDir = assetDir ~ dirSeparator ~ FONTS_DIR;

    mkdirRecurse(soundsDir);
    mkdirRecurse(musicDir);
    mkdirRecurse(texturesDir);
    mkdirRecurse(imagesDir);
    mkdirRecurse(fontsDir);
    dbg.log("Verified directories");

    AssetLoader loader = new AssetLoader(prettify(GAME_NAME, CapsOptions.NONE), assetDir);
    loader.logger = dbg;
    dbg.log("Asset loader ready");

    foreach (DirEntry entry; dirEntries(soundsDir, SpanMode.depth)) {
        if (entry.isDir) continue;
        string name = relativePath(entry.name, soundsDir);
        loader.load(name, AssetType.SOUND);
    }

    foreach (DirEntry entry; dirEntries(musicDir, SpanMode.depth)) {
        if (entry.isDir) continue;
        string name = relativePath(entry.name, musicDir);
        loader.load(name, AssetType.MUSIC);
    }

    foreach (DirEntry entry; dirEntries(texturesDir, SpanMode.depth)) {
        if (entry.isDir) continue;
        string name = relativePath(entry.name, texturesDir);
        loader.load(name, AssetType.TEXTURE);
    }

    foreach (DirEntry entry; dirEntries(imagesDir, SpanMode.depth)) {
        if (entry.isDir) continue;
        string name = relativePath(entry.name, imagesDir);
        loader.load(name, AssetType.IMAGE);
    }

    foreach (DirEntry entry; dirEntries(fontsDir, SpanMode.depth)) {
        if (entry.isDir) continue;
        string name = relativePath(entry.name, fontsDir);
        loader.load(name, AssetType.FONT);
    }

    dbg.log("Validating assets...");

    foreach (string name, Texture texture; TEXTURES.assets) {
        string actualName = name[namespace.length + 1..$];

        if (actualName[0..5] == "tile/") {
            assert(texture.width == texture.height, "Tile textures must be square");
        }
    }
}

struct NamespaceID {
    string namespace;
    string id;

    this(string namespace, string id) {
        this.namespace = namespace;
        this.id = id;
    }
}

string parseId(string name, string namespace = prettify(GAME_NAME, CapsOptions.NONE)) {
    return namespace ~ ':' ~ name;
}

NamespaceID splitId(string fullId) {
    auto index = fullId.indexOf(':');
    return NamespaceID(fullId[0..index], fullId[index + 1..$]);
}

class AssetLoader {
    string namespace;
    string basePath;
    bool noExtension = true;

    Logger logger = null;

    this(string namespace, string basePath) {
        this.namespace = namespace;
        this.basePath = basePath;
    }

    void load(string name, AssetType type) {

        string subFolder = "";

        switch (type) {
        case AssetType.SOUND:
            subFolder = SOUNDS_DIR;
            break;
        case AssetType.MUSIC:
            subFolder = MUSIC_DIR;
            break;
        case AssetType.TEXTURE:
            subFolder = TEXTURES_DIR;
            break;
        case AssetType.IMAGE:
            subFolder = IMAGES_DIR;
            break;
        case AssetType.FONT:
            subFolder = FONTS_DIR;
            break;
        default: break;
        }

        immutable string pathStr = basePath ~ dirSeparator ~ subFolder ~ dirSeparator ~ name;

        const char * path = cast(const char*) pathStr;
        immutable string id = namespace ~ ':' ~ (this.noExtension ? stripExtension(name) : name);

        if (this.logger !is null)
            logger.logf("Loading '%s' from '%s'", id, subFolder ~ dirSeparator ~ name);

        switch (type) {
        case AssetType.SOUND:
            SOUNDS[id] = LoadSound(path);
            return;
        case AssetType.MUSIC:
            MUSIC[id] = LoadMusicStream(path);
            return;
        case AssetType.TEXTURE:
            TEXTURES[id] = LoadTexture(path);
            return;
        case AssetType.IMAGE:
            IMAGES[id] = LoadImage(path);
            return;
        case AssetType.FONT:
            FONTS[id] = LoadFont(path);
            return;
        default: break;
        }
    }
}