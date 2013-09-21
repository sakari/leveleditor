package sakari.leveleditor;

class ObservableBool<T: Bool> extends Observable<T> {
    public function new(s: T) {
        super(s);
    }

    public override function listen(l: T -> T -> Void) {
        super.listen(function(v, o) {
                if(v == o) return;
                l(v, o);
            });
        return this;
    }

    public function follows(rhs: ObservableBool<T>) {
        set(rhs.get());
        rhs.listen(function(v, o) {
                set(v);
            });
    }

    public function iff(rhs: ObservableBool<T>) {
        follows(rhs);
        rhs.follows(this);
    }

    public function reverse(rhs: ObservableBool<T>) {
        var d: Dynamic = !rhs.get();
        set(d);
        rhs.listen(function(v: T, o) {
                var d: Dynamic = !v;
                set(d);
            });
    }

    public function iffNot(rhs: ObservableBool<T>) {
        reverse(rhs);
        rhs.reverse(this);
    }
}