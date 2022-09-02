import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class CharacterFactory extends WatchUi.PickerFactory {
    private var roster as String;

    public function initialize(characterSet as String) {
        PickerFactory.initialize();
        roster = characterSet;
    }

    public function getIndex(value as String) as Number {
        return roster.find(value);
    }

    public function getSize() as Number {
        return roster.length();
    }

    public function getValue(index as Number) as Object? {
        return roster.substring(index, index + 1);
    }

    public function getDrawable(index as Number, selected as Boolean) as Drawable? {
        return new WatchUi.Text(
            {
                :text => getValue(index) as String,
                :color => Graphics.COLOR_WHITE,
                :font => Graphics.FONT_LARGE,
                :locX => WatchUi.LAYOUT_HALIGN_CENTER,
                :locY => WatchUi.LAYOUT_VALIGN_CENTER
            }
        );
    }
}
