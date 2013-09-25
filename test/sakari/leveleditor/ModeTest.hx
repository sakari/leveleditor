package sakari.leveleditor;
using sakari.should.Should;
using sakari.should.openfl.Simulate;
import flash.display.Sprite;
import flash.events.KeyboardEvent;

class ModeTest {
    var on: Sprite;

    @Before function setup() {
        on = new Sprite();
    }
    
    @Test function it_starts_disabled() {
        new Mode().enabled.should().eql(false);
    }
    
    @Test function changing_state_notifies_listeners() {
        var enabled = 0;
        var disabled = 0;
        new Mode()
            .onEnable(function() {
                    enabled++;
                })
            .onDisable(function() {
                    disabled++;
                })
            .enable()
            .disable();

        enabled.should().eql(1);
        disabled.should().eql(1);
    }

    @Test function modes_manage_event_listeners() {
        var m = new Mode();
        var hits = 0;
        m.manageEvent(on
                      , KeyboardEvent.KEY_DOWN
                      , function(e: KeyboardEvent) {
                          hits++;
                      });
        m.disable();
        on.key().down('a');
        hits.should().eql(0);
        m.enable();
        on.key().down('a');
        hits.should().eql(1);
    }
}