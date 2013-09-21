package sakari.leveleditor;

import sakari.leveleditor.Editor;
import sakari.leveleditor.LoadedScene;
import mocks.sys.io.Fs;
import flash.display.Sprite;
import flash.geom.Point;
using sakari.should.Should;

class TestSceneBridge implements Editor.SceneBridge {
    public var onAddEntity: EventEmitter<Editor.EntityBridge>;
    public var onBegin: EventEmitter<Sprite>;
    var scene: JsonScene;

    public function new(json: JsonScene) {
        scene = json;
        onAddEntity = new EventEmitter();
        onBegin = new EventEmitter();
    }

    public function load() {
        scene.entities.map(function(e) {
                onAddEntity.emit(new TestEntityBridge(e));
            });
    }
}

class LoadedSceneTest {
    var loadedScene: LoadedScene;
    var paused: Observable<Bool>;
    var bridge: TestSceneBridge;
    static var PATH = "path";
    var savePath: String;
    var openPath: String;
    var scene: JsonScene;
    var emptyScene: JsonScene;

    @Before function setup() {
        Fs.clean();
        savePath = null;
        openPath = PATH;
        paused = new Observable(true);
        bridge = null;
        emptyScene = { layers: [], grids: [], entities: []};
        loadedScene = new LoadedScene(function(json) {
                bridge = new TestSceneBridge(json);
                return bridge;
            }, paused
            , function(cb: String -> Void): Void {
                cb(savePath);
            }, function(cb: String -> Void): Void {
                cb(openPath);
            });
        scene = { layers: [ { name: 'layer' }, 
            { name: 'tiledLayer', grid: 'tiled'}]
                  , grids: [{ name: 'tiled', 
                              x: {x: 10, y: 0}, 
                              y: { x: 0, y: 10}}]
                  , entities: [{x: 1, y: 1
                                , save: true
                                , deleted: false
                                , id: 0
                                , type: 'some'
                                , layer: 'layer' }] };
        Fs.write(PATH, new Json().stringify(scene));
    }

    @Test function new_scene_can_be_saved() {
        loadedScene.newScene();
        savePath = "saved";
        loadedScene.save();
        Fs.read("saved").should().eql(new Json()
                                      .stringify(emptyScene));
    }

    @Test function new_scene_empties_the_current_file_setting() {
        loadedScene.load();
        loadedScene.newScene();
        savePath = 'newpath';
        loadedScene.save();
        Fs.read('newpath').should().eql(new Json().stringify(emptyScene));
    }

    @Test function new_scene_saving_can_be_cancelled() {
        loadedScene.newScene();
        savePath = null;
        loadedScene.save();
    }

    @Test function scene_can_be_saved_as() {
        loadedScene.load();
        savePath = 'newPath';
        loadedScene.saveAs();
        Fs.read(PATH).should().eql(new Json()
                                   .stringify(scene));
    }

    @Test function saving_as_sets_the_current_filename() {
        loadedScene.load();
        savePath = 'newPath';
        loadedScene.saveAs();
        Fs.clean();
        loadedScene.save();
        Fs.read('newPath').should().eql(new Json()
                                        .stringify(scene));
    }

    @Test function loaded_scene_can_be_saved() {
        loadedScene.load();
        Fs.clean();
        loadedScene.save();
        var json = Fs.read(PATH);
        Fs.read(PATH).should().eql(new Json()
                                   .stringify(scene));
    }

    @Test function dynamic_entities_are_not_saved() {
        loadedScene.load();
        bridge.onAddEntity.emit(new TestEntityBridge({
                layer: 'layer', x: 1, y: 1, type: 'a', save: false, deleted: false, id: 1
                        }));
        loadedScene.save();
        Fs.read(PATH).should().eql(new Json()
                                   .stringify(scene));
    }

    @Test function entities_added_from_the_editor_are_saved() {
        loadedScene.load();
        var e = {layer: 'layer', x: 1.0, y: 1.0, type: 'a', save: true, deleted: false, id: 1 };
        bridge.onAddEntity.emit(new TestEntityBridge(e));
        loadedScene.save();
        scene.entities.push(e);
        Fs.read(PATH).should().eql(new Json()
                                   .stringify(scene));
    }

    @Test function deleted_entities_are_not_saved() {
        loadedScene.load();
        var e = {layer: 'layer', x: 1.0, y: 1.0, type: 'a', save: true, deleted: true, id: 1 };
        bridge.onAddEntity.emit(new TestEntityBridge(e));
        loadedScene.save();
        Fs.read(PATH).should().eql(new Json()
                                   .stringify(scene));
    }

    @Test function on_load_scene_tells_which_entities_have_been_added() {
        var called = 0;
        loadedScene.onAddEntity.call(function(e) {
                called++;
            });
        loadedScene.load();
        called.should().eql(1);
    }

    @Test function loading_a_scene_pauses_game_engine() {
        var c = 0;
        paused.listen(function(n, o) {
                n.should().eql(true);
                c++;
            });
        loadedScene.load();
        c.should().eql(1);
    }

    @Test function null_layer_returns_default_tiler() {
        loadedScene.load();
        loadedScene.tiler(null).tile(new Point(12.1, 0)).x
            .should().eql(12.1);
    }

    @Test function layers_without_tilers_return_freehand_tiler() {
        loadedScene.load();
        loadedScene.tiler('layer').tile(new Point(12.1, 0)).x
            .should().eql(12.1);
    }

    @Test function layers_with_tilers_return_tiled_tilers() {
        loadedScene.load();
        loadedScene.tiler('tiledLayer').tile(new Point(10, 10)).x
            .should().eql(1);
    }
}