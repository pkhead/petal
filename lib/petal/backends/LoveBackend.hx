package petal.backends;
import petal.backends.Backend.GfxImPrimTopology;
import love.keyboard.KeyConstant;
import love.keyboard.Scancode;
import love.Love;

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
            {love:KeyConstant.Kp0, petal:KeyCode.Kp0},
            {love:KeyConstant.Kp1, petal:KeyCode.Kp1},
            {love:KeyConstant.Kp2, petal:KeyCode.Kp2},
            {love:KeyConstant.Kp3, petal:KeyCode.Kp3},
            {love:KeyConstant.Kp4, petal:KeyCode.Kp4},
            {love:KeyConstant.Kp5, petal:KeyCode.Kp5},
            {love:KeyConstant.Kp6, petal:KeyCode.Kp6},
            {love:KeyConstant.Kp7, petal:KeyCode.Kp7},
            {love:KeyConstant.Kp8, petal:KeyCode.Kp8},
            {love:KeyConstant.Kp9, petal:KeyCode.Kp9},
            {love:KeyConstant.KpPeriod, petal:KeyCode.KpPeriod},
            {love:KeyConstant.KpDivision, petal:KeyCode.KpDivision},
            {love:KeyConstant.KpMultiply, petal:KeyCode.KpMultiply},
            {love:KeyConstant.KpMinus, petal:KeyCode.KpMinus},
            {love:KeyConstant.KpPlus, petal:KeyCode.KpPlus},
            {love:KeyConstant.KpEnter, petal:KeyCode.KpEnter},
            {love:KeyConstant.KpEquals, petal:KeyCode.KpEquals},
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
            {love:KeyConstant.ScrolLock, petal:KeyCode.ScrolLock},
            {love:KeyConstant.RShift, petal:KeyCode.RShift},
            {love:KeyConstant.LShift, petal:KeyCode.LShift},
            {love:KeyConstant.RCtrl, petal:KeyCode.RCtrl},
            {love:KeyConstant.LCtrl, petal:KeyCode.LCtrl},
            {love:KeyConstant.RAlt, petal:KeyCode.RAlt},
            {love:KeyConstant.LAlt, petal:KeyCode.LAlt},
            {love:KeyConstant.RMeta, petal:KeyCode.RMeta},
            {love:KeyConstant.LMeta, petal:KeyCode.LMeta},
            {love:KeyConstant.LSuper, petal:KeyCode.LSuper},
            {love:KeyConstant.RSuper, petal:KeyCode.RSuper},
            {love:KeyConstant.Mode, petal:KeyCode.Mode},
            {love:KeyConstant.Compose, petal:KeyCode.Compose},
            {love:KeyConstant.Pause, petal:KeyCode.Pause},
            {love:KeyConstant.Escape, petal:KeyCode.Escape},
            {love:KeyConstant.Help, petal:KeyCode.Help},
            {love:KeyConstant.Print, petal:KeyCode.Print},
            {love:KeyConstant.SysReq, petal:KeyCode.SysReq},
            {love:KeyConstant.Break, petal:KeyCode.Break},
            {love:KeyConstant.Menu, petal:KeyCode.Menu},
            {love:KeyConstant.Power, petal:KeyCode.Power},
            {love:KeyConstant.Euro, petal:KeyCode.Euro},
            {love:KeyConstant.Undo, petal:KeyCode.Undo},
            {love:KeyConstant.WWW, petal:KeyCode.WWW},
            {love:KeyConstant.Mail, petal:KeyCode.Mail},
            {love:KeyConstant.Calculator, petal:KeyCode.Calculator},
            {love:KeyConstant.AppSearch, petal:KeyCode.AppSearch},
            {love:KeyConstant.AppHome, petal:KeyCode.AppHome},
            {love:KeyConstant.AppBack, petal:KeyCode.AppBack},
            {love:KeyConstant.AppForward, petal:KeyCode.AppForward},
            {love:KeyConstant.AppRefresh, petal:KeyCode.AppRefresh},
            {love:KeyConstant.AppBookmarks, petal:KeyCode.AppBookmarks},
        ];

        for (v in arr) {
            keyMap[v.love] = v.petal;
        }
    }

    @:access(petal.App)
    public function initApp(app:App) {
        var canvas = love.Graphics.newCanvas();
        love.Graphics.setLineStyle(Rough);
        love.Graphics.setLineJoin(None);

        Love.load = (args:lua.Table<Dynamic, Dynamic>, unfilteredArgs:lua.Table<Dynamic, Dynamic>) -> {
            
        };

        Love.resize = (newW:Float, newH:Float) -> {
            canvas.release();
            canvas = love.Graphics.newCanvas();
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
            app.mouseX = love.Mouse.getX();
            app.mouseY = love.Mouse.getY();

            love.Graphics.origin();
            love.Graphics.setCanvas(canvas);
            app.update(dt);
            love.Graphics.setCanvas();

            app.keysPressed.resize(0);
            app.keysReleased.resize(0);
        }

        Love.draw = () -> {
            love.Graphics.draw(canvas, 0.0, 0.0);
        }
    }

    public function gfxClear(r:Float, g:Float, b:Float, a:Float) {
        love.Graphics.clear(r, g, b, a);
    }
    
    public function gfxImSetColor(r:Float, g:Float, b:Float, a:Float):Void {
        love.Graphics.setColor(r, g, b, a);
    }

    public function gfxImSetLineWidth(lw:Float):Void {
        love.Graphics.setLineWidth(lw);
    }

    public function gfxImRectFill(x:Float, y:Float, w:Float, h:Float):Void {
        love.Graphics.rectangle(Fill, x, y, w, h);
    }

    public function gfxImRectLines(x:Float, y:Float, w:Float, h:Float):Void {
        love.Graphics.rectangle(Line, x, y, w, h);
    }

    var vtxTable:lua.Table<Int, Float> = lua.Table.create();
    var vtxTableIndex = 0;
    var imPrimTopology:GfxImPrimTopology;

    public function gfxImBegin(mode:GfxImPrimTopology):Void {
        untyped __lua__("for k, v in pairs({0}) do {0}[k] = nil end", vtxTable);

        vtxTableIndex = 0;
        imPrimTopology = mode;
    }

    public function gfxImEnd():Void {
        if (imPrimTopology == GfxImPrimTopology.Lines) {
            love.Graphics.line(vtxTable);
        }
    }

    public function gfxImVertex(x:Float, y:Float):Void {
        vtxTable[vtxTableIndex + 1] = x;
        vtxTable[vtxTableIndex + 2] = y;
        vtxTableIndex += 2;

        switch (imPrimTopology) {
            case Triangles:
                if (vtxTableIndex >= 3*2) {
                    love.Graphics.polygon(Fill, vtxTable);
                    vtxTableIndex = 0;
                }

            case Quads:
                if (vtxTableIndex >= 4*2) {
                    love.Graphics.polygon(Fill, vtxTable);
                    vtxTableIndex = 0;
                }

            case Lines:
        }
    }
}