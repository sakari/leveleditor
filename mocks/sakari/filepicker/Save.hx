package mocks.sakari.filepicker;

class Save {
    static var current: Save;
    var callback: String -> Void;

    public function new() {}
    static public function get() {
        return current;
    }

    public function extensions(x: Array<String>): Save {
        return this;
    }

    public function select(path:String) {
        Save.current = null;
        var c = callback;
        callback = null;
        c(path);
    }
    public function open(cb: String -> Void) {
        Save.current = this;
        callback = cb;
    }
}