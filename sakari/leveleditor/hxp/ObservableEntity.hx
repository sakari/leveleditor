package sakari.leveleditor.hxp;
import com.haxepunk.Entity;

class ObservableEntity extends Entity {
    var listeners: Array<ObservableEntity -> Void>;

    public function notifyChange() {
        for(i in listeners) {
            i(this);
        }
    }

    public function onChange(observer: ObservableEntity -> Void): ObservableEntity {
        listeners.push(observer);
        return this;
    }

    public function new() {
        super();
        listeners = [];
    }

}
