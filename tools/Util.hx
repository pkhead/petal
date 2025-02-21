package tools;

class Util {
    public static var lineSeparator(default, never) = Sys.systemName() == "Windows" ? "\r\n" : "\n";
}