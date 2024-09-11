module path_utils;

import std.file : readText, mkdirRecurse;
import std.json;
import std.stdio : File;
import std.conv : to;
import std.process : environment;

import declarations;

JSONValue getJsonFile(string path) @safe {
    string content = readText(path);
    JSONValue json = parseJSON(content);

    return json;
}

void createIfDoesNotExist(const string path, void delegate(File) cb = null) {
    if (path.length == 0)
        return;

    string dirname = "";

    for (size_t i = path.length - 1; i >= 0; --i) {
        if (to!string(path[i]) == dirSeparator) {
            dirname = path[0..i];
            break;
        }
    }

    dirname = getAbsolutePath(dirname);

    if (dirname != "")
        mkdirRecurse(dirname);
    
    File file = File(path, "w");
    
    if (cb != null)
        cb(file);

    file.close();
}

string getAbsolutePath(const string path) @safe {
    string res = "";

    if (path[0] == HOME_DIR) {
        res = environment.get("HOME", "") ~ path[1..$];
    } else if (IS_UNIX && path[0] != UNIX_ROOT) {
        res = environment.get("PWD", "") ~ dirSeparator ~ path;
    }

    return absolutePath(res);
}