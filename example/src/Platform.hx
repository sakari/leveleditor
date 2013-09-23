import flash.geom.Point;
import com.haxepunk.graphics.Image;
import com.haxepunk.HXP;
import sakari.leveleditor.hxp.ObservableEntity;

class Platform extends ObservableEntity {
    var speed: Point;

    public function new(def) {
        super(def);
        var i = new Image('graphics/platform.png');
        addGraphic(i);
        x = def.x - i.width / 2;
        y = def.y - i.height / 2;
        setOrigin(Std.int(i.width / 2), Std.int(i.height / 2));
        width = i.width;
        height = i.height;
        type = "platform";
        layer = 1;
    }
}