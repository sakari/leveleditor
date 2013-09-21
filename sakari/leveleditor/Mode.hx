package sakari.leveleditor;

class Mode extends ObservableBool<Bool>{
    var enableListeners: Array<Void -> Void>;
    var disableListeners: Array<Void -> Void>;
    public var enabled(get, null): Bool;

    public function new() {
        super(false);
    }

    public function enable(): Mode {
        if(get()) return this;
        set(true);
        return this;
    }

    public function get_enabled() {
        return get();
    }

    public function disable(): Mode {
        if(!get()) return this;
        set(false);
        return this;
    }

    public function onEnable(cb: Void -> Void): Mode {
        listen(function(v, o) {
                if(!v) return;
                cb();
            });
        return this;
    }

    public function onDisable(cb: Void -> Void): Mode {
        listen(function(v, o) {
                if(v) return;
                cb();
            });
        return this;
    }
}