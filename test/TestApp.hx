import petal.KeyCode;
import petal.gfx.Graphics;

class TestApp extends petal.App {
    var circRadius = 100.0;

    public override function update(dt:Float) {
        if (isKeyDown(W)) {
            circRadius += 50.0 * dt;
        }

        if (isKeyDown(S)) {
            circRadius -= 50.0 * dt;
        }

        if (isKeyPressed(A)) {
            circRadius += 40.0;
        }

        if (isKeyReleased(A)) {
            circRadius -= 40.0;
        }

        var gfx = Graphics.instance;
        gfx.clear(0.0, 0.0, 0.0);

        gfx.setColor(1.0, 0.0, 0.0);
        gfx.fillCircle(mouseX, mouseY, circRadius);
    }

    static function main() {
        new TestApp();
    }
}