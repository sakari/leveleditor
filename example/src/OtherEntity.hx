import flash.geom.Point;
import com.haxepunk.graphics.Image;
import com.haxepunk.HXP;
import sakari.leveleditor.hxp.ObservableEntity;

class OtherEntity extends ObservableEntity {
    var speed: Point;

    public function new(def) {
        super(def);
        speed = new Point(0, 5 - Math.random() * 10);
        var i = new Image('graphics/test.png');
        addGraphic(i);
        setOrigin(Std.int(i.width / 2), Std.int(i.height / 2));
    }

    public override function update() {
        super.update();
        x += HXP.elapsed * speed.x;
        y += HXP.elapsed * speed.y;
        notifyChange();
    }
}