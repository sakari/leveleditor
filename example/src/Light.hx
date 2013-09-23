import flash.geom.Point;
import com.haxepunk.graphics.Image;
import com.haxepunk.HXP;
import sakari.leveleditor.hxp.ObservableEntity;

class Light extends ObservableEntity {
    public function new(def) {
        super(def);
        var i = new Image('graphics/light.png');
        addGraphic(i);
        x = def.x - i.width / 2;
        y = def.y - i.height / 2;
        type = "light";
        layer = 1;
        setHitbox(i.width
                  , i.height
                  , Std.int(i.width / 2)
                  , Std.int(i.height / 2));
    }
}