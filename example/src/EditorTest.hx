import sakari.leveleditor.Editor;
import sakari.leveleditor.hxp.EditorEngine;
import flash.geom.Point;
import sakari.leveleditor.hxp.ObservableEntity;

class EditorTest extends EditorEngine {
    public override function entities(): Array<Prefab> {
        return [
                {type: 'some', icon: null }
                , {type: 'other', icon: null, layer: 'tiled' }
                ];
    }

    public override function entityFactory(p) {
        var e: ObservableEntity;
        if(p.type == 'some')
            e = new SomeEntity(p);
        else
            e = new OtherEntity(p);
        return e;
    }

    public static function main() { new EditorTest(); }
}