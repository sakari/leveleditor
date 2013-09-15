package sakari.leveleditor.modes;
import sakari.leveleditor.Mode;

class Single extends Mode{
    var modes: Array<Mode>;
    var enabledMode: Null<Int>;

    public function new() {
        super();
        modes = [];
    }

    public override function enable(): Single {
        if(enabledMode != null) {
            modes[enabledMode].enable();
        }
        super.enable();
        return this;
    }
    
    public function add(m: Mode): Single {
        var modeIndex = modes.length;
        if(m.enabled) {
            disable();
            enabledMode = modeIndex;
        }
        m.onEnable(function() {
                for(i in 0...modes.length) {
                    if(i != modeIndex) {
                        modes[i].disable();
                    }
                }
                enabledMode = modeIndex;
            });
        m.onDisable(function() {
                enabledMode = null;
            });
        modes.push(m);
        return this;
    }

    public override function disable(): Single {
        for(i in modes) {
            i.disable();
        }
        super.disable();
        return this;
    }
} 