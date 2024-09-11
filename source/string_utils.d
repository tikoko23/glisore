module string_utils;

import std.string : toLower, toUpper;

string prettify(const string str, CapsOptions options = CapsOptions.STRING_START) {
    switch (options) {
    case CapsOptions.STRING_START:
        return (cast(char) toUpper(str[0])) ~ str[1..$];

    case CapsOptions.WORDS_START:
        bool newWord = true;
        string newStr = "";

        foreach (const char ch; str) {
            if (ch == ' ') {
                newWord = true;
                newStr ~= ' ';
                continue;
            }

            if (newWord) {
                newStr ~= cast(char) toUpper(ch);
                newWord = false;
                continue;
            }

            newStr ~= ch;
        }

        return newStr;

    case CapsOptions.ALL:
        string newStr = "";

        foreach (const char ch; str) {
            newStr ~= cast(char) toUpper(ch);
        }

        return newStr;
    
    case CapsOptions.NONE:
        string newStr = "";

        foreach (const char ch; str) {
            newStr ~= cast(char) toLower(ch);
        }

        return newStr;
    default: break;
    }

    return "";
}

char[] nstr(string str) {
    char[] newStr;

    for (size_t i = 0; i < str.length; i++) {
        newStr ~= cast(char) str[i];
    }

    newStr ~= '\0';
    return newStr;
}

enum CapsOptions {
    STRING_START,
    WORDS_START,
    ALL,
    NONE,
}