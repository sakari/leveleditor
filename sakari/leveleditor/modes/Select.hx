package sakari.leveleditor.modes;
import sakari.leveleditor.Mode;
import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.geom.Point;
import sakari.leveleditor.Entity;
import sakari.leveleditor.Editor;
using Lambda;

class Select extends Mode {
    var on: DisplayObjectContainer;
    var selected: Array<Entity>;
    var dragStart: Point;
    static var BACKSPACE = 8;
    var camera: Observable<Point>;
    var dragScroll: Drag;
    var autoScroll: AutoScroll;
    var scrollMode: Single; 

    public function new(on: DisplayObjectContainer
                        , camera: Observable<Point>
                        , screen: Observable<Point>) {
        super();
        this.camera = camera;
        selected = [];
        this.on = on;
        autoScroll = new AutoScroll(on, camera, screen);
        dragScroll = new Drag(on, function(x, y) {
                var c = camera.get();
                camera.set(new Point(c.x - x, c.y - y));
            });
        scrollMode = new Single()
            .add(autoScroll)
            .add(dragScroll);
    }

    public override function enable() {
        on.addEventListener(MouseEvent.MOUSE_DOWN, selectEntity);
        on.addEventListener(KeyboardEvent.KEY_DOWN, deleteSelection);
        dragScroll.enable();
        super.enable();
        return this;
    }

    private function selectEntity(m: MouseEvent) {
        for(i in selected) {
            i.selected = false;
        }

        selected = on.getObjectsUnderPoint(new Point(m.stageX, m.stageY))
            .filter(function(e) {
                    return Type.getClass(e) == Entity;
                })
            .map(function(e) {
                    var e = cast(e, Entity);
                    e.selected = true;
                    return e;
                });
        if(selected.length > 0) {
            autoScroll.enable();
        }
        dragStart = new Point(camera.get().x + on.mouseX
                              , camera.get().y + on.mouseY);
        on.addEventListener(Event.ENTER_FRAME, moveSelected);
        on.addEventListener(MouseEvent.MOUSE_UP, moveStop);
    }

    private function moveSelected(e: Event) {        
        var c = camera.get();
        var x = on.mouseX + c.x;
        var y = on.mouseY + c.y;
        selected.map(function(e) {
                e.bridge.x.set(e.bridge.x.get() + x - dragStart.x);
                e.bridge.y.set(e.bridge.y.get() + y - dragStart.y);
                e.save();
            });
        dragStart.x = x;
        dragStart.y = y;
    }

    private function deleteSelection(k: Dynamic) {
        if(k.charCode != BACKSPACE) return;
        selected.map(function(e) {
                e.delete();
                e.save();
            });
        selected = [];
    }

    private function moveStop(m: MouseEvent) {
        dragScroll.enable();
        on.removeEventListener(Event.ENTER_FRAME, moveSelected);
        on.removeEventListener(MouseEvent.MOUSE_UP, moveStop);
    }

    public override function disable() {
        on.removeEventListener(KeyboardEvent.KEY_DOWN, deleteSelection);
        on.removeEventListener(MouseEvent.MOUSE_DOWN, selectEntity);
        on.removeEventListener(Event.ENTER_FRAME, moveSelected);
        on.removeEventListener(MouseEvent.MOUSE_UP, moveStop);
        scrollMode.disable();
        super.disable();
        return this;
    }
}