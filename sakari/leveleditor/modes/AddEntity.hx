package sakari.leveleditor.modes;
import flash.display.DisplayObjectContainer;
import flash.geom.Point;
import sakari.leveleditor.Editor;

class AddEntity extends Mode {
    var click: Click;
    var scroll: Drag;
    var _createEntity: EntityArguments -> Void;
    var _prefab: Observable<Editor.Prefab>;
    var _grids: String -> Tiler;

    private function add(x: Float, y: Float) {
        if(_prefab.get() == null) return;
        var t = _grids(_prefab.get().layer);
        var t_p = t.real(t.tile(new Point(x, y)));
        var e = {
        type: _prefab.get().type
        , x: t_p.x
        , y: t_p.y
        , id: 0
        , save: true
        , deleted: false
        , layer: _prefab.get().layer
        };
        _createEntity(e);
    }

    public function new(on
                        , camera: Observable<Point>
                        , prefab
                        , grids
                        , createEntity) {
        super();
        _grids = grids;
        _prefab = prefab;
        _createEntity = createEntity;
        click = new Click(on, function(x, y) {
                add(x + camera.get().x, y + camera.get().y);
            });
        scroll = new Drag(on, function(x, y) {
                var c = camera.get();
                camera.set(new Point(c.x - x, c.y - y));
            });
        click.iff(this);
        scroll.iff(this);
    }
}