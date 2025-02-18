package petal.gfx;

import haxe.Exception;
import haxe.exceptions.ArgumentException;
import petal.backends.Backend.InternalMesh;
import petal.util.ByteData;

/**
 * Describes the role of a vertex attribute.
 */
enum MeshAttributeName
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

/**
 * Describes the primitive data type of each component of a vertex attribute.
 */
enum MeshAttributeType {
    Float;
    Byte;
}

/**
 * The primitive data type of each index element for a mesh.
 */
enum IndexDataType {
    UInt16;
    UInt32;
}

/**
 * The expected frequency of mesh data updates. It affects the mesh's memory usage and performance.
 */
enum BufferUsage {
    /**
     * The mesh will be updated infrequently or not at all.
     */
    Static;

    /**
     * The mesh will be updated frequently.
     */
    Dynamic;

    /**
     * The mesh will be updated on every frame.
     */
    Stream;
}

/**
 * How the vertex data in a mesh is interpreted when drawing.
 */
enum MeshDrawMode {
    /**
     * The vertices create unconnected triangles.
     */
    Triangles;

    /**
     * The vertices create a series of triangles that each share two vertices with the last triangle.
     * 
     * With V being the vertex list, the first triangle is created with `V[0]`, `V[1]`, and `V[2]`. Afterwards,
     * each vertex creates a triangle with `V[i-1]`, `V[i-2]`, and `V[i]`, with `i` being the index of the new vertex.
     */
    Strip;

    /**
     * This creates a series of triangles that each share one central vertex.
     * 
     * With V being the vertex list, the first triangle is created with `V[0]`, `V[1]`, and `V[2]`. Afterwards,
     * each vertex creates a triangle with the points `V[0]`, `V[i-1]`, and `V[i-2]`, with `i` being the index
     * of the new vertex.
     */
    Fan;
}

/**
 * Description of a vertex attribute. Each attribute has `size` components of type `type`. `name` describes the role of the åttribute.
 */
typedef VertexAttributeDescription = {
    name:MeshAttributeName,
    type:MeshAttributeType,
    size:Int
}

/**
 * Representation of a standard-format vertex.
 */
typedef Vertex = {
    x:Float, y:Float,
    u:Float, v:Float,
    color:Int
}

/**
 * Class used for representing polygonal meshes.
 */
class Mesh {
    var internal:InternalMesh;
    var _indexType:Null<IndexDataType>;
    var _vtxCount:Int;
    var _vtxFormatSize:Int;
    var _indicesUploaded = false;

    static var stdFormat = [
        {name: Position, type: Float, size: 2},
        {name: TexCoord0, type: Float, size: 2},
        {name: Color0, type: Byte, size: 4},
    ];

    /**
     * Calculate the size, in bytes, of each vertex following the given format.
     * @param format The vertex format description.
     */
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

    /**
     * Create an uninitialized mesh with a custom vertex format.
     * @param format The vertex format to use.
     * @param vertexCount The number of vertices the mesh will have.
     * @param indexType The primitive type of each element in the index buffer. Null if the mesh is not indexed.
     * @param usage The expected frequency of mesh data updates. It affects the mesh's memory usage and performance.
     */
    public function new(format:Array<VertexAttributeDescription>, vertexCount:Int, indexType:Null<IndexDataType>, mode:MeshDrawMode, usage:BufferUsage) {
        var backend = @:privateAccess Graphics.instance.backend;
        internal = backend.gfxMeshNew(format, vertexCount, indexType != null, indexType ?? UInt16, mode, usage);

        _indexType = indexType;
        _vtxCount = vertexCount;
        _vtxFormatSize = calcVertexSize(format);
    }

    /**
     * Create a new mesh using the standard vertex format.
     * @param vertexCount The number of vertices the mesh will have.
     * @param indexType The primitive type of each element in the index buffer. Null if the mesh is not indexed.
     * @param usage The expected frequency of mesh data updates. It affects the mesh's memory usage and performance.
     */
    public static function createStandard(vertexCount:Int, indexType:Null<IndexDataType>, mode:MeshDrawMode, usage:BufferUsage) {
        return new Mesh(stdFormat, vertexCount, indexType, mode, usage);
    }

    /**
     * Create a new mesh from an array of vertex data.
     * @param vertices The vertex data the mesh will be initialized with.
     * @param usage The expected frequency of mesh data updates. It affects the mesh's memory usage and performance.
     */
    public static function createFromArray(vertices:Array<Vertex>, mode:MeshDrawMode, usage:BufferUsage) {
        var mesh = new Mesh(stdFormat, vertices.length, null, mode, usage);
        mesh.uploadVertices(vertices);

        return mesh;
    }

    /**
     * Create a new indexed mesh from an array of vertex data and indices.
     * @param vertices The vertex data the mesh will be initialized with.
     * @param indices The index data the mesh will be initialized with.
     * @param indexDataType The primtive type of each element in the index buffer.
     * @param usage The expected frequency of mesh data updates. It affects the mesh's memory usage and performance.
     */
     public static function createIndexedFromArray(vertices:Array<Vertex>, indices:Array<Int>, indexDataType:IndexDataType, mode:MeshDrawMode, usage:BufferUsage) {
        var mesh = new Mesh(stdFormat, vertices.length, indexDataType, mode, usage);
        mesh.uploadVertices(vertices);
        mesh.uploadIndices(indices);

        return mesh;
    }
    
    /**
     * Upload the vertex data of the mesh from a ByteData.
     * @param data The data to update the mesh with.
     * @param startVertex The index of the vertex to start from. Defaults to 0.
     * @param vertexCount The number of vertices to overwrite. Defaults to the number of vertices in the given data.
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
     * Upload the vertex data of the mesh from a vertex array.
     * @param vertices The data to update the mesh with.
     * @param startVertex The index of the vertex to start from. Defaults to 0.
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
     * @param data New index data for the mesh.
     */
    public function uploadByteIndices(data:ByteData) {
        if (_indexType == null) {
            throw new Exception("Attempt to upload indices of non-indexed Mesh");
        }

        var backend = @:privateAccess Graphics.instance.backend;
        backend.gfxMeshUploadIndices(internal, data);
    }

    /**
     * Upload the index data of the mesh from an int array.
     * @param indices New index data for the mesh.
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

        uploadByteIndices(bytes);
        bytes.dispose();

        _indicesUploaded = true;
    }

    /**
     * Draw the mesh into the active framebuffer.
     */
    public function draw() {
        if (_indexType != null && !_indicesUploaded)
            throw new Exception("No index data was uploaded to the Mesh");

        var backend = @:privateAccess Graphics.instance.backend;
        backend.gfxMeshDraw(internal);
    }

    /**
     * Immediately dispose internal resources used by the Mesh.
     * @returns False if the object had already been disposed, true otherwise.
     */
    public function dispose() {
        if (internal == null) return false;

        var backend = @:privateAccess Graphics.instance.backend;
        backend.gfxMeshDispose(internal);
        internal = null;
        return true;
    }
}