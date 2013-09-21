package sakari.leveleditor;

import sakari.leveleditor.Editor;

class TestEntityBridge implements Editor.EntityBridge {
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
