package petal;

import petal.backends.love.NativeFs;
import haxe.Exception;
import petal.backends.Backend;
import petal.gfx.Graphics;

class App {
    public static var instance(default, null):App;

    var backend:Backend;

    var keysPressed:Array<KeyCode> = [];
    var keysReleased:Array<KeyCode> = [];
    var keysDown:Array<KeyCode> = [];

    public var mouseX(default, null):Float;
    public var mouseY(default, null):Float;
    public var windowWidth(get, never):Int;
    public var windowHeight(get, never):Int;

    public function new() {
        if (instance != null) throw new Exception("Can only have one running Application active at a time.");
        instance = this;

        #if love
        backend = new petal.backends.love.LoveBackend();
        #else
        #error "unspecified backend. possible options: love"
        #end

        backend.initApp(this);
        @:privateAccess new Graphics(backend);
    }

    function update(dt:Float) {}

    inline function get_windowWidth() return backend.getWindowWidth();
    inline function get_windowHeight() return backend.getWindowHeight(); 

    function keyPressed(keycode:KeyCode, isRepeat:Bool) {}
    function keyReleased(keycode:KeyCode) {}

    inline public function isKeyPressed(keycode:KeyCode) {
        return keysPressed.contains(keycode);
    }

    inline public function isKeyReleased(keycode:KeyCode) {
        return keysReleased.contains(keycode);
    }

    inline public function isKeyDown(keycode:KeyCode) {
        return keysDown.contains(keycode);
    }
}