/*
* Copyright (c) 2011-2018 Peter Volf (https://github.com/volfpeter)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Peter Volf <do.volfp@gmail.com>
*/

public class MyApp : Gtk.Application {

    public MyApp () {
        Object (
            application_id: "com.github.yourusername.yourrepositoryname",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate() {
        var main_window = new Gtk.ApplicationWindow(this);

        this._set_window_properties(main_window);
        this._add_main_window_content(main_window);

        main_window.show_all();
    }

    private void _add_main_window_content(Gtk.ApplicationWindow window) {
        window.add(this._create_hellow_world_button());
    }

    private Gtk.Button _create_hellow_world_button() {
        var button = new Gtk.Button.with_label("Click here!");
        button.margin = 12;
        button.clicked.connect(() => {
            button.label = "Heló World!";
            button.sensitive = false;
        });
        return button;
    }

    private void _set_window_properties(Gtk.ApplicationWindow window) {
        window.default_height = 200;
        window.default_width = 300;
        window.title = "Hello World";
    }

    public static int main(string[] args) {
        var app = new MyApp();
        return app.run (args);
    }
}
