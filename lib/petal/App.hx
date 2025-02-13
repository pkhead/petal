package petal;

import petal.backends.Backend;
import petal.backends.LoveBackend;
import petal.gfx.Graphics;

class App {
    var backend:Backend;

    var keysPressed:Array<KeyCode> = [];
    var keysReleased:Array<KeyCode> = [];
    var keysDown:Array<KeyCode> = [];

    public var mouseX(default, null):Float;
    public var mouseY(default, null):Float;

    public function new() {
        #if love
        backend = new LoveBackend();
        #else
        #error "unspecified backend. possible options: love"
        #end

        backend.initApp(this);
        @:privateAccess new Graphics(backend);
    }

    function update(dt:Float) {}

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