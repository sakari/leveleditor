package mocks.sys.io;

class Fs {
    static var fs: Map<String, String>;
    static public function clean() {
        fs = new Map();
    }
    static public function write(path, str) {
        fs.set(path, str);
    }
    static public function read(path) {
        return fs.get(path);
    }
}