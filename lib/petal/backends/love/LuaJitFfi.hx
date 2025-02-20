package petal.backends.love;

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