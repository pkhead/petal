package tools;

import haxe.io.Path;
import sys.io.File;
import sys.FileSystem;
import haxe.Json;

class Project {
    var projectDir:String;
    var buildDir:String;
    var outDir:String;

    var projectData:Dynamic;
    
    public function new(projectDir:String) {
        this.projectDir = projectDir;

        buildDir = Path.join([projectDir, "build"]);
        outDir = Path.join([projectDir, "out"]);
        projectData = Json.parse(File.getContent(Path.join([projectDir, "petal.json"])));

        if (!FileSystem.exists(buildDir))
            FileSystem.createDirectory(buildDir);

        if (!FileSystem.exists(outDir))
            FileSystem.createDirectory(outDir);

        var shaderPaths:Array<String> = projectData.shaderPaths;
        for (path in shaderPaths) {
            for (name in FileSystem.readDirectory(Path.join([projectDir, path]))) {
                var absPath = Path.join([projectDir, path, name]);
                trace(absPath);

                ShaderProcessor.process(absPath);
            }
        }
    }

    function writeHxml(args:Array<String>, out:String) {
        var outHxml = File.write(out, false);
        outHxml.writeString(args.join(Util.lineSeparator), haxe.io.Encoding.UTF8);
        outHxml.close();
    }

    public function generateLove2d() {
        // copy nativefs library to love2d project
        {
            var destFile = File.write(Path.join([outDir, "nativefs.lua"]), false);
            var srcFile = File.read("targets/love/nativefs.lua", false);

            while (!srcFile.eof()) {
                destFile.writeString(srcFile.readLine());
                destFile.writeString(Util.lineSeparator);
            }
            
            destFile.close();
            srcFile.close();
        }

        // write conf.lua
        {
            var lines:Array<String> = [];
            lines.push("function love.conf(t)");
            lines.push("  t.window.width = 800");
            lines.push("  t.window.height = 600");
            lines.push("  t.window.resizable = true");
            lines.push("end");
            
            var destFile = File.write(Path.join([outDir, "conf.lua"]), false);
            for (l in lines) {
                destFile.writeString(l);
                destFile.writeString(Util.lineSeparator);
            }
            destFile.close();
        }
        var haxeArgs:Array<String> = [];

        haxeArgs.push("-lib love");
        haxeArgs.push("-lib petal");

        for (cp in (projectData.classPaths : Array<String>)) {
            haxeArgs.push("-cp " + Path.join([projectDir, cp]));
        }

        haxeArgs.push('--main ${projectData.main}');
        haxeArgs.push('--lua ${Path.join([outDir, "main.lua"])}');

        writeHxml(haxeArgs, Path.join([buildDir, "compile.hxml"]));
    }
}