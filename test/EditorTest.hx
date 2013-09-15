package;
import massive.munit.util.Timer;
import massive.munit.async.AsyncFactory;
import com.haxepunk.HXP;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.Scene;
import com.haxepunk.Engine;
import flash.events.Event;
import flash.geom.Point;
import flash.display.Sprite;
import flash.Lib;

class S extends Scene {
    public override function begin() {
        super.begin();
        var entity = new Entity();
        var i = new Image('fixtures/entity.png');
        entity.addGraphic(i); // <-------------------- comment this to prevent crash
        entity.x = 10;
        entity.y = 10;
        add(entity);
        trace('scene ready');
    }
}
class E extends Engine {
    public override function init() {
        super.init();
        var scene = new S();
        HXP.scene = scene;
        trace('engine inited');
    }
}

class EditorTest {
    @Test
    public function minimal_crash_test() {
        var engine = new E();
        engine.dispatchEvent(new Event(Event.ENTER_FRAME)); // <------ or this
        trace(Lib.current.stage.getObjectsUnderPoint(new Point(10, 10)));
    }
}