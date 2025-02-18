package petal.gfx;

import haxe.exceptions.NotImplementedException;
import petal.backends.Backend.InternalTexture;

enum TextureFilterMode {
    Nearest; Linear;
}

enum TextureWrapMode {
    Repeat; Clamp;
}

@:allow(petal.gfx.TextureSlice)
class Texture {
    public static var defaultWrapMode = TextureWrapMode.Clamp;
    public static var defaultFilterMode = TextureFilterMode.Linear;

    var internal:InternalTexture;

    public var width(default, null):Int;
    public var height(default, null):Int;

    public var wrapModeU:TextureWrapMode;
    public var wrapModeV:TextureWrapMode;
    public var filterModeU:TextureFilterMode;
    public var filterModeV:TextureFilterMode;

    public var wrapMode(never, set):TextureWrapMode;
    public var filterMode(never, set):TextureFilterMode;

    function set_wrapMode(mode:TextureWrapMode) {
        wrapModeU = mode;
        return wrapModeV = mode;
    }

    function set_filterMode(mode:TextureFilterMode) {
        filterModeU = mode;
        return filterModeV = mode;
    }

    function new(internal:InternalTexture, w:Int, h:Int) {
        this.internal = internal;
        width = w;
        height = h;
        wrapMode = defaultWrapMode;
        filterMode = defaultFilterMode;
    }

    public static function fromImage(image:Image) {
        var backend = @:privateAccess Graphics.instance.backend;
        var tex = backend.gfxTextureNew(image);
        return new Texture(tex, image.width, image.height);
    }

    public static function fromFile(filePath:String) {
        var img = Image.fromFile(filePath);
        var tex = fromImage(img);
        img.dispose();

        return tex;
    }

    public function dispose() {
        if (internal == null) return false;

        var backend = @:privateAccess Graphics.instance.backend;
        backend.gfxTextureDispose(internal);
        internal = null;

        return true;
    }

    function setup() {
        var backend = @:privateAccess Graphics.instance.backend;
        backend.gfxTextureSetWrap(internal, wrapModeU, wrapModeV);
        backend.gfxTextureSetFilter(internal, filterModeU, filterModeV);
    }

    public function draw() {
        var backend = @:privateAccess Graphics.instance.backend;
        setup();
        backend.gfxTextureDraw(internal);
    }

    public function drawSlice(x:Float, y:Float, w:Float, h:Float) {
        var backend = @:privateAccess Graphics.instance.backend;
        setup();
        backend.gfxTextureDrawQuad(internal, x, y, w, h, width, height);
    }
}