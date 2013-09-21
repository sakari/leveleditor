package sakari.leveleditor;
import flash.display.Sprite;
import sakari.leveleditor.modes.AddEntity;
import flash.geom.Point;

using sakari.should.openfl.Simulate;
using sakari.should.Should;
import sakari.should.Should;

class AddEntityTest {
    var add: AddEntity;
    var layer: Sprite;
    var camera: Observable<Point>;
    var got: Editor.EntityArguments;
    var prefab: Observable<Editor.Prefab>;

    function tiler(s: String): Tiler {
        if(s == 'tiled') 
            return new Tiler.Tiled(new Point(10, 0)
                                   , new Point(0, 10));
        return new Tiler.FreeHand();
    }

    @Before function setup() {
        got = null;
        var p: Editor.Prefab = { type: 'entity' };
        prefab = new Observable(p);
        camera = new Observable(new Point(1, 2));
        layer = new Sprite();
        add = new AddEntity(layer
                            , camera
                            , prefab
                            , tiler
                            , function(e: Editor.EntityArguments) {
                                got = e;
                            });
    }

    @Test function no_entity_is_created_if_no_prefab_is_selected() {
        prefab.set(null);
        add.enable();
        layer.click(10, 20);
        Should.should(got).eql(null);
    }

    @Test function entity_type_is_set_from_prefab() {
        add.enable();
        layer.click(10, 20);
        got.type.should().eql('entity');
    }

    @Test function entity_coordinates_can_be_fitted_to_grid() {
        prefab.set({ type: 'entity', layer: 'tiled' });
        add.enable();
        layer.click(8, 9);
        got.x.should().eql(10);
        got.y.should().eql(10);
    }

    @Test function click_provides_coordinates_in_world() {
        add.enable();
        layer.click(10, 20);
        got.x.should().eql(1 + 10);
        got.y.should().eql(2 + 20);
    }

    @Test function multiple_entities_can_be_added() {
        add.enable();
        layer.click(10, 20);
        layer.click(0, 0);
        got.x.should().eql(1);
        got.y.should().eql(2);
    }

    @Test function camera_can_be_dragged() {
        add.enable();
        layer.drag(5, 5).to(10, 15);
        camera.get().x.should().eql(1 - (10 - 5) );
        camera.get().y.should().eql(2 - (15 - 5) );
    }
}