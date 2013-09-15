package sakari.leveleditor.modes;

import sakari.leveleditor.Mode;
import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;
import flash.events.Event;
import flash.geom.Point;
import sakari.leveleditor.Editor;
import flash.Lib;

class AutoScroll extends Mode {
    var on: DisplayObjectContainer;
    var cameraScrollVector: Point;
    var camera: Observable<Point>;
    var lastUpdate = 0;
    var screen:  Observable<Point>;
    static var SPEED = 1000;
    static var THRESHOLD = 60;

    public function new(on: DisplayObjectContainer
                        , camera: Observable<Point>
                        , screen: Observable<Point>
                        ) {
        super();
        this.on = on;
        this.camera = camera;
        this.screen = screen;
        cameraScrollVector = new Point(0, 0);
    }
        
    public override function enable(): AutoScroll {
        if(enabled) return this;
        on.addEventListener(Event.ENTER_FRAME, scroll);
        super.enable();
        return this;
    }

    public override function disable(): AutoScroll {
        if(!enabled) return this;
        on.removeEventListener(Event.ENTER_FRAME, scroll);
        super.disable();
        return this;
    }

    private function scroll(m: Event) {
        var screenPoint = new Point(Lib.current.stage.mouseX
                                    , Lib.current.stage.mouseY);
        if(screenPoint.x < THRESHOLD) {
            cameraScrollVector.x = -SPEED * (THRESHOLD - screenPoint.x) / THRESHOLD;
        } else if(screenPoint.x > screen.get().x - THRESHOLD) {
            cameraScrollVector.x = SPEED * (screenPoint.x - (screen.get().x - THRESHOLD)) / THRESHOLD;
        } else {
            cameraScrollVector.x = 0;
        }  

        if(screenPoint.y < THRESHOLD) {
            cameraScrollVector.y = -SPEED * (THRESHOLD - screenPoint.y) / THRESHOLD;
        } else if(screenPoint.y > screen.get().y - THRESHOLD) {
            cameraScrollVector.y = SPEED * (screenPoint.y - (screen.get().y - THRESHOLD)) / THRESHOLD;
        } else {
            cameraScrollVector.y = 0;
        }

        if(cameraScrollVector.x == 0 && cameraScrollVector.y == 0) {
            lastUpdate = 0;
            return;
        }

        var now = Lib.getTimer();
        if(lastUpdate == 0) {
            lastUpdate = now;
            return;
        }
        camera.set(new Point(camera.get().x + cameraScrollVector.x * (now - lastUpdate) / 1000
                             , camera.get().y + cameraScrollVector.y * (now - lastUpdate) / 1000));
        lastUpdate = now;
    }
}