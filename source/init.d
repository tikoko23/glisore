module init;

import std.path;
import std.stdio : File;
import std.file : dirEntries, SpanMode, DirEntry;
import std.json;

import raylib;

import assets;
import dbg;
import camera;
import declarations;
import path_utils;
import vector;
import string_utils : prettify;

void _init() {
	Logger dbg = new Logger("INIT");

    initWindow(dbg);

	dbg.log("Initialising audio device...");
	InitAudioDevice();

	dbg.log("Loading assets...");
	
	immutable string assetDir = getAbsolutePath(MAIN_DIR ~ dirSeparator ~ ASSET_SUBDIR);

	dbg.log("Asset loading completed");

	foreach (DirEntry entry; dirEntries(assetDir, SpanMode.shallow)) {
		if (entry.isDir)
			loadAssets(relativePath(entry.name, assetDir));
	}

	dbg.log("Initialisation complete");
}

private void initWindow(Logger dbg) {
    immutable string windowConfigPath = getAbsolutePath(MAIN_DIR ~ dirSeparator ~ "window_config.json");
	dbg.logf("Loading config file at %s", windowConfigPath);

	JSONValue windowConfig;

	if (FileExists(cast(const char *) windowConfigPath)) {
		windowConfig = getJsonFile(windowConfigPath);
	} else {
		dbg.log("No config found, creating automatically...");
		windowConfig = parseJSON(`{"width": 800, "height": 600, "title": "` ~ prettify(GAME_NAME) ~ `", "fullscreen": false, "targetFPS": 144}`);
		
		createIfDoesNotExist(windowConfigPath, (File file) { file.write(windowConfig.toPrettyString()); });
	}

	const long windowHeight = windowConfig["height"].get!long();
	const long windowWidth = windowConfig["width"].get!long();

	if (windowHeight <= 0 || windowWidth <= 0 || windowHeight > int.max || windowWidth > int.max)
		throw new Exception("Window size is out of bounds");

	const string title = windowConfig["title"].get!string();

	dbg.log("Creating window...");
	InitWindow(0, 0, cast(const char *) title);
	SetExitKey(KeyboardKey.KEY_NULL);

	const bool isFullscreen = windowConfig["fullscreen"].get!bool();
	long targetFPS = windowConfig["targetFPS"].get!long();

	if (targetFPS <= 0 || targetFPS > int.max) {
		dbg.warnf("Target FPS of %l is out of bounds of int, defaulting to refresh rate", targetFPS);
		targetFPS = GetMonitorRefreshRate(GetCurrentMonitor());
	}

	if (IsWindowFullscreen() != isFullscreen) {
		BeginDrawing();
		EndDrawing();
		ToggleFullscreen();
	}
	
	SetTargetFPS(cast(int) targetFPS);

	
	if (isFullscreen)
		SCREEN_SIZE = Vec!(int, 2)(GetMonitorWidth(GetCurrentMonitor()), GetMonitorHeight(GetCurrentMonitor()));
	else
		SCREEN_SIZE = Vec!(int, 2)(cast(int) windowWidth, cast(int) windowHeight);
	
	dbg.logf("Detected screen size: %d x %d", SCREEN_SIZE.x, SCREEN_SIZE.y);
	SetWindowSize(SCREEN_SIZE.x, SCREEN_SIZE.y);

    CAMERA = new CCamera;
	CAMERA.offset = SCREEN_SIZE.cnv!dec().scale(-0.5);
}

void finish() {
	Logger dbg = new Logger("EXIT");

	dbg.log("Exiting with cleanup...");

	dbg.log("Closing audio device...");
	CloseAudioDevice();

	dbg.log("Closing window...");
	CloseWindow();

	dbg.log("Finished cleanup");
}