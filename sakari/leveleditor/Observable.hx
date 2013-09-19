package sakari.leveleditor;

class Observable<T> {
    var t: T;
    var listeners: Array<T -> T -> Void>;
    public function new(t: T) {
        listeners = [];
        this.t = t;
    }

    public function set(t: T): Observable<T> {
        var old = this.t;
        this.t = t;
        notify(old);
        return this;
    }

    public function get(): T {
        return this.t;
    }

    public function listen(f:T -> T -> Void): Observable<T> {
        listeners.push(f);
        return this;
    }

    function notify(T) {
        for(i in listeners) {
            i(this.t, T);
        }
    }
}
