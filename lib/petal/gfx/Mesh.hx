package petal.gfx;

import haxe.Exception;
import haxe.exceptions.ArgumentException;
import petal.backends.Backend.InternalMesh;
import petal.util.ByteData;

enum AttributeName
{
    Position;
    Normal;
    Tangent;
    Bitangent;
    Color0;
    Color1;
    Color2;
    Color3;
    Indices;
    Weight;
    TexCoord0;
    TexCoord1;
    TexCoord2;
    TexCoord3;
    TexCoord4;
    TexCoord5;
    TexCoord6;
    TexCoord7;
}

enum AttributeType {
    Float;
    Byte;
}

enum IndexDataType {
    UInt16;
    UInt32;
}

enum BufferUsage {
    Static;
    Dynamic;
    Stream;
}

typedef VertexAttributeDescription = {
    name:AttributeName,
    type:AttributeType,
    size:Int
}

typedef Vertex = {
    x:Float, y:Float,
    u:Float, v:Float,
    color:Int
}

class Mesh {
    var internal:InternalMesh;
    var _indexType:Null<IndexDataType>;
    var _vtxCount:Int;
    var _vtxFormatSize:Int;

    static var stdFormat = [
        {name: Position, type: Float, size: 2},
        {name: TexCoord0, type: Float, size: 2},
        {name: Color0, type: Byte, size: 4},
    ];

    public static function calcVertexSize(format:Array<VertexAttributeDescription>) {
        var size = 0;

        for (f in format) {
            size += switch (f.type) {
                case Float: 4 * f.size;
                case Byte: f.size;
            };
        }

        return size;
    }

    public function new(format:Array<VertexAttributeDescription>, vertexCount:Int, indexType:Null<IndexDataType>, usage:BufferUsage) {
        var backend = @:privateAccess Graphics.instance.backend;
        internal = backend.gfxMeshNew(format, vertexCount, indexType != null, indexType ?? UInt16, usage);

        _indexType = indexType;
        _vtxCount = vertexCount;
        _vtxFormatSize = calcVertexSize(format);
    }

    /**
     * Create a new mesh from an array of vertex data.
     * @param vertices
     * @param usage
     */
    public static function createFromArray(vertices:Array<Vertex>, usage:BufferUsage) {
        var mesh = new Mesh(stdFormat, vertices.length, null, usage);
        mesh.uploadVertices(vertices);

        return mesh;
    }
    
    /**
     * Upload the vertex data of the mesh from a ByteData.
     * @param data 
     * @param startVertex 
     * @param vertexCount 
     */
    public function uploadByteVertices(data:ByteData, startVertex:Int = 0, ?vertexCount:Int) {
        var backend = @:privateAccess Graphics.instance.backend;
        vertexCount ??= Std.int(data.length / _vtxFormatSize);

        if (startVertex < 0 || startVertex + vertexCount > _vtxCount) {
            throw new Exception("Given slice is out of bounds");
        }

        backend.gfxMeshUploadVertices(internal, data, startVertex, vertexCount);
    }

    /**
     * Upload the vertex data of the mesh from a Vertex array.
     * @param vertices 
     * @param startVertex 
     */
    public function uploadVertices(vertices:Array<Vertex>, startVertex:Int = 0) {
        if (_vtxFormatSize != 20) throw new ArgumentException("vertices", "Incompatible vertex formats");

        var bytes = new ByteData(vertices.length * 20);
        var offset = 0;
        for (vtx in vertices) {
            bytes.setFloat(offset, vtx.x);
            bytes.setFloat(offset + 4, vtx.y);
            bytes.setFloat(offset + 8, vtx.u);
            bytes.setFloat(offset + 12, vtx.v);
            bytes.setUInt32(offset + 16, vtx.color);
            offset += 20;
        }

        uploadByteVertices(bytes, startVertex, vertices.length);
        bytes.dispose();
    }

    /**
     * Upload the index data of the mesh from a ByteData.
     * @param data 
     */
    public function uploadByteIndices(data:ByteData) {
        if (_indexType == null) {
            throw new Exception("Attempt to upload indices of non-indexed Mesh");
        }

        var backend = @:privateAccess Graphics.instance.backend;
        backend.gfxMeshUploadIndices(internal, data);
    }

    /**
     * Upload the index data of the mesh from an Int array.
     * @param indices 
     */
    public function uploadIndices(indices:Array<Int>) {
        if (_indexType == null) {
            throw new Exception("Attempt to upload indices of non-indexed Mesh");
        }

        var bytes:ByteData;
        var offset = 0;

        switch (_indexType) {
            case UInt16:
                bytes = new ByteData(indices.length * 2);

                for (v in indices) {
                    bytes.setUInt16(offset, v);
                    offset += 2;
                }

            case UInt32:
                bytes = new ByteData(indices.length * 4);

                for (v in indices) {
                    bytes.setUInt32(offset, v);
                    offset += 4;
                }
        }

        uploadByteVertices(bytes);
        bytes.dispose();
    }

    /**
     * Draw the mesh into the active framebuffer.
     */
    public function draw() {
        var backend = @:privateAccess Graphics.instance.backend;
        backend.gfxMeshDraw(internal);
    }
}