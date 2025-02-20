package petal.util;

class Timer {
    public static function stamp() {
        #if love
        return love.timer.TimerModule.getTime();
        #else
        return haxe.Timer.stamp();
        #end
    }

    public static function sleep(seconds:Float) {
        #if love
        love.timer.TimerModule.sleep(seconds);
        #else
        return Sys.sleep(seconds);
        #end
    }
}