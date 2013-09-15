import flash.geom.Point;
import com.haxepunk.graphics.Image;
import com.haxepunk.HXP;
import sakari.leveleditor.hxp.ObservableEntity;

class SomeEntity extends ObservableEntity {
    var speed: Point;

    public function new(x, y) {
        super();
        speed = new Point(5 - Math.random() * 10, 0);
        var i = new Image('graphics/test.png');
        this.x = x;
        this.y = y;
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
