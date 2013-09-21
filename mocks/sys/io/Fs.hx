package mocks.sys.io;

class Fs {
    static var fs: Map<String, String>;
    static public function clean() {
        fs = new Map();
    }
    static public function write(path, str) {
        if(path == null) throw 'saving with null path';
        fs.set(path, str);
    }
    static public function read(path) {
        if(path == null) throw 'reading with null path';
        return fs.get(path);
    }
}