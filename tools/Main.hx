package tools;

import sys.FileSystem;
import haxe.io.Path;
import sys.io.File;
import haxe.Json;

class Main {
    static var directorySeparator = Sys.systemName() == "Windows" ? "\r\n" : "\n";

    static function main() {
        var projectDir = Sys.args()[0];
        var data = Json.parse(File.getContent(Path.join([projectDir, "petal.json"])));
        trace(data);
        
        var buildDir = Path.join([projectDir, "build"]);
        var outDir = Path.join([projectDir, "out"]);

        if (!FileSystem.exists(buildDir))
            FileSystem.createDirectory(buildDir);

        if (!FileSystem.exists(outDir))
            FileSystem.createDirectory(outDir);

        {
            var destFile = File.write(Path.join([outDir, "nativefs.lua"]), false);
            var srcFile = File.read("targets/love/nativefs.lua", false);

            while (!srcFile.eof()) {
                destFile.writeString(srcFile.readLine());
                destFile.writeString(directorySeparator);
            }
            
            destFile.close();
            srcFile.close();
        }

        var outHxml = File.write(Path.join([buildDir, "compile.hxml"]), false);

        var args:Array<String> = [];
        args.push("-lib love");
        args.push("-lib petal");

        for (cp in (data.classPaths : Array<String>)) {
            args.push("-cp " + Path.join([projectDir, cp]));
        }

        args.push('--main ${data.main}');

        args.push('--lua ${Path.join([outDir, "main.lua"])}');

        outHxml.writeString(args.join(directorySeparator), haxe.io.Encoding.UTF8);
        outHxml.close();
    }
}