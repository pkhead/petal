import petal.util.Timer;
import petal.gfx.TextureSlice;
import petal.gfx.Mesh;
import petal.gfx.Graphics;
import petal.gfx.Texture;

class TestApp extends petal.App {
    // var circRadius = 100.0;
    var mesh:Mesh;
    var tex:Texture;
    var sliceTex:TextureSlice;

    public function new() {
        untyped __lua__("if os.getenv(\"LOCAL_LUA_DEBUGGER_VSCODE\") == \"1\" then require(\"lldebugger\").start() end");
        super();

        Texture.defaultFilterMode = Nearest;

        // var vertices:Array<Vertex> = [
        //     vertex(0.0, 0.0),
        //     vertex(0.0, 100.0),
        //     vertex(100.0, 0.0),

        //     vertex(100.0, 0.0),
        //     vertex(0.0, 100.0),
        //     vertex(100.0, 100.0)
        // ];

        var vertices:Array<Vertex> = [
            vertex(0.0, 0.0, 0.0, 0.0),
            vertex(0.0, 50.0, 0.0, 1.0),
            vertex(50.0, 50.0, 1.0, 1.0),
            vertex(80.0, 0.0, 1.0, 0.0),
        ];

        var indices:Array<Int> = [0, 1, 2, 2, 3, 0];

        mesh = Mesh.createIndexedFromArray(
            vertices, indices,
            UInt16, Triangles, Dynamic
        );
        
        tex = Texture.fromFile("cracked-block.png");
        tex.wrapMode = Repeat;
        sliceTex = new TextureSlice(tex, 0.0, 0.0, tex.width / 2, tex.height / 2);

        mesh.texture = tex;
    }

    inline static function vertex(x:Float, y:Float, u:Float, v:Float):Vertex {
        return {
            x: x, y: y,
            u: u, v: v,
            color: 0xFFFFFFFF
        };
    }

    public override function update(dt:Float) {
        
        // if (isKeyDown(W)) {
        //     circRadius += 50.0 * dt;
        // }

        // if (isKeyDown(S)) {
        //     circRadius -= 50.0 * dt;
        // }

        // if (isKeyPressed(A)) {
        //     circRadius += 40.0;
        // }

        // if (isKeyReleased(A)) {
        //     circRadius -= 40.0;
        // }

        var gfx = Graphics.instance;
        gfx.clear(0.0, 0.0, 0.0);

        gfx.translate(windowWidth / 2, windowHeight / 2);
        gfx.rotate(Timer.stamp());

        for (x in 0...10) {
            for (y in 0...10) {
                gfx.push();
                gfx.translate(x * 50, y * 50);

                gfx.setColor(x / 10, y / 10, 1.0);
                mesh.draw();
                gfx.pop();
            }
        }

        gfx.origin();
        mesh.draw();

        // gfx.origin();
        // gfx.scale(4, 4);
        // sliceTex.x = mouseX;
        // sliceTex.y = mouseY;
        // sliceTex.width = tex.width;
        // sliceTex.height = tex.height;
        // sliceTex.draw();
        //tex.drawSlice(mouseX, mouseY, tex.width / 2, tex.height / 2);
        //tex.drawSlice(0.0, 0.0, tex.width / 2, tex.height / 2);

        
        // gfx.setColor(1.0, 0.0, 0.0);
        // gfx.fillCircle(mouseX, mouseY, circRadius);
    }

    static function main() {
        new TestApp();
    }
}