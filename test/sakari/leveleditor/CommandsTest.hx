package sakari.leveleditor;
using sakari.should.Should;
using sakari.should.openfl.Simulate;

import flash.display.Sprite;

class CommandsTest {
    var on: Sprite;
    var c: Commands;
    @BeforeClass function setupClass() {
        on = new Sprite();
        c = Commands.instance(on);
    }
    
    @Before function setup() {
        c.enable();
    }

    @After function teardown() {
        c.disable();
    }
    
    @Test function shortcut_keys_trigger_actions() {
        trace('shortcut action');
        var hit = 0;
        c.command('trigger action', 'Commands/Test/Trigger', 'a', function() {
                trace('got hit');
                hit++;
            });
        on.key().withCmd().down("a");
        hit.should().eql(1);
    }

    @Test function shortcut_keys_can_be_disabled() {
        trace('disable shortcut');
        var hit = 0;
        c.command('disable shortcuts', 'Commands/Test/Disable', 'b', function() {
                trace('got hit');
                hit++;
            });
        c.disable();
        on.key().withCmd().down("b");
        hit.should().eql(0);

        c.enable();
        on.key().withCmd().down("b");
        hit.should().eql(1);
    }
}