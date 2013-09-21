package sakari.leveleditor;
import sakari.menubar.Menubar;
import sakari.leveleditor.Editor;

typedef Selection<T> = {
    var tag: String;
    var arg: T;
};

class MenuSelect<T> {
    var m: Menubar;
    var root: String;
    public var observe(get, null): Observable<T>;
    var _observe: Observable<T>;
    var _select: Observable<Selection<T>>;

    public function get_observe() {
        return _observe;
    }

    public function new(m: Menubar
                        , root: String) {
        this.m = m;
        _select = new Observable(null);
        _observe = new Observable(null);
        _select.listen(function(v: Selection<T>, o) {
                if(v == null) {
                    _observe.set(null);
                    return;
                }
                _observe.set(v.arg);
            });
        this.root = root;
    }

    private function name(tag: String): String {
        return '$root/$tag';
    }

    public function reset() {
        if(_select.get() == null) return;
        m.off(name(_select.get().tag));
        _select.set(null);
    }

    public function add(tag: String, data: T) {
        m.add(name(tag))
            .enable(name(tag))
            .listen(name(tag), function() {
                    if(_select.get() != null) {
                        m.off(name(_select.get().tag));
                        if(_select.get().tag == tag) {
                            _select.set(null);
                            return;
                        }
                    }
                    m.on(name(tag));
                    _select.set({tag: tag, arg: data});
                });
    }
}