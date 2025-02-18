package petal.util;

import haxe.Exception;
import haxe.exceptions.ArgumentException;
import love.data.DataModule;
#if love
import petal.backends.LoveBackend.LuaJitFfi;
#end

class ByteData {
    public var length(get, never):Int;

    #if love
    static var temp_u8 = LuaJitFfi._new("uint8_t[8]");
    static var temp_i8 = LuaJitFfi._cast("int8_t*", temp_u8);
    static var temp_i16 = LuaJitFfi._cast("int16_t*", temp_u8);
    static var temp_u16 = LuaJitFfi._cast("uint16_t*", temp_u8);
    static var temp_i32 = LuaJitFfi._cast("int32_t*", temp_u8);
    static var temp_u32 = LuaJitFfi._cast("uint32_t*", temp_u8);
    // static var temp_i64 = LuaJitFfi._cast("int64_t*", temp_u8);
    // static var temp_u64 = LuaJitFfi._cast("uint64_t*", temp_u8);
    static var temp_float = LuaJitFfi._cast("float*", temp_u8);
    static var temp_double = LuaJitFfi._cast("double*", temp_u8);

    var data_u8:Dynamic;
    var _len:Int;
    
    inline function get_length() { return _len; }

    /**
     * The love.data.ByteData the instance is wrapping over, if it was created
     * with `fromLoveByteData` or `loveAlloc`. Otherwise, it is null.
     */
    public var loveData(default, null):Null<love.Data>;

    /**
     * Immediately dispose the underlying data. This is only useful for
     * if it was created with `loveAlloc`.
     */
    public function dispose() {
        if (data_u8 == null) return;

        if (loveData != null) {
            loveData.release();
            loveData = null;
        }

        data_u8 = null;
        _len = 0;
    }

    function new(loveData:Null<love.Data>, u8_ptr:Dynamic, size:Int) {
        this.loveData = loveData;
        this.data_u8 = u8_ptr;
        _len = size;
        //data_u8 = LuaJitFfi._cast("uint8_t*", loveData.getFFIPointer());
    }

    /**
     * Create a new ByteData using the data from a pre-existing love.data.ByteData.
     * @param loveData The preallocated LOVE ByteData.
     */
    public static function fromLoveData(loveData:love.Data) {
        var ptr = LuaJitFfi._cast("uint8_t*", loveData.getFFIPointer());
        return new ByteData(loveData, ptr, Std.int(loveData.getSize()));
    }

    /**
     * Create a new ByteData ƒrom a pointer.
     * @param ptr Pointer to the first data element.
     * @param size Size of the data, in bytes.
     */
    public static function fromPointer(ptr:Dynamic, size:Int) {
        return new ByteData(null, ptr, size);
    }

    /**
     * Allocate a new ByteData using love.data.newByteData.
     * The ByteData can then be used with LOVE's API.
     * 
     * The love.data.ByteData will be owned by this class. When `dispose` is called,
     * it will be released.
     * @param size The size of the ByteData in bytes.
     */
    public static function loveAlloc(size:Int) {
        var loveData = DataModule.newByteData(size);
        return new ByteData(loveData, LuaJitFfi._cast("uint8_t*", loveData.getFFIPointer()), size);
    }

    /**
     * Allocate a new ByteData.
     * @param size The size of the ByteData in bytes.
     */
    public static function alloc(size:Int) {
        return new ByteData(null, LuaJitFfi._new("uint8_t[?}", size), size);
    }
    #else
    var data:haxe.io.Bytes;
    #end

    #if love
    inline public function get(i:Int):Int {
        if (i < 0 || i >= _len) throw new ArgumentException("i", "out of bounds");
        return data_u8[i];
    }

    inline public function set(i:Int, v:Int) {
        if (i < 0 || i >= _len) throw new ArgumentException("i", "out of bounds");
        data_u8[i] = v & 0xFF;
    }

    inline public function getInt8(i:Int):Int {
        if (i < 0 || i >= _len) throw new ArgumentException("i", "out of bounds");
        LuaJitFfi.copy(temp_i8, data_u8 + i, 1);
        return temp_i8[0];
    }

    inline public function setInt8(i:Int, v:Int) {
        if (i < 0 || i >= _len) throw new ArgumentException("i", "out of bounds");
        temp_i8[0] = v & 0xFF;
        LuaJitFfi.copy(data_u8 + i, temp_i8, 1);
    }

    inline public function setInt16(i:Int, v:Int) {
        if (i < 0 || i >= _len - 1) throw new ArgumentException("i", "out of bounds");
        temp_i16[0] = v & 0xFFFF;
        LuaJitFfi.copy(data_u8 + i, temp_i16, 2);
    }

    inline public function getInt16(i:Int):Int {
        if (i < 0 || i >= _len - 1) throw new ArgumentException("i", "out of bounds");
        LuaJitFfi.copy(temp_i16, data_u8 + i, 2);
        return temp_i16[0];
    }

    inline public function setUInt16(i:Int, v:Int) {
        if (i < 0 || i >= _len - 1) throw new ArgumentException("i", "out of bounds");
        temp_u16[0] = v & 0xFFFF;
        LuaJitFfi.copy(data_u8 + i, temp_u16, 2);
    }

    inline public function getUInt16(i:Int):Int {
        if (i < 0 || i >= _len - 1) throw new ArgumentException("i", "out of bounds");
        LuaJitFfi.copy(temp_u16, data_u8 + i, 2);
        return temp_u16[0];
    }

    inline public function setInt32(i:Int, v:Int) {
        if (i < 0 || i >= _len - 3) throw new ArgumentException("i", "out of bounds");
        temp_i32[0] = v & 0xFFFFFFFF;
        LuaJitFfi.copy(data_u8 + i, temp_i32, 4);
    }

    inline public function getInt32(i:Int):Int {
        if (i < 0 || i >= _len - 3) throw new ArgumentException("i", "out of bounds");
        LuaJitFfi.copy(temp_i32, data_u8 + i, 4);
        return temp_i32[0];
    }

    inline public function setUInt32(i:Int, v:Int) {
        if (i < 0 || i >= _len - 3) throw new ArgumentException("i", "out of bounds");
        temp_u32[0] = v & 0xFFFFFFFF;
        LuaJitFfi.copy(data_u8 + i, temp_u32, 4);
    }

    inline public function getUInt32(i:Int):Int {
        if (i < 0 || i >= _len - 3) throw new ArgumentException("i", "out of bounds");
        LuaJitFfi.copy(temp_u32, data_u8 + i, 4);
        return temp_u32[0];
    }

    // inline public function setInt64(i:Int, v:Int) {
    //     if (i < 0 || i >= _len - 7) throw new ArgumentException("i", "out of bounds");
    //     temp_i64[0] = v;
    //     LuaJitFfi.copy(data_u8 + i, temp_i64, 8);
    // }

    // inline public function getInt64(i:Int):Int {
    //     if (i < 0 || i >= _len - 7) throw new ArgumentException("i", "out of bounds");
    //     LuaJitFfi.copy(temp_i64, data_u8 + i, 8);
    //     return temp_i64[0];
    // }

    // inline public function setUInt64(i:Int, v:Int) {
    //     if (i < 0 || i >= _len - 7) throw new ArgumentException("i", "out of bounds");
    //     temp_u64[0] = v;
    //     LuaJitFfi.copy(data_u8 + i, temp_u64, 8);
    // }

    // inline public function getUInt64(i:Int):Int {
    //     if (i < 0 || i >= _len - 7) throw new ArgumentException("i", "out of bounds");
    //     LuaJitFfi.copy(temp_u64, data_u8 + i, 8);
    //     return temp_u64[0];
    // }
    
    inline public function setFloat(i:Int, v:Float) {
        if (i < 0 || i >= _len - 3) throw new ArgumentException("i", "out of bounds");
        temp_float[0] = v;
        LuaJitFfi.copy(data_u8 + i, temp_float, 4);
    }

    inline public function getFloat(i:Int):Float {
        if (i < 0 || i >= _len - 3) throw new ArgumentException("i", "out of bounds");
        LuaJitFfi.copy(temp_float, data_u8 + i, 4);
        return temp_float[0];
    }

    inline public function setDouble(i:Int, v:Float) {
        if (i < 0 || i >= _len - 7) throw new ArgumentException("i", "out of bounds");
        temp_double[0] = v;
        LuaJitFfi.copy(data_u8 + i, temp_double, 8);
    }

    inline public function getDouble(i:Int):Float {
        if (i < 0 || i >= _len - 7) throw new ArgumentException("i", "out of bounds");
        LuaJitFfi.copy(temp_double, data_u8 + i, 8);
        return temp_double[0];
    }

    public function blit(pos:Int, src:ByteData, srcpos:Int, len:Int) {
        if (pos < 0 || pos + len > _len) throw new Exception("destination out of bounds");
        if (srcpos < 0 || srcpos + len > src._len) throw new Exception("source out of bounds");
        LuaJitFfi.copy(data_u8 + pos, src.data_u8 + srcpos, len);
    }
    #else
    inline public function get(i:Int) return data.get(i);
    inline public function set(i:Int, v:Int) data.set(i, v);

    inline public function getInt8(i:Int):Int; // TODO
    inline public function setInt8(i:Int, v:Int); // TODO
    inline public function setInt16(i:Int, v:Int); // TODO
    inline public function getInt16(i:Int):Int; // TODO

    inline public function setUInt16(i:Int, v:Int) data.setUInt16(i, v);
    inline public function getUInt16(i:Int) return data.getUInt16(i);
    inline public function setInt32(i:Int, v:Int) data.setInt32(i, v);
    inline public function getInt32(i:Int):Int return data.getInt32(i);

    inline public function setUInt32(i:Int, v:Int); // TODO
    inline public function getUInt32(i:Int):Int; // TODO
    // inline public function setInt64(i:Int, v:Int); // TODO
    // inline public function getInt64(i:Int):Int; // TODO
    // inline public function setUInt64(i:Int, v:Int); // TODO
    // inline public function getUInt64(i:Int):Int; // TODO
    
    inline public function setFloat(i:Int, v:Float) data.setFloat(i, v);
    inline public function getFloat(i:Int) return data.getFloat(i);
    inline public function setDouble(i:Int, v:Float) data.setDouble(i, v);
    inline public function getDouble(i:Int) return data.getDouble(i);

    inline public function blit(pos:Int, src:ByteData, srcpos:Int, len:Int) {
        return data.blit(pos, src.data, srcpos, len);
    }
    #end
}