package petal.gfx;

import petal.backends.Backend;

class Graphics {
    public static var instance(default, null):Graphics;
    var backend:Backend;

    @:allow(petal.App)
    function new(backend:Backend) {
        instance = this;
        this.backend = backend;
    }

    /**
     * Clear the background of the active framebuffer with a given color.
     * @param r The red value of the color, from 0 to 1.
     * @param g The green value of the color, from 0 to 1.
     * @param b The value value of the color, from 0 to 1.
     * @param a The alpha value of the color, from 0 to 1.
     */
    inline public function clear(r:Float, g:Float, b:Float, a:Float = 1.0) {
        backend.gfxClear(r, g, b, a);
    }

    inline public function setColor(r:Float, g:Float, b:Float, a:Float = 1.0) {
        backend.gfxImSetColor(r, g, b, a);
    }

    inline public function drawRect(x:Float, y:Float, w:Float, h:Float) {
        backend.gfxImRectFill(x, y, w, h);
    }

    inline public function drawRectLines(x:Float, y:Float, w:Float, h:Float) {
        backend.gfxImRectLines(x, y, w, h);
    }

    inline public function drawLine(x0:Float, y0:Float, x1:Float, y1:Float) {
        backend.gfxImLine(x0, y0, x1, y1);
    }

    public function fillCircle(x:Float, y:Float, r:Float, segments:Int = 24) {
        backend.gfxImBegin(PrimitiveTopology.Triangles);

        var lastC = 1.0;
        var lastS = 0.0;

        for (i in 1...segments+1) {
            var angle = (i / segments) * 2 * Math.PI;
            var c = Math.cos(angle);
            var s = Math.sin(angle);

            backend.gfxImVertex(x, y);
            backend.gfxImVertex(lastC * r + x, lastS * r + y);
            backend.gfxImVertex(c * r + x, s * r + y);

            lastC = c;
            lastS = s;
        }

        backend.gfxImEnd();
    }

    inline public function origin() {
        backend.gfxImMatrixIdentity();
    }

    inline public function push() {
        backend.gfxImPushMatrix();
    }

    inline public function pop() {
        backend.gfxImPopMatrix();
    }

    inline public function translate(x:Float, y:Float) {
        backend.gfxImTranslate(x, y);
    }

    inline public function scale(x:Float, y:Float) {
        backend.gfxImScale(x, y);
    }

    inline public function rotate(ang:Float) {
        backend.gfxImRotate(ang);
    }
}