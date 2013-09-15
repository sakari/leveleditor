package mocks.sys.io;

class FileOutput {
    var path: String;
    public function new(path: String) {
        this.path = path;
    }
    public function writeString(str: String) {
        Fs.write(this.path, str);
    }
}