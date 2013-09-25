package sakari.leveleditor;
import flash.events.EventDispatcher;

class Mode extends ObservableBool<Bool>{
    var enableListeners: Array<Void -> Void>;
    var disableListeners: Array<Void -> Void>;
    public var enabled(get, null): Bool;
    
    var events: Array<{e: EventDispatcher, type: String, cb: Dynamic -> Void}>;

    public function new() {
        super(false);
        events = [];
    }

    public function manageEvent(e: EventDispatcher
                                , type: String
                                , cb: Dynamic -> Void) {
        events.push({e: e, type: type, cb: cb});
    }

    public function enable(): Mode {
        if(!get())
            set(true);
        events.map(function(i) {
                trace('adding event listener', i.type);
                i.e.addEventListener(i.type, i.cb);
            });
        return this;
    }

    public function get_enabled() {
        return get();
    }

    public function disable(): Mode {
        if(get())
            set(false);
        events.map(function(i) {
                i.e.removeEventListener(i.type, i.cb);
            });
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