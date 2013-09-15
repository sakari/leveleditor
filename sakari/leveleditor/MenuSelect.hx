package sakari.leveleditor;

#if mocks
import mocks.sakari.menubar.Menubar;
#else
import sakari.menubar.Menubar;
#end

class MenuSelect<T> {
    var m: Menubar;
    var root: String;
    var selected(get, null): Null<String>;
    var _selected: Null<String>;
    var cb: String -> T -> Void;

    public function get_selected(): String {
        return _selected;
    }
    public function new(m: Menubar
                        , root: String) {
    
        this.m = m;
        this.root = root;
        _selected = null;
    }

    private function name(tag: String): String {
        return '$root/$tag';
    }

    public function onSelect(cb: String -> T -> Void): MenuSelect<T> {
        this.cb = cb;
        return this;
    }

    public function reset() {
        if(selected == null) return;
        m.off(name(selected));
        _selected = null;
        cb(null, null);
    }

    public function add(tag: String, data: T) {
        m.add(name(tag))
            .enable(name(tag))
            .listen(name(tag), function() {
                    if(selected != null) {
                        m.off(name(selected));
                        if(selected == tag) {
                            selected = null;
                            cb(null, null);
                            return;
                        }
                    }
                    m.on(name(tag));
                    cb(tag, data);
                    _selected = tag;
                });
    }
}