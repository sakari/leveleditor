package mocks.sakari.menubar;

class Menubar {
    static var menubar;
    var menus: Map<String, Void -> Void>;

    private function new() {
        menus = new Map();
    }
    
    static public function get() {
        if(menubar == null)
            menubar = new Menubar();
        return menubar;
    }

    public function add(path, ?short, ?enable, ?cb: Void -> Void) {
        if(cb != null) {
            menus.set(path, cb);
        }
        return this;
    }

    public function enable(path) {
        return this;
    }

    public function disable(path) {
        return this;
    }

    public function listen(path, cb) {
        menus.set(path, cb);
        return this;
    }

    public function off(path) { return this; }
    public function on(path) { return this; }

    public function click(path) {
        if(menus.get(path) != null)
            menus.get(path)();
        return this;
    }
}