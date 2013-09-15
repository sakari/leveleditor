package;

import sakari.leveleditor.hxp.EditorEngine;
import sakari.menubar.Menubar;
import mocks.sakari.filepicker.Save;
import mocks.sakari.filepicker.Open;
import mocks.sys.io.Fs;
import haxe.Json;
import massive.munit.util.Timer;
import massive.munit.async.AsyncFactory;
import flash.display.BitmapData;
import flash.Lib;
import openfl.Assets;
import com.haxepunk.graphics.Image;
import sakari.leveleditor.hxp.ObservableEntity;
import flash.events.Event;
import flash.events.MouseEvent;

using sakari.should.Should;
using sakari.should.openfl.Should;

class En extends ObservableEntity {
    public function new(x, y) {
        super();
        this.x = x;
        this.y = y;
        var i = new Image('fixtures/entity.png');
        addGraphic(i);
        setOrigin(Std.int(i.width / 2), Std.int(i.height / 2));
    }
}

class Ed extends EditorEngine {
    public override function entities() {
        return [{ type: 'entity', icon: null}];
    }
    public override function entityFactory(e) {
        return new En(e.x, e.y);
    }
}

class Drag {
    private function new() {
    }
        
    static public function from(x, y) {
        var e = new MouseEvent(MouseEvent.MOUSE_DOWN);
        e.stageX = x;
        e.stageY = y;
        Lib.current.stage.dispatchEvent(e);
        return new Drag();
    }

    public function to(x, y) {
        var e = new MouseEvent(MouseEvent.MOUSE_MOVE);
        e.stageX = x;
        e.stageY = y;
        Lib.current.stage.dispatchEvent(e);
        return this;
    }

    public function andDrop(x, y) {
        var e = new MouseEvent(MouseEvent.MOUSE_UP);
        e.stageX = x;
        e.stageY = y;
        Lib.current.stage.dispatchEvent(e);
    }
}

class EditorTest {
    var e: EditorEngine;

    function newScene() {
        Menubar.get().click('File/New');
        e.dispatchEvent(new Event(Event.ENTER_FRAME));
    }

    function saveSceneAs(path) {
        Menubar.get().click('File/Save As');
        Save.get().select(path);
    }
    
    function openScene(path) {
        Menubar.get().click('File/Open');
        Open.get().select(path == null ? [] : [path]);
        e.dispatchEvent(new Event(Event.ENTER_FRAME));
    }

    function givenAddEntityModeIsOff() {
        Menubar.get().click('Edit/Add Entity');
    }

    function thenLoadedSceneIsVisible() {
        e.should()
            .matchBitmap(Assets
                         .getBitmapData('fixtures/load_scene.png'));
    }
    
    function givenALoadedScene() {
        var j = Json.stringify({entities: [
            {type: 'entity', x: 0, y: 0 }
            , {type: 'entity', x: 10, y: 20 }
                                           ]});
        Fs.write('foo.json', j);
        openScene('foo.json');
    }
    
    function givenGameIsPaused() {
        Menubar.get().click('Edit/Pause');
    }

    function givenAddEntityModeIsOn() {
        Menubar.get().click('Edit/Pause')
            .click('Edit/Add Entity')
            .click('Prefab/entity');
    }

    function addEntity(x, y) {
        var e = new MouseEvent(MouseEvent.MOUSE_DOWN);
        e.stageX = x;
        e.stageY = y;
        Lib.current.stage.dispatchEvent(e);

        e = new MouseEvent(MouseEvent.MOUSE_UP);
        e.stageX = x;
        e.stageY = y;

        Lib.current.stage.dispatchEvent(e);
    }

    @BeforeClass
    public function createEngine() {
        e = new Ed();
    }

    @Before
    public function cleanEngine() {
        e.editor.resetMode();
        Fs.clean();
        newScene();
    }

    @Test
    public function test_editor_can_be_created() {
        e.should().exist;
    }

    @Test
    public function editor_can_load_a_scene() {
        givenALoadedScene();
        thenLoadedSceneIsVisible();
    }

    @Test
    public function editor_can_cancel_scene_open() {
        givenALoadedScene();
        openScene(null);
        thenLoadedSceneIsVisible();
    }

    @Test
    public function editor_can_cancel_scene_save_as() {
        givenALoadedScene();
        saveSceneAs(null);
        thenLoadedSceneIsVisible();
    }

    @Test
    public function editor_can_cancel_scene_save_as_when_no_loaded_scene() {
        saveSceneAs(null);
    }

    @Test
    public function editor_can_save_a_scene() {
        saveSceneAs('foo.json');
        Fs.read('foo.json').should().eql('{"entities":[]}');
    }

    @Test
    public function entity_can_be_added_to_scene() {
        givenAddEntityModeIsOn();
        addEntity(0, 0);
        addEntity(50, 60);
        e.should()
            .matchBitmap(Assets
                         .getBitmapData('fixtures/add_entities.png'));
    }

    @skipTest
    public function entities_can_be_dragged() {
        givenAddEntityModeIsOn();
        addEntity(0, 0);
        addEntity(50, 60);
        givenAddEntityModeIsOff();
        Drag.from(150, 160).to(0, 30).andDrop(0, 30);
        e.should()
            .matchBitmap(Assets
                         .getBitmapData('fixtures/add_entities.png'));
    }
}