package sakari.leveleditor;
import flash.geom.Point;
import flash.display.Sprite;
import flash.events.MouseEvent;
import sakari.leveleditor.Editor;

class Entity extends Sprite {
    public var bridge: EntityBridge;
    public var selected(get, set): Bool;
    var _selected: Bool;
    var _saved: EntityArguments;
    public var snapDelta: Point;
    public var saved(get, null): EntityArguments;

    public function get_saved() {
        return _saved;
    }

    public function save() {
        _saved.x = bridge.x.get();
        _saved.y = bridge.y.get();
        _saved.deleted = bridge.deleted.get();
    }

    public function get_selected(): Bool {
        return _selected;
    }

    public function set_selected(v: Bool): Bool {
        snapDelta.x = 0;
        snapDelta.y = 0;
        _selected = v;
        draw();
        return _selected;
    }

    public function delete() {
        if(bridge.deleted.get() == false)
            bridge.deleted.set(true);
        if(parent != null)
            parent.removeChild(this);
    }

    private function draw() {
        graphics.clear();
        graphics.beginFill(0, 0);
        if(selected) graphics.lineStyle(1, 0x00ff00);
        graphics.drawCircle(0, 0, 10);
    }

    public function new(e: EntityBridge) {
        snapDelta = new Point(0, 0);
        _saved = e.definition;
        super();
        selected = false;
        this.bridge = e;
        draw();
        x = e.x.get();
        y = e.y.get();
        e.x.listen(function(x, o) {
                this.x = x;
            });
        e.y.listen(function(y, o) {
                this.y = y;
            });
        e.deleted.listen(function(v, o) {
                if(v) delete();
            });
    }
}
