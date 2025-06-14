package petal.backends;

import petal.util.ByteData;
import petal.gfx.Mesh;
import petal.gfx.Texture;

enum PrimitiveTopology {
    Triangles; Quads; Lines;
}

typedef InternalMesh = Any;
typedef InternalFramebuffer = Any;
typedef InternalTexture = Any;

interface Backend {
    public function initApp(app:App):Void;

    public function getWindowWidth():Int;
    public function getWindowHeight():Int;

    public function gfxClear(r:Float, g:Float, b:Float, a:Float):Void;

    public function gfxTextureNew(image:Image):InternalTexture;
    public function gfxTextureDispose(tex:InternalTexture):Void;
    public function gfxTextureSetFilter(tex:InternalTexture, u:TextureFilterMode, v:TextureFilterMode):Void;
    public function gfxTextureSetWrap(tex:InternalTexture, u:TextureWrapMode, v:TextureWrapMode):Void;
    public function gfxTextureDraw(tex:InternalTexture):Void;
    public function gfxTextureDrawQuad(tex:InternalTexture, x:Float, y:Float, w:Float, h:Float, refW:Float, refH:Float):Void;

    public function gfxMeshNew(format:Array<VertexAttributeDescription>, vertexCount:Int, indexed:Bool, indexDataType:IndexDataType, mode:MeshDrawMode, usage:BufferUsage):InternalMesh;
    public function gfxMeshDispose(mesh:InternalMesh):Void;
    public function gfxMeshUploadVertices(mesh:InternalMesh, data:ByteData, startVertex:Int, vertexCount:Int):Void;
    public function gfxMeshUploadIndices(mesh:InternalMesh, data:ByteData):Void;
    public function gfxMeshDraw(mesh:InternalMesh, start:Int, count:Int):Void;

    public function gfxFramebufferNew(width:Int, height:Int, readable:Bool):InternalFramebuffer;
    public function gfxFramebufferDispose(fb:InternalFramebuffer):Void;
    public function gfxSetFramebuffer(fb:InternalFramebuffer):Void;
    
    public function gfxImSetColor(r:Float, g:Float, b:Float, a:Float):Void;
    public function gfxImSetLineWidth(lw:Float):Void;
    public function gfxImRectFill(x:Float, y:Float, w:Float, h:Float):Void;
    public function gfxImRectLines(x:Float, y:Float, w:Float, h:Float):Void;
    public function gfxImLine(x0:Float, y0:Float, x1:Float, y1:Float):Void;
    public function gfxImBegin(mode:PrimitiveTopology):Void;
    public function gfxImEnd():Void;
    public function gfxImVertex(x:Float, y:Float):Void;

    public function gfxImMatrixIdentity():Void;
    public function gfxImTranslate(x:Float, y:Float):Void;
    public function gfxImScale(x:Float, y:Float):Void;
    public function gfxImRotate(angle:Float):Void;
    public function gfxImPushMatrix():Void;
    public function gfxImPopMatrix():Void;
}