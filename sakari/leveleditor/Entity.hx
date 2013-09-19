package sakari.leveleditor;
import flash.display.Sprite;
import flash.events.MouseEvent;
import sakari.leveleditor.Editor;

class Entity extends Sprite {
    public var bridge: EntityBridge;
    public var selected(get, set): Bool;
    var _selected: Bool;

    public function get_selected(): Bool {
        return _selected;
    }

    public function set_selected(v: Bool): Bool {
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
        else graphics.lineStyle(1, 0x0000ff);
        graphics.drawCircle(0, 0, 10);
    }

    public function new(e: EntityBridge) {
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
