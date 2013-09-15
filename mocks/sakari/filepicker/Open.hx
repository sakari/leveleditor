package mocks.sakari.filepicker;

class Open {
    static var current: Open;
    var callback: Array<String> -> Void;

    public function new() {}

    static public function get() {
        return current;
    }

    public function chooseFiles(): Open {
        return this;
    }

    public function select(paths:Array<String>) {
        Open.current = null;
        var c = callback;
        callback = null;
        c(paths);
    }
    public function open(cb: Array<String> -> Void) {
        Open.current = this;
        callback = cb;
    }
}