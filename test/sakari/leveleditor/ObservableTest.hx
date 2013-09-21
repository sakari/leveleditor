package sakari.leveleditor;

import sakari.leveleditor.Observable;
using sakari.should.Should;

class ObservableTest {
    @Test function listeners_are_notified_of_sets() {
        var o = new Observable(1);
        o.listen(function(n, o) {
                o.should().eql(1);
                n.should().eql(2);
            });
        o.set(2);
    }

    @Test function observable_values_can_be_got() {
        var o = new Observable(1);
        o.get().should().eql(1);
    }
}
