package petal;

import haxe.Exception;
import petal.util.ByteData;

#if love
import love.image.ImageModule;
#end

enum PixelFormat {
    R8;
    Rg8;
    Rgba8;
}

class Image {
    /**
     * The width of the image in pixels.
     */
    public var width(default, null):Int;

    /**
     * The height of the image in pixels.
     */
    public var height(default, null):Int;

    /**
     * Raw image data.
     */
    public var imageData(default, null):ByteData;

    #if love
    public var loveImage(default, null):love.image.ImageData;

    function new(loveImage:love.image.ImageData) {
        this.loveImage = loveImage;
        imageData = ByteData.fromLoveData(loveImage);

        width = Std.int(loveImage.getWidth());
        height = Std.int(loveImage.getHeight());
    }

    static inline function toLoveFormat(imgFormat:PixelFormat) {
        return switch (imgFormat) {
            case R8: love.image.PixelFormat.R8;
            case Rg8: love.image.PixelFormat.Rg8;
            case Rgba8: love.image.PixelFormat.Rgba8;
        }
    }
    
    public static function fromFile(filePath:String) {
        return new Image(ImageModule.newImageData(filePath));
    }

    public static function create(width:Int, height:Int, format:PixelFormat = PixelFormat.Rgba8) {
        return new Image(ImageModule.newImageData(width, height, love.image.PixelFormat.Rgba8));
    }

    public function setPixel(x:Int, y:Int, r:Float, g:Float, b:Float, a:Float = 1.0) {
        if (x < 0 || y < 0 || x >= width || y >= height)
            throw new Exception("out of bounds");

        loveImage.setPixel(x, y, r, g, b, a);
    }

    public function getPixel(x:Int, y:Int):{r:Float, g:Float, b:Float, a:Float} {
        if (x < 0 || y < 0 || x >= width || y >= height)
            throw new Exception("out of bounds");

        var res = loveImage.getPixel(x, y);
        return {
            r: res.r,
            g: res.g,
            b: res.b,
            a: res.a
        };
    }

    inline public function dispose() {
        imageData.dispose();
        loveImage.release();
    }
    #else
    inline public function dispose() {}
    #end

}