package tools;

import sys.io.File;
import sys.io.FileInput;

enum KeywordType {
    KwModule;
    KwVertex;
    KwFragment;
    KwNamespace;
}

enum TokenData {
    Keyword(type:KeywordType);
    Identifier(value:String);
    Symbol(value:String);
    ShaderSource(value:String);
}

typedef Token = {
    line:Int,
    offset:Int,
    data:TokenData
}

private class ShaderParser {
    // only supports symbols up to two characters in length
    static var symbols:Array<String> = [
        "//", "/*",
        "@", "{", "}", "."
    ];

    static var keywords:Map<String, KeywordType> = [
        "module" => KwModule,
        "vertex" => KwVertex,
        "fragment" => KwFragment,
        "namespace" => KwNamespace
    ];

    // assuming the to-be-pushed token is a open brace,
    // check if based on context that this denotes a shader source
    static function isBeginningShaderSource(outTokens:Array<Token>) {
        if (outTokens.length < 2) return false;

        switch (outTokens[outTokens.length - 2].data) {
            case Keyword(type):
                if (type == KwModule || type == KwVertex || type == KwFragment) {
                    switch (outTokens[outTokens.length - 1].data) {
                        case Identifier(value):
                            return true;

                        default:
                    }
                }

            default:
        }

        return false;
    }

    public static function readTokens(file:FileInput):Array<Token> {
        var outTokens:Array<Token> = [];

        var lineNumber = 1;

        function processWord(line:String, wordStart:Int, wordEnd:Int) {
            if (wordEnd > wordStart) {
                var word = line.substring(wordStart, wordEnd);
    
                var kw = keywords.get(word);
                var tokData:TokenData;
    
                if (kw != null) {
                    tokData = TokenData.Keyword(kw);
                } else {
                    tokData = TokenData.Identifier(word);
                }
    
                outTokens.push({
                    line: lineNumber,
                    offset: wordStart + 1,
                    data: tokData
                });
            }
        }

        var blockComment = false;

        var shaderSource = false;
        var shaderSourceStartLine = 0;
        var shaderSourceStartOffset = 0;
        var braceLevel = 0;
        var shaderSourceLines:Array<String> = [];

        while (!file.eof()) {
            var line = file.readLine();

            var wordStart = 0;
            var wordEnd = 0;
            var charIndex = 0;

            while (charIndex < line.length) {
                if (blockComment) {
                    if (line.substr(charIndex, 2) == "*/") {
                        blockComment = false;
                        charIndex += 2;
                        wordStart = charIndex;
                        wordEnd = charIndex;
                    } else {
                        charIndex++;
                    }

                    continue;
                }
                
                if (shaderSource) {
                    if (line.charAt(charIndex) == "{") braceLevel++;
                    else if (line.charAt(charIndex) == "}") braceLevel--;

                    if (braceLevel == 0) {
                        shaderSourceLines.push(line.substring(wordStart, charIndex));
                        
                        outTokens.push({
                            line: shaderSourceStartLine,
                            offset: shaderSourceStartOffset,
                            data: TokenData.ShaderSource(shaderSourceLines.join(Util.lineSeparator))
                        });

                        shaderSource = false;

                        charIndex++;
                        wordStart = charIndex;
                        wordEnd = charIndex;
                    } else {
                        charIndex++;
                    }

                    continue;
                }

                // check if the next two characters matches any symbols
                var sym:Null<String> = null;

                for (qSym in symbols) {
                    if (qSym.length == 0) continue;
                    if (
                        (qSym.charCodeAt(0) == line.charCodeAt(charIndex)) &&
                        (qSym.length < 2 || qSym.charCodeAt(1) == line.charCodeAt(charIndex + 1))
                    ) {
                        sym = qSym;
                    }
                }

                if (sym != null) {
                    processWord(line, wordStart, wordEnd);

                    // line comment handling: hardcoded
                    if (sym == "//") {
                        wordStart = line.length;
                        wordEnd = line.length;
                        break;
                    }

                    // block comment handling: hardcoded
                    else if (sym == "/*") {
                        blockComment = true;
                    }

                    else if (sym == "{" && isBeginningShaderSource(outTokens)) {
                        shaderSource = true;
                        braceLevel = 1;
                        shaderSourceLines = [];

                        shaderSourceStartLine = lineNumber;
                        shaderSourceStartOffset = charIndex + 1;
                    }

                    else {
                        outTokens.push({
                            line: lineNumber,
                            offset: charIndex + 1,
                            data: TokenData.Symbol(sym)
                        });
                    }

                    charIndex += sym.length - 1;
                    wordStart = charIndex + 1;
                    wordEnd = wordStart; 
                } else if (StringTools.isSpace(line, charIndex)) {
                    processWord(line, wordStart, wordEnd);

                    while (charIndex < line.length && StringTools.isSpace(line, charIndex)) {
                        charIndex++;
                    }

                    wordStart = charIndex;
                    wordEnd = charIndex;
                    charIndex--;
                } else {
                    wordEnd++;
                }

                charIndex++;
            }

            if (!blockComment && !shaderSource) processWord(line, wordStart, line.length);
            if (shaderSource) {
                shaderSourceLines.push(line.substring(wordStart, line.length));
            }
            lineNumber++;
        }

        return outTokens;
    }
}

enum ModuleType {
    Header;
    Vertex;
    Fragment;
}

class ShaderModule {
    var type(default, null): ModuleType;
    var name(default, null):String;

    public function new(moduleName:String, type:ModuleType, source:String, tags:Array<String>) {
        trace('Module ${moduleName}, ${type}, ${tags}');
        this.type = type;
    }
}

class ShaderProcessor {
    var tokens:Array<Token>;
    var tokenIndex = 0;
    var filePath:String;

    var modules:Map<String, ShaderModule> = [];
    
    function new() {}

    public static function process(filePath:String) {
        return new ShaderProcessor().instProcess(filePath);
    }

    inline function popToken() {
        return tokens[tokenIndex++];
    }

    inline function peekToken() {
        return tokens[tokenIndex];
    }

    inline function isTokenEof() {
        return tokenIndex >= tokens.length;
    }

    inline function tokenExpect(expected:TokenData) {
        var tok = popToken();
        if (!tok.data.equals(expected)) {
            error(tok, 'expected ${tokToString(expected)}, got ${tokToString(tok.data)}');
        }
        return tok;
    }


    function tokToString(tokData:TokenData) {
        return Std.string(tokData);
    }

    inline function error(tok:Token, msg:String) {
        throw new haxe.Exception('${filePath}:${tok.line}:${tok.offset}: ' + msg);
    }

    function tokIsKeyword(tok:Token, ?reqType:KeywordType) {
        if (reqType == null) {
            switch (tok.data) {
                case Keyword(_): return true;
                default: return false;
            }
        } else {
            switch (tok.data) {
                case Keyword(type):
                    return type == reqType;

                default: return false;
            }
        }
    }

    function procModuleDef(?namespace:String, type:ModuleType, tags:Array<String>) {
        var idToken = popToken();
        switch (idToken.data) {
            case Identifier(modName):
                var src = popToken();
                switch (src.data) {
                    case ShaderSource(value):
                        var fullName = namespace == null ? modName : namespace + "." + modName;
                        if (modules.exists(fullName)) {
                            error(src, "redefinition of module " + fullName);
                        }

                        var mod = new ShaderModule(fullName, type, value, tags);
                        modules[fullName] = mod;

                    default: error(src, "expected shader source, got" + tokToString(src.data));
                }
                
            default: error(idToken, "expected identifier, got" + tokToString(idToken.data));
        }
    }

    function procNamespace(?namespace:String) {
        trace(namespace);

        var tags:Array<String> = [];

        while (true) {
            var tok = peekToken();
            if (tok == null) break;

            switch (tok.data) {
                case Symbol("@"):
                    popToken();
                    var tagId = popToken();
                    switch (tagId.data) {
                        case Identifier(value):
                            if (tags.contains(value))
                                error(tagId, "redefinition of tag " + value);

                            tags.push(value);

                        default: error(tagId, "expected identifier, got " + tokToString(tagId.data));
                    }

                case Keyword(KeywordType.KwNamespace):
                    popToken();

                    var idToken = popToken();
                    switch (idToken.data) {
                        case Identifier(subName):
                            tokenExpect(Symbol("{"));
                            procNamespace(namespace == null ? subName : namespace + "." + subName);
                            tokenExpect(Symbol("}"));
                            
                        default: error(idToken, "expected identifier, got " + tokToString(idToken.data));
                    }

                case Keyword(KeywordType.KwModule):
                    popToken();
                    procModuleDef(namespace, ModuleType.Header, tags);
                    tags.resize(0);
                
                case Keyword(KeywordType.KwVertex):
                    popToken();
                    procModuleDef(namespace, ModuleType.Vertex, tags);
                    tags.resize(0);

                case Keyword(KeywordType.KwFragment):
                    popToken();
                    procModuleDef(namespace, ModuleType.Fragment, tags);
                    tags.resize(0);

                default:
                    break;
            }
        }
    }

    public function instProcess(filePath:String) {
        this.filePath = filePath;
        var file = File.read(filePath, false);
        tokens = ShaderParser.readTokens(file);
        file.close();
        
        procNamespace();
    }
}