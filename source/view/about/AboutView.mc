using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class AboutView extends BaseView {
    
    function initialize(serviceLocator) {
        BaseView.initialize();
    }

    function onLayout(dc) {
        View.setLayout(Rez.Layouts.about(dc));
        var aboutText = View.findDrawableById("about_text");
        var textTemplate = Application.loadResource(Rez.Strings.about_text_template);
        var appName = Application.loadResource(Rez.Strings.app_name);
        var appVersion = Application.loadResource(Rez.Strings.app_version);
        aboutText.setText(Lang.format(textTemplate, [appName, appVersion]));
    }
}
