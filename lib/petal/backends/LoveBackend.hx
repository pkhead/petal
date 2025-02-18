package petal.backends;
import petal.util.ByteData;
import petal.gfx.Mesh;
import petal.backends.Backend;
import love.keyboard.KeyConstant;
import love.keyboard.Scancode;

import love.Love;
import love.graphics.GraphicsModule;
import love.mouse.MouseModule;

@:luaRequire("ffi")
extern class LuaJitFfi {
    @:native("new")
    public static function _new(ctype:String, args:haxe.extern.Rest<Dynamic>):Dynamic;

    @:native("cast")
    public static function _cast(ct:String, init:Dynamic):Dynamic;

    public static function abi(param:String):Bool;

    @:overload(function(dst:Dynamic, str:Dynamic):Void {})
    public static function copy(dst:Dynamic, src:Dynamic, len:Int):Void;
}

typedef MeshImpl = {
    mesh:love.graphics.Mesh,
    indexType:IndexDataType
};

class LoveBackend implements Backend {
    var keyMap:Map<KeyConstant, KeyCode> = [];

    public function new() {
        // first, list key mappings as an array of pairs
        // then, assign to keyMap map.
        // This is kind of really stupid but if i assign it directly
        // generated lua code will use more than 200 local variables
        // since it creates a new variable (of the same name) for each pairing,
        // thus causing an error.
        // What the hell.
        var arr:Array<{love:KeyConstant, petal:KeyCode}> = [
            {love:KeyConstant.A, petal:KeyCode.A},
            {love:KeyConstant.B, petal:KeyCode.B},
            {love:KeyConstant.C, petal:KeyCode.C},
            {love:KeyConstant.D, petal:KeyCode.D},
            {love:KeyConstant.E, petal:KeyCode.E},
            {love:KeyConstant.F, petal:KeyCode.F},
            {love:KeyConstant.G, petal:KeyCode.G},
            {love:KeyConstant.H, petal:KeyCode.H},
            {love:KeyConstant.I, petal:KeyCode.I},
            {love:KeyConstant.J, petal:KeyCode.J},
            {love:KeyConstant.K, petal:KeyCode.K},
            {love:KeyConstant.L, petal:KeyCode.L},
            {love:KeyConstant.M, petal:KeyCode.M},
            {love:KeyConstant.N, petal:KeyCode.N},
            {love:KeyConstant.O, petal:KeyCode.O},
            {love:KeyConstant.P, petal:KeyCode.P},
            {love:KeyConstant.Q, petal:KeyCode.Q},
            {love:KeyConstant.R, petal:KeyCode.R},
            {love:KeyConstant.S, petal:KeyCode.S},
            {love:KeyConstant.T, petal:KeyCode.T},
            {love:KeyConstant.U, petal:KeyCode.U},
            {love:KeyConstant.V, petal:KeyCode.V},
            {love:KeyConstant.W, petal:KeyCode.W},
            {love:KeyConstant.X, petal:KeyCode.X},
            {love:KeyConstant.Y, petal:KeyCode.Y},
            {love:KeyConstant.Z, petal:KeyCode.Z},
            {love:KeyConstant.Zero, petal:KeyCode.Zero},
            {love:KeyConstant.One, petal:KeyCode.One},
            {love:KeyConstant.Two, petal:KeyCode.Two},
            {love:KeyConstant.Three, petal:KeyCode.Three},
            {love:KeyConstant.Four, petal:KeyCode.Four},
            {love:KeyConstant.Five, petal:KeyCode.Five},
            {love:KeyConstant.Six, petal:KeyCode.Six},
            {love:KeyConstant.Seven, petal:KeyCode.Seven},
            {love:KeyConstant.Eight, petal:KeyCode.Eight},
            {love:KeyConstant.Nine, petal:KeyCode.Nine},
            {love:KeyConstant.Space, petal:KeyCode.Space},
            {love:KeyConstant.ExclamationMark, petal:KeyCode.ExclamationMark},
            {love:KeyConstant.DoubleQuote, petal:KeyCode.DoubleQuote},
            {love:KeyConstant.Hash, petal:KeyCode.Hash},
            {love:KeyConstant.Dollar, petal:KeyCode.Dollar},
            {love:KeyConstant.Ampersand, petal:KeyCode.Ampersand},
            {love:KeyConstant.SingleQuote, petal:KeyCode.SingleQuote},
            {love:KeyConstant.LeftParenthesis, petal:KeyCode.LeftParenthesis},
            {love:KeyConstant.RightParenthesis, petal:KeyCode.RightParenthesis},
            {love:KeyConstant.Asterik, petal:KeyCode.Asterik},
            {love:KeyConstant.Plus, petal:KeyCode.Plus},
            {love:KeyConstant.Comma, petal:KeyCode.Comma},
            {love:KeyConstant.Minus, petal:KeyCode.Minus},
            {love:KeyConstant.Period, petal:KeyCode.Period},
            {love:KeyConstant.Slash, petal:KeyCode.Slash},
            {love:KeyConstant.Colon, petal:KeyCode.Colon},
            {love:KeyConstant.Semicolon, petal:KeyCode.Semicolon},
            {love:KeyConstant.LessThan, petal:KeyCode.LessThan},
            {love:KeyConstant.Equals, petal:KeyCode.Equals},
            {love:KeyConstant.RightThan, petal:KeyCode.RightThan},
            {love:KeyConstant.QuestionMark, petal:KeyCode.QuestionMark},
            {love:KeyConstant.At, petal:KeyCode.At},
            {love:KeyConstant.LeftBracket, petal:KeyCode.LeftBracket},
            {love:KeyConstant.Backslash, petal:KeyCode.Backslash},
            {love:KeyConstant.RightBracket, petal:KeyCode.RightBracket},
            {love:KeyConstant.Caret, petal:KeyCode.Caret},
            {love:KeyConstant.Underscore, petal:KeyCode.Underscore},
            {love:KeyConstant.GraveAccent, petal:KeyCode.GraveAccent},
            {love:KeyConstant.Kp0, petal:KeyCode.Keypad0},
            {love:KeyConstant.Kp1, petal:KeyCode.Keypad1},
            {love:KeyConstant.Kp2, petal:KeyCode.Keypad2},
            {love:KeyConstant.Kp3, petal:KeyCode.Keypad3},
            {love:KeyConstant.Kp4, petal:KeyCode.Keypad4},
            {love:KeyConstant.Kp5, petal:KeyCode.Keypad5},
            {love:KeyConstant.Kp6, petal:KeyCode.Keypad6},
            {love:KeyConstant.Kp7, petal:KeyCode.Keypad7},
            {love:KeyConstant.Kp8, petal:KeyCode.Keypad8},
            {love:KeyConstant.Kp9, petal:KeyCode.Keypad9},
            {love:KeyConstant.KpPeriod, petal:KeyCode.KeypadPeriod},
            {love:KeyConstant.KpDivision, petal:KeyCode.KeypadDivision},
            {love:KeyConstant.KpMultiply, petal:KeyCode.KeypadMultiply},
            {love:KeyConstant.KpMinus, petal:KeyCode.KeypadMinus},
            {love:KeyConstant.KpPlus, petal:KeyCode.KeypadPlus},
            {love:KeyConstant.KpEnter, petal:KeyCode.KeypadEnter},
            {love:KeyConstant.KpEquals, petal:KeyCode.KeypadEquals},
            {love:KeyConstant.Up, petal:KeyCode.Up},
            {love:KeyConstant.Down, petal:KeyCode.Down},
            {love:KeyConstant.Right, petal:KeyCode.Right},
            {love:KeyConstant.Left, petal:KeyCode.Left},
            {love:KeyConstant.Home, petal:KeyCode.Home},
            {love:KeyConstant.End, petal:KeyCode.End},
            {love:KeyConstant.PageUp, petal:KeyCode.PageUp},
            {love:KeyConstant.PageDown, petal:KeyCode.PageDown},
            {love:KeyConstant.Insert, petal:KeyCode.Insert},
            {love:KeyConstant.Backspace, petal:KeyCode.Backspace},
            {love:KeyConstant.Tab, petal:KeyCode.Tab},
            {love:KeyConstant.Clear, petal:KeyCode.Clear},
            {love:KeyConstant.Return, petal:KeyCode.Return},
            {love:KeyConstant.Delete, petal:KeyCode.Delete},
            {love:KeyConstant.F1, petal:KeyCode.F1},
            {love:KeyConstant.F2, petal:KeyCode.F2},
            {love:KeyConstant.F3, petal:KeyCode.F3},
            {love:KeyConstant.F4, petal:KeyCode.F4},
            {love:KeyConstant.F5, petal:KeyCode.F5},
            {love:KeyConstant.F6, petal:KeyCode.F6},
            {love:KeyConstant.F7, petal:KeyCode.F7},
            {love:KeyConstant.F8, petal:KeyCode.F8},
            {love:KeyConstant.F9, petal:KeyCode.F9},
            {love:KeyConstant.F10, petal:KeyCode.F10},
            {love:KeyConstant.F11, petal:KeyCode.F11},
            {love:KeyConstant.F12, petal:KeyCode.F12},
            {love:KeyConstant.F13, petal:KeyCode.F13},
            {love:KeyConstant.F14, petal:KeyCode.F14},
            {love:KeyConstant.F15, petal:KeyCode.F15},
            {love:KeyConstant.NumLock, petal:KeyCode.NumLock},
            {love:KeyConstant.CapsLock, petal:KeyCode.CapsLock},
            {love:KeyConstant.ScrollLock, petal:KeyCode.ScrollLock},
            {love:KeyConstant.RShift, petal:KeyCode.RShift},
            {love:KeyConstant.LShift, petal:KeyCode.LShift},
            {love:KeyConstant.RCtrl, petal:KeyCode.RCtrl},
            {love:KeyConstant.LCtrl, petal:KeyCode.LCtrl},
            {love:KeyConstant.RAlt, petal:KeyCode.RAlt},
            {love:KeyConstant.LAlt, petal:KeyCode.LAlt},
            {love:KeyConstant.LGui, petal:KeyCode.LSuper},
            {love:KeyConstant.RGui, petal:KeyCode.RSuper},
            {love:KeyConstant.Mode, petal:KeyCode.Mode},
            {love:KeyConstant.Pause, petal:KeyCode.Pause},
            {love:KeyConstant.Escape, petal:KeyCode.Escape},
            {love:KeyConstant.Help, petal:KeyCode.Help},
            {love:KeyConstant.PrintScreen, petal:KeyCode.PrintScreen},
            {love:KeyConstant.SysReq, petal:KeyCode.SysReq},
            {love:KeyConstant.Menu, petal:KeyCode.Menu},
            {love:KeyConstant.Power, petal:KeyCode.Power},
        ];

        for (v in arr) {
            keyMap[v.love] = v.petal;
        }
    }

    @:access(petal.App)
    public function initApp(app:App) {
        var canvas = GraphicsModule.newCanvas();
        GraphicsModule.setLineStyle(Rough);
        GraphicsModule.setLineJoin(None);

        Love.load = (args:lua.Table<Dynamic, Dynamic>, unfilteredArgs:lua.Table<Dynamic, Dynamic>) -> {
            
        };

        Love.resize = (newW:Float, newH:Float) -> {
            canvas.release();
            canvas = GraphicsModule.newCanvas();
        };

        Love.keypressed = (keycode:KeyConstant, scancode:Scancode, isRepeat:Bool) -> {
            var kc = keyMap[keycode];
            app.keyPressed(kc, isRepeat);

            if (!isRepeat) {
                app.keysPressed.push(kc);
                app.keysDown.push(kc);
            }
        };

        Love.keyreleased = (keycode:KeyConstant, scancode:Scancode) -> {
            var kc = keyMap[keycode];
            app.keyReleased(kc);
            app.keysReleased.push(kc);
            app.keysDown.remove(kc);
        };

        Love.update = (dt:Float) -> {
            app.mouseX = MouseModule.getX();
            app.mouseY = MouseModule.getY();

            GraphicsModule.origin();
            GraphicsModule.setCanvas(canvas);
            app.update(dt);
            GraphicsModule.setCanvas();

            app.keysPressed.resize(0);
            app.keysReleased.resize(0);
        }

        Love.draw = () -> {
            GraphicsModule.draw(canvas, 0.0, 0.0);
        }
    }

    public function gfxClear(r:Float, g:Float, b:Float, a:Float) {
        GraphicsModule.clear(r, g, b, a);
    }
    
    public function gfxImSetColor(r:Float, g:Float, b:Float, a:Float):Void {
        GraphicsModule.setColor(r, g, b, a);
    }

    public function gfxImSetLineWidth(lw:Float):Void {
        GraphicsModule.setLineWidth(lw);
    }

    public function gfxImRectFill(x:Float, y:Float, w:Float, h:Float):Void {
        GraphicsModule.rectangle(Fill, x, y, w, h);
    }

    public function gfxImRectLines(x:Float, y:Float, w:Float, h:Float):Void {
        GraphicsModule.rectangle(Line, x, y, w, h);
    }

    public function gfxImLine(x0:Float, y0:Float, x1:Float, y1:Float):Void {
        GraphicsModule.line(x0, y0, x1, y1);
    }

    var vtxTable:lua.Table<Int, Float> = lua.Table.create();
    var vtxTableIndex = 0;
    var imPrimTopology:PrimitiveTopology;

    public function gfxImBegin(mode:PrimitiveTopology):Void {
        untyped __lua__("for k, v in pairs({0}) do {0}[k] = nil end", vtxTable);

        vtxTableIndex = 0;
        imPrimTopology = mode;
    }

    public function gfxImEnd():Void {
        if (imPrimTopology == PrimitiveTopology.Lines) {
            GraphicsModule.line(vtxTable);
        }
    }

    public function gfxImVertex(x:Float, y:Float):Void {
        vtxTable[vtxTableIndex + 1] = x;
        vtxTable[vtxTableIndex + 2] = y;
        vtxTableIndex += 2;

        switch (imPrimTopology) {
            case Triangles:
                if (vtxTableIndex >= 3*2) {
                    GraphicsModule.polygon(Fill, vtxTable);
                    vtxTableIndex = 0;
                }

            case Quads:
                if (vtxTableIndex >= 4*2) {
                    GraphicsModule.polygon(Fill, vtxTable);
                    vtxTableIndex = 0;
                }

            case Lines:
        }
    }

    public function gfxFramebufferNew(width:Int, height:Int, readable:Bool):InternalFramebuffer {
        var settings = lua.Table.create();
        settings.readable = readable;
        return GraphicsModule.newCanvas(width, height, settings);
    }
    
    public function gfxFramebufferDispose(fb:InternalFramebuffer):Void {
        cast(fb, love.graphics.Canvas).release();
    }

    public function gfxSetFramebuffer(fb:InternalFramebuffer):Void {
        GraphicsModule.setCanvas(fb);
    }

    public function gfxMeshNew(format:Array<VertexAttributeDescription>, vertexCount:Int, indexed:Bool, indexType:IndexDataType, mode:DrawMode, usage:BufferUsage):MeshImpl {
        var tf:lua.Table<Int, lua.Table<Int, Dynamic>> = lua.Table.create();
        var i = 1;
        var vtxSize = 0;

        for (f in format) {
            var item:lua.Table<Int, Dynamic> = lua.Table.create();
            item[1] = switch (f.name) {
                case AttributeName.Position: "VertexPosition";
                case AttributeName.Normal: "VertexNormal";
                case AttributeName.Tangent: "VertexTangent";
                case AttributeName.Bitangent: "VertexBitangent";
                case AttributeName.Color0: "VertexColor";
                case AttributeName.Color1: "VertexColor1";
                case AttributeName.Color2: "VertexColor2";
                case AttributeName.Color3: "VertexColor3";
                case AttributeName.Indices: "VertexIndices";
                case AttributeName.Weight: "VertexWeight";
                case AttributeName.TexCoord0: "VertexTexCoord";
                case AttributeName.TexCoord1: "VertexTexCoord1";
                case AttributeName.TexCoord2: "VertexTexCoord2";
                case AttributeName.TexCoord3: "VertexTexCoord3";
                case AttributeName.TexCoord4: "VertexTexCoord4";
                case AttributeName.TexCoord5: "VertexTexCoord5";
                case AttributeName.TexCoord6: "VertexTexCoord6";
                case AttributeName.TexCoord7: "VertexTexCoord7";
            };

            item[2] = switch (f.type) {
                case Float: 
                    vtxSize += f.size * 4;
                    "float";
                case Byte: 
                    vtxSize = f.size;
                    "byte";
            };

            item[3] = f.size;

            tf[i++] = item;
        }

        var loveDrawMode:love.graphics.MeshDrawMode = switch (mode) {
            case Triangles: Triangles;
            case Strip: Strip;
            case Fan: Fan;
        };

        var loveBufferUsage:love.graphics.SpriteBatchUsage = switch (usage) {
            case Static: Static;
            case Dynamic: Dynamic;
            case Stream: Stream;
        };

        return {
            mesh: GraphicsModule.newMesh(tf, vertexCount, loveDrawMode, loveBufferUsage),
            indexType:indexType
        };
    }

    public function gfxMeshDispose(mesh:InternalMesh):Void {
        (mesh : MeshImpl).mesh.release();
    }
    
    public function gfxMeshUploadVertices(mesh:InternalMesh, data:ByteData, startVertex:Int, vertexCount:Int):Void {
        var meshImpl = (mesh : MeshImpl);
        
        // for some reason there's no overload for setVertices(ByteData, int, int|"all")?
        // meshImpl.mesh.setVertices(data.loveData, startVertex, vertexCount);
        untyped __lua__("{0}:setVertices({1}, {2}, {3})", meshImpl.mesh, data.loveData, startVertex + 1, vertexCount);
    }

    public function gfxMeshUploadIndices(mesh:InternalMesh, data:ByteData):Void {
        var meshImpl = (mesh : MeshImpl);

        var type = switch (meshImpl.indexType) {
            case UInt16: love.graphics.IndexDataType.Uint16;
            case UInt32: love.graphics.IndexDataType.Uint32;
        };
        meshImpl.mesh.setVertexMap(data.loveData, type);
    }

    public function gfxMeshDraw(mesh:InternalMesh):Void {
        var meshImpl = (mesh : MeshImpl);
        GraphicsModule.draw(meshImpl.mesh, 0, 0);
    }
}