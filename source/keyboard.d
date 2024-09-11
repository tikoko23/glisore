module keyboard;

import raylib;

import event;
import vector;
import declarations;

class Keyboard {
    private static Event!void[KeyboardKey] keyPressedEvents;
    private static Event!void[KeyboardKey] keyReleasedEvents;
    private static Event!void[KeyboardKey] whileKeyDownEvents;

    public static Event!KeyboardKey anyKeyPressed;

    public static Event!void getKeyPressedEvent(KeyboardKey key) {
        if (key in keyPressedEvents)
            return keyPressedEvents[key];
        
        keyPressedEvents[key] = new Event!void();
        return keyPressedEvents[key];
    }

    public static Event!void getKeyReleasedEvent(KeyboardKey key) {
        if (key in keyReleasedEvents)
            return keyReleasedEvents[key];
        
        keyReleasedEvents[key] = new Event!void();
        return keyReleasedEvents[key];
    }

    public static Event!void getWhileKeyDownEvent(KeyboardKey key) {
        if (key in whileKeyDownEvents)
            return whileKeyDownEvents[key];
        
        whileKeyDownEvents[key] = new Event!void();
        return whileKeyDownEvents[key];
    }

    private static void processPressed() {
        KeyboardKey pressed = cast(KeyboardKey) GetKeyPressed();
        if (pressed == KeyboardKey.KEY_NULL)
            return;
        
        anyKeyPressed.trigger(pressed);

        foreach (KeyboardKey key, Event!void event; keyPressedEvents) {
            if (IsKeyPressed(key))
                event.trigger();
        }
    }

    private static void processDown() {
        foreach (KeyboardKey key, Event!void event; whileKeyDownEvents) {
            if (IsKeyDown(key))
                event.trigger();
        }
    }

    private static void processReleased() {       
        foreach (KeyboardKey key, Event!void event; keyReleasedEvents) {
            if (IsKeyReleased(key))
                event.trigger();
        }
    }

    public static void update() {
        processPressed();
        processDown();
        processReleased();
    }

    public static Vec!(dec, 2) getVector(KeyboardKey up, KeyboardKey down, KeyboardKey left, KeyboardKey right) {
        return Vec!(dec, 2)(
            (IsKeyDown(left) ? -1 : 0) + (IsKeyDown(right) ? 1 : 0),
            (IsKeyDown(up) ? -1 : 0) + (IsKeyDown(down) ? 1 : 0)
        );
    }

    public static dec getAxis(KeyboardKey negative, KeyboardKey positive) {
        return (IsKeyDown(negative) ? -1 : 0) + (IsKeyDown(positive) ? 1 : 0);
    }

    static this() {
        this.anyKeyPressed = new Event!KeyboardKey();
    }

    this() {
        throw new Exception("Cannot create instance of Keyboard");
    }
}