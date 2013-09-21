package sakari.leveleditor;
using sakari.should.Should;

class ModeTest {
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
}