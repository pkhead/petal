package tools;

import sys.FileSystem;
import haxe.io.Path;
import sys.io.File;
import haxe.Json;

class Main {
    static var programArgs = Sys.args();

    static function showHelp() {
        Sys.println("help - show this help page");
        Sys.println("generate - generate project files");
        Sys.println("bulid - generate and build the project files");
    }

    static function main() {
        if (programArgs.length == 1) {
            showHelp();
            return;
        }

        var projectDir = programArgs[programArgs.length - 1];
        var subcommand = programArgs[0];
        switch (subcommand) {
            case "generate":
                var proj = new Project(projectDir);
                proj.generateLove2d();

            case "build":
                var proj = new Project(projectDir);
                proj.generateLove2d();
                Sys.command("haxe", [projectDir + "/build/compile.hxml"]);

            case "help":
                showHelp();

            default:
                Sys.println("unknown command: " + subcommand);
        }
    }
}