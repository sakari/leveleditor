package sakari.leveleditor.modes;
import sakari.leveleditor.Mode;
import sakari.leveleditor.Editor;
import sakari.leveleditor.modes.Drag;
import flash.geom.Point;
import flash.Lib;

class Camera extends Mode {
    var drag: Drag;
    var camera: Observable<Point>;

    public function new(camera: Observable<Point>) {
        super();
        this.camera = camera;
        drag = new Drag(Lib.current.stage
                        , function(x, y) {
                            var c = camera.get();
                            camera.set(new Point(c.x + x, c.y + y));
                        });
    }

    public override function enable() {
        drag.enable();
        super.enable();
        return this;
    }

    public override function disable() {
        drag.disable();
        super.disable();
        return this;
    }
}
