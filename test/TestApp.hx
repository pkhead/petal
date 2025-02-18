import petal.gfx.Mesh;
import petal.gfx.Graphics;

class TestApp extends petal.App {
    // var circRadius = 100.0;
    var mesh:Mesh;

    public function new() {
        untyped __lua__("if os.getenv(\"LOCAL_LUA_DEBUGGER_VSCODE\") == \"1\" then require(\"lldebugger\").start() end");
        super();

        var vertices:Array<Vertex> = [
            vertex(0.0, 0.0),
            vertex(0.0, 100.0),
            vertex(100.0, 0.0),

            vertex(100.0, 0.0),
            vertex(0.0, 100.0),
            vertex(100.0, 100.0)
        ];

        mesh = Mesh.createFromArray(vertices, BufferUsage.Dynamic);
    }

    inline static function vertex(x:Float, y:Float):Vertex {
        return {
            x: x, y: y,
            u:0.0, v:0.0,
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

        gfx.setColor(1.0, 1.0, 1.0);
        mesh.draw();
        
        // gfx.setColor(1.0, 0.0, 0.0);
        // gfx.fillCircle(mouseX, mouseY, circRadius);
    }

    static function main() {
        new TestApp();
    }
}