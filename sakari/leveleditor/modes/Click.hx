package sakari.leveleditor.modes;

import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;
import sakari.leveleditor.Mode;

class Click extends Mode {
    var on: DisplayObjectContainer;
    var fn: Float -> Float -> Void;
    var isClick: Bool;
    
    public function new(on: DisplayObjectContainer, fn: Float -> Float -> Void) {
        super();
        this.on = on;
        this.fn = fn;
    }

    public override function enable(): Click {
        if(enabled) return this;
        on.addEventListener(MouseEvent.MOUSE_DOWN, click);
        super.enable();
        return this;
    }
    
    private function notClick(m: MouseEvent) {
        isClick = false;
    }
    
    private function click(d: MouseEvent) {
        isClick = true;
        on.addEventListener(MouseEvent.MOUSE_MOVE, notClick);
        on.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
    }

    private function mouseUp(m: MouseEvent) {
        if(isClick)
            fn(m.stageX, m.stageY);
        on.removeEventListener(MouseEvent.MOUSE_MOVE, notClick);
        on.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
    }

    public override function disable(): Click {
        if(!enabled) return this;
        on.removeEventListener(MouseEvent.MOUSE_DOWN, click);
        on.removeEventListener(MouseEvent.MOUSE_MOVE, notClick);
        on.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
        super.disable();
        return this;
    }
}

