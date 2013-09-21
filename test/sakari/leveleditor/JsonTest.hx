package sakari.leveleditor;
import sakari.leveleditor.Json;
using sakari.should.Should;

class JsonTest {
    @Test function it_parses_strings_to_dynamic() {
        var j = new Json().parse('{"foo": "bar" }');
        var bar: String = j.foo;
        bar.should().eql('bar');
    }

    @Test function it_stringifies_terminals() {
        new Json().stringify(1).should().eql('1');
        new Json().stringify(1.1).should().eql('1.1');
        new Json().stringify(true).should().eql('true');
        new Json().stringify('text').should().eql('"text"');
    }

    @Test function it_stringifies_arrays() {
        var str = new Json().stringify([1, 2]);
        str.should().eql('[\n    1,\n    2\n]');
    }

    @Test function it_stringifies_objects_alphabetically() {
        var str = new Json().stringify({ ab: 1, aa: "bar", ac: true });
        var exp = '{\n    "aa": "bar",\n    "ab": 1,\n    "ac": true\n}';
        str.should().eql(exp);
    }

    @Test function roundtrip() {
        var o = { foo: [{ bar: 1}] };
        var got = new Json().parse(new Json().stringify(o));
        var p: { foo: Array<{bar: Int}>} = got;
        p.foo[0].bar.should().eql(1);
    }
}