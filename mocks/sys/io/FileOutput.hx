package mocks.sys.io;

class FileOutput {
    var _path: String;
    var _buffered = null;
    var _closed = false;
    public function new(path: String) {
        _path = path;
    }

    public function writeString(str: String) {
        if(_closed) throw 'writing to closed file $_path';
        _buffered = str;
    }
    
    public function close() {
        if(_closed) throw 'double close of file $_path';
        Fs.write(_path, _buffered);
        _closed = true;
    }
}