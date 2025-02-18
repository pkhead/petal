package petal.gfx;

class TextureSlice {
    public var texture:Texture;
    public var x:Float;
    public var y:Float;
    public var width:Float;
    public var height:Float;

    public function new(tex:Texture, x:Float, y:Float, w:Float, h:Float) {
        this.texture = tex;
        this.x = x;
        this.y = y;
        this.width = w;
        this.height = h;
    }

    public function draw() {
        var backend = @:privateAccess Graphics.instance.backend;
        texture.setup();
        backend.gfxTextureDrawQuad(texture.internal, x, y, width, height, texture.width, texture.height);
    }
}