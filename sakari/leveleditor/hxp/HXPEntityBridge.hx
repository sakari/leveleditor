package sakari.leveleditor.hxp;

import sakari.leveleditor.Editor;
import com.haxepunk.HXP;

class HXPEntityBridge implements EntityBridge{
    var e: ObservableEntity;
    public var x: Observable<Float>;
    public var y: Observable<Float>;
    public var deleted: Observable<Bool>;
    public var definition: EntityArguments;

    public function new(e: ObservableEntity) {
        definition = e.def;
        this.e = e;
        this.x = new Observable(e.x + e.originX);
        this.y = new Observable(e.y + e.originY);
        this.deleted = new Observable(false);

        this.e.onChange(function(t) {
                this.x.set(e.x + e.originX);
                this.y.set(e.y + e.originY);
            });
        this.x.listen(function(x, o) {
                if(x == this.e.x + e.originX) return;
                this.e.x = x - e.originX;
                HXP.engine.render();
            });
        this.y.listen(function(y, o) {
                if(y == this.e.y + e.originY) return;
                this.e.y = y - e.originY;
                HXP.engine.render();
            });
        this.deleted.listen(function(v, o) {
                if(!v) return;
                e.scene.remove(e);
                HXP.engine.update();
                HXP.engine.render();
            });
    }
}
