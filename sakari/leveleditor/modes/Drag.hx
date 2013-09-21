package sakari.leveleditor.modes;

import sakari.leveleditor.Mode;
import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;

class Drag extends Mode {
    var on: DisplayObjectContainer;
    var fn: Float -> Float -> Void;
    var startX: Float;
    var startY: Float;
    
    public function new(on: DisplayObjectContainer, fn: Float -> Float -> Void) {
        super();
        this.on = on;
        this.fn = fn;
        startX = 0;
        startY = 0;
        onEnable(function() {
                on.addEventListener(MouseEvent.MOUSE_DOWN, dragStart);
            });
        onDisable(function() {
                on.removeEventListener(MouseEvent.MOUSE_DOWN, dragStart);
                on.removeEventListener(MouseEvent.MOUSE_MOVE, dragMove);
                on.removeEventListener(MouseEvent.MOUSE_UP, dragStop);
            });
    }

    private function dragStart(m: MouseEvent) {
        startX = m.stageX;
        startY = m.stageY;
        on.addEventListener(MouseEvent.MOUSE_MOVE, dragMove);
        on.addEventListener(MouseEvent.MOUSE_UP, dragStop);
    }

    private function dragMove(m: MouseEvent) {
        fn(m.stageX - startX
           , m.stageY - startY);
        startX = m.stageX;
        startY = m.stageY;
    }

    private function dragStop(m: MouseEvent) {
        fn(m.stageX - startX
           ,  m.stageY - startY);
        on.removeEventListener(MouseEvent.MOUSE_MOVE, dragMove);
        on.removeEventListener(MouseEvent.MOUSE_UP, dragStop);
    }
}
