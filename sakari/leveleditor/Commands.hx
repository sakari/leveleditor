package sakari.leveleditor;
import sakari.menubar.Menubar;
import flash.display.DisplayObjectContainer;
import flash.events.KeyboardEvent;
import flash.events.Event;
using Lambda;

class Commands extends Mode{
    static var _commands: Commands;
    var _on: DisplayObjectContainer;
    var _modifier = false;
    var _keys: Map<String, Void -> Void>;

    private function new(on: DisplayObjectContainer) {
        super();
        _keys = new Map();
        _on = on;

        manageEvent(_on, KeyboardEvent.KEY_DOWN, keyDown);
        manageEvent(_on, KeyboardEvent.KEY_UP, keyUp);
        onEnable(function() {
                _modifier = false;
            });
    }

    private function keyUp(e: KeyboardEvent) {
        if(e.keyCode == 15) {
            _modifier = false;
            return;
        }
    }

    private function keyDown(e: KeyboardEvent) {
        trace('keydown', e.charCode, e.shiftKey, _modifier);
        if(e.keyCode == 15) {
            _modifier = true;
            return;
        }
        if(!_modifier) return;
        for(k in _keys.keys()) {
            var charCode = e.shiftKey ?
                k.toLowerCase().charCodeAt(0) :
                k.charCodeAt(0);

            if(k.toLowerCase() == k && e.shiftKey)
                continue;
            if(charCode == e.charCode) {
                _keys.get(k)();
                break;
            }
        }
    }
            
    static public function instance(on: DisplayObjectContainer): Commands {
        if(_commands == null) {
            _commands = new Commands(on);
        }
        return _commands;
    }

    public function commandToggle(name: String
                                  , menu: String
                                  , shortcut: String
                                  , obs: Observable<Bool>
                                  , ?enabled: Observable<Bool>): Commands {
        var m = Menubar.get();
        m.add(menu, shortcut, true, function() {
                obs.set(!obs.get());
            });
        if(obs.get())
            m.on(menu);
        else
            m.off(menu);
        
        if(enabled != null) {
            if(enabled.get()) m.enable(menu);
            else m.disable(menu);

            enabled.listen(function(v, o) {
                    if(v) m.enable(menu);
                    else m.disable(menu);
                });
        }
        
        obs.listen(function(v, o) {
                if(v == o) return;
                if(v) m.on(menu);
                else m.off(menu);
            });

        _keys.set(shortcut, function() {
                trace('command $name');
                obs.set(!obs.get());
            });
        return this;
    }

    public function command(name: String
                            , menu: String
                            , shortcut: String
                            , action: Void -> Void): Commands {
        var m = Menubar.get();
        m.add(menu, shortcut, true, action);
        trace('registered', name, 'for', shortcut.charCodeAt(0));
        _keys.set(shortcut, function() {
                trace('command', name);
                action();
            });
        return this;
    }
}