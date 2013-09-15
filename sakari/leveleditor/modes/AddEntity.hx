package sakari.leveleditor.modes;
import flash.display.DisplayObjectContainer;
import flash.geom.Point;
import sakari.leveleditor.Editor;

class AddEntity extends Mode {
    var click: Click;
    var scroll: Drag;

    public function new(on: DisplayObjectContainer
                        , camera: Observable<Point>
                        , add: Float -> Float -> Void) {
        super();
        click = new Click(on, add);
        scroll = new Drag(on, function(x, y) {
                var c = camera.get();
                camera.set(new Point(c.x - x, c.y - y));
            });
    }

    public override function enable(): AddEntity {
        if(enabled) return this;
        super.enable();
        click.enable();
        scroll.enable();
        return this;
    }

    public override function disable(): AddEntity {
        if(!enabled) return this;
        super.disable();
        click.disable();
        scroll.disable();
        return this;
    }
}