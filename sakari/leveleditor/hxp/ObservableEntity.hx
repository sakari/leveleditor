package sakari.leveleditor.hxp;
import com.haxepunk.Entity;
import sakari.leveleditor.Editor;

class ObservableEntity extends Entity {
    var listeners: Array<ObservableEntity -> Void>;
    public var def: EntityArguments;

    public function notifyChange() {
        for(i in listeners) {
            i(this);
        }
    }

    public function onChange(observer: ObservableEntity -> Void): ObservableEntity {
        listeners.push(observer);
        return this;
    }

    public function new(def: EntityArguments) {
        super();
        x = def.x;
        y = def.y;
        this.def = def;
        listeners = [];
    }

}
