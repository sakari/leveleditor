package mocks.sys.io;

class File {
    static public function write(path: String, binary):FileOutput {
        return new FileOutput(path);
    }
    static public function getContent(path: String): String {
        return Fs.read(path);
    }
}