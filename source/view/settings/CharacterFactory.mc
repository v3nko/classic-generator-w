import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class CharacterFactory extends WatchUi.PickerFactory {
    private var roster as Array;

    public function initialize(characterSet as Array) {
        PickerFactory.initialize();
        roster = characterSet;
    }

    public function getSize() as Number {
        return roster.size();
    }

    public function getValue(index as Number) as Object? {
        return roster[index];
    }

    public function getDrawable(index as Number, selected as Boolean) as Drawable? {
        return new WatchUi.Text(
            {
                :text => getValue(index).toString(),
                :color => Graphics.COLOR_WHITE,
                :font => Graphics.FONT_LARGE,
                :locX => WatchUi.LAYOUT_HALIGN_CENTER,
                :locY => WatchUi.LAYOUT_VALIGN_CENTER
            }
        );
    }
}
