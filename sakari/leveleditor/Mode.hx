package sakari.leveleditor;

class Mode {
    var enableListeners: Array<Void -> Void>;
    var disableListeners: Array<Void -> Void>;
    var _enabled: Bool;
    public var enabled(get, null): Bool;

    public function new() {
        enableListeners = [];
        disableListeners = [];
        _enabled = false;
    }
    public function enable(): Mode {
        if(enabled) return this;
        _enabled = true;
        for(i in enableListeners) {
            i();
        }
        return this;
    }

    public function get_enabled() {
        return _enabled;
    }

    public function disable(): Mode {
        if(!enabled) return this;
        _enabled = false;
        for(i in disableListeners) {
            i();
        }
        return this;
    }

    public function onEnable(cb: Void -> Void): Mode {
        enableListeners.push(cb);
        return this;
    }

    public function onDisable(cb: Void -> Void): Mode {
        disableListeners.push(cb);
        return this;
    }
}