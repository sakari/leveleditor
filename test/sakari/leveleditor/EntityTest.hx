package sakari.leveleditor;
import sakari.leveleditor.Entity;
import sakari.leveleditor.Editor;
import flash.display.Sprite;
using sakari.should.Should;

class TestEntityBridge implements EntityBridge {
    public var x: Observable<Float>;
    public var y: Observable<Float>;
    public var deleted: Observable<Bool>;
    public var definition: EntityArguments;

    public function new(e: EntityArguments) {
        x = new Observable(e.x);
        y = new Observable(e.y);
        deleted = new Observable(false);
        definition = e;
    }
}

class EntityTest {
    var b: EntityBridge;
    var e: Entity;

    @Before 
    function setup() {
        b = new TestEntityBridge({ x : 0.0
                                   , y: 0.0
                                   , type: 'some'
                                   , id: 0
                                   , save: true
                                   , deleted: false
            });
        e = new Entity(b);
    }
    
    @Test function entities_have_saved_state() {
        e.saved.x.should().eql(0);
    }

    @Test function entity_coordinates_mirror_the_bridge_coordinates() {
        b.x.set(2);
        e.x.should().eql(2);
    }
    
    @Test function entity_saved_state_does_not_change_until_save_is_called() {
        b.x.set(2);
        e.saved.x.should().eql(0);
        e.save();
        e.saved.x.should().eql(2);
    }

    @Test function entity_deletion_is_mirrored_to_bridge() {
        e.delete();
        b.deleted.get().should().eql(true);
    }
    
    @Test function if_entity_is_deleted_it_is_removed_from_parent() {
        var p = new Sprite();
        p.addChild(e);
        p.numChildren.should().eql(1);
        e.delete();
        p.numChildren.should().eql(0);
    }

    @Test function entity_saved_deletion_state_is_set_on_save() {
        e.delete();
        e.saved.deleted.should().eql(false);
        e.save();
        e.saved.deleted.should().eql(true);
    }
}