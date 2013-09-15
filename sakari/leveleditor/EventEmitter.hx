package sakari.leveleditor;

class EventEmitter<T> {
    var listeners: Array<T -> Void>;
    public function new() {
        listeners = [];
    }

    public function call(cb) {
        listeners.push(cb);
        return this;
    }

    public function emit(?value: T) {
        listeners.map(function(cb) {
                cb(value);
            });
        return this;
    }
}