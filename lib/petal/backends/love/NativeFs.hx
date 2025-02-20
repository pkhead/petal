package petal.backends.love;

import lua.Table;
import love.Data;
import love.data.ContainerType;
import love.filesystem.FileType;
import love.filesystem.FileMode;
import love.filesystem.FileData;
import love.filesystem.FilesystemModule;

extern class NativeFile extends love.filesystem.File {}

@:luaRequire("nativefs")
extern class NativeFs {
    /**
	 * Creates a new NativeFile object. 
	 * 
	 * It needs to be opened before it can be accessed.
	 * @param filename The filename of the file.
	 * @returns The new NativeFile object.
	 */
	@:overload(function (filename:String, mode:FileMode) : NativeFsNewFileResult {})
    public static function newFile(filename:String) : NativeFile;
    
    /**
	 * Creates a new FileData object from a file on disk, or from a string in memory.
	 * @param contents The contents of the file in memory represented as a string.
	 * @param name The name of the file. The extension may be parsed and used by LÖVE when passing the FileData object into love.audio.newSource.
	 * @returns The new FileData.
	 */
	@:overload(function (originaldata:Data, name:String) : FileData {})
    @:overload(function (filepath:String) : FilesystemModuleNewFileDataResult {})
    public static function newFileData(contents:String, name:String) : FileData;
    
    /**
	 * Mounts a zip file or folder in the game's save directory for reading.
	 * 
	 * It is also possible to mount love.filesystem.getSourceBaseDirectory if the game is in fused mode.
	 * @param archive The folder or zip file in the game's save directory to mount.
	 * @param mountpoint The new path the archive will be mounted to.
	 * @param appendToPath Whether the archive will be searched when reading a filepath before or after already-mounted archives. This includes the game's source and save directories.
	 * @returns True if the archive was successfully mounted, false otherwise.
	 */
	@:overload(function (filedata:FileData, mountpoint:String, ?appendToPath:Bool) : Bool {})
    @:overload(function (data:Data, archivename:String, mountpoint:String, ?appendToPath:Bool) : Bool {})
    public static function mount(archive:String, mountpoint:String, ?appendToPath:Bool) : Bool;
    
    /**
	 * Unmounts a zip file or folder previously mounted for reading with love.filesystem.mount.
	 * @param archive The folder or zip file in the game's save directory which is currently mounted.
	 * @returns True if the archive was successfully unmounted, false otherwise.
	 */
	public static function unmount(archive:String) : Bool;
    
    /**
	 * Read the contents of a file.
	 * @param name The name (and path) of the file.
	 * @param size How many bytes to read.
	 */
	@:overload(function (container:ContainerType, name:String, ?size:Float) : FilesystemModuleReadResult {})
    public static function read(name:String, ?size:Float) : FilesystemModuleReadResult;
    
    /**
	 * Write data to a file in the save directory. If the file existed already, it will be completely replaced by the new contents.
	 * @param name The name (and path) of the file.
	 * @param data The string data to write to the file.
	 * @param size How many bytes to write.
	 */
	@:overload(function (name:String, data:Data, ?size:Float) : FilesystemModuleWriteResult {})
    public static function write(name:String, data:String, ?size:Float) : FilesystemModuleWriteResult;
    
    /**
	 * Append data to an existing file.
	 * @param name The name (and path) of the file.
	 * @param data The string data to append to the file.
	 * @param size How many bytes to write.
	 */
	@:overload(function (name:String, data:Data, ?size:Float) : FilesystemModuleAppendResult {})
    public static function append(name:String, data:String, ?size:Float) : FilesystemModuleAppendResult;
    
    /**
	 * Iterate over the lines in a file.
	 * @param name The name (and path) of the file
	 * @returns A function that iterates over all the lines in the file
	 */
	public static function lines(name:String) : Void->Void;
    
    /**
	 * Loads a Lua file (but does not run it).
	 * @param name The name (and path) of the file.
	 */
	public static function load(name:String) : FilesystemModuleLoadResult;
    
    /**
	 * Gets the current working directory.
	 * @returns The current working directory.
	 */
	public static function getWorkingDirectory() : String;
    
    /**
	 * Returns a table with the names of files and subdirectories in the specified path. The table is not sorted in any way; the order is undefined.
	 * 
	 * If the path passed to the function exists in the game and the save directory, it will list the files and directories from both places.
	 * @param dir The directory.
	 * @returns A sequence with the names of all files and subdirectories as strings.
	 */
	@:overload(function (dir:String, callback:Void->Void) : Table<Dynamic,Dynamic> {})
    public static function getDirectoryItems(dir:String) : Table<Dynamic,Dynamic>;
    
    /**
	 * Gets information about the specified file or directory.
	 * @param path The file or directory path to check.
	 * @param filtertype If supplied, this parameter causes getInfo to only return the info table if the item at the given path matches the specified file type.
	 * @returns A table containing information about the specified path, or nil if nothing exists at the path. The table contains the following fields:
	 */
	@:overload(function (path:String, info:Table<Dynamic,Dynamic>) : Table<Dynamic,Dynamic> {})
        @:overload(function (path:String, filtertype:FileType, info:Table<Dynamic,Dynamic>) : Table<Dynamic,Dynamic> {})
    public static function getInfo(path:String, ?filtertype:FileType) : Table<Dynamic,Dynamic>;
    
    /**
	 * Recursively creates a directory.
	 * 
	 * When called with 'a/b' it creates both 'a' and 'a/b', if they don't exist already.
	 * @param name The directory to create.
	 * @returns True if the directory was created, false if not.
	 */
	public static function createDirectory(name:String) : Bool;
    
    /**
	 * Removes a file or empty directory.
	 * @param name The file or directory to remove.
	 * @returns True if the file/directory was removed, false otherwise.
	 */
	public static function remove(name:String) : Bool;

    public static function getDirectoryItemsInfo(path:String, ?filterType:FileType):Array<Table<Dynamic,Dynamic>>;

    public static function getDriveList():Array<String>;
    public static function setWorkingDirectory(path:String):NativeFsSetWorkingDirectoryResult;
}

@:multiReturn
extern class NativeFsNewFileResult
{
	var file : NativeFile;
	var errorstr : Null<String>;
}

@:multiReturn
extern class NativeFsSetWorkingDirectoryResult {
    var success:Bool;
    var error:Null<String>;
}