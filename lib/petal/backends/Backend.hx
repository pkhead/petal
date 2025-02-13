package petal.backends;

enum GfxImPrimTopology {
    Triangles; Quads; Lines;
}

interface Backend {
    public function initApp(app:App):Void;
    public function gfxClear(r:Float, g:Float, b:Float, a:Float):Void;

    public function gfxImSetColor(r:Float, g:Float, b:Float, a:Float):Void;
    public function gfxImSetLineWidth(lw:Float):Void;
    public function gfxImRectFill(x:Float, y:Float, w:Float, h:Float):Void;
    public function gfxImRectLines(x:Float, y:Float, w:Float, h:Float):Void;
    public function gfxImBegin(mode:GfxImPrimTopology):Void;
    public function gfxImEnd():Void;
    public function gfxImVertex(x:Float, y:Float):Void;
}