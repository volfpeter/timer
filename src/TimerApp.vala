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
            application_id: "com.github.volfpeter.timer",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate() {
        var main_window = new Gtk.ApplicationWindow(this);

        this._set_window_properties(main_window);
        this._add_main_view(main_window);
        this._set_custom_actions(main_window);

        main_window.show_all();
    }

    private void _add_main_view(Gtk.ApplicationWindow window) {
        var hours_entry = this._create_spin_button(0, 99);
        var minutes_entry = this._create_spin_button(0, 59);
        minutes_entry.wrapped.connect(() => {
            if (minutes_entry.value == 0) {
                // Wrapped in the positive direction.
                hours_entry.spin(Gtk.SpinType.STEP_FORWARD, 1);
            } else {
                // Wrapped in the negative direction.
                if (hours_entry.value == 0) {
                    minutes_entry.value = 0;
                } else {
                    hours_entry.spin(Gtk.SpinType.STEP_BACKWARD, 1);
                }
            }
        });
        var seconds_entry = this._create_spin_button(0, 59);
        seconds_entry.wrapped.connect(() => {
            if (seconds_entry.value == 0) {
                // Wrapped in the positive direction.
                minutes_entry.spin(Gtk.SpinType.STEP_FORWARD, 1);
            } else {
                // Wrapped in the negative direction.
                if (hours_entry.value == 0 && minutes_entry.value == 0) {
                    seconds_entry.value = 0;
                } else {
                    minutes_entry.spin(Gtk.SpinType.STEP_BACKWARD, 1);
                }
            }
        });

        var message_entry = new Gtk.Entry();
        message_entry.placeholder_text = _("Timer completed!");

        var clock_button = new Gtk.Button.from_icon_name("tools-timer-symbolic");
        var start_button = new Gtk.Button.from_icon_name("media-playback-start-symbolic");
        start_button.clicked.connect(() => {
            var notification = new Notification(_("Timer completed"));
            notification.set_body(message_entry.text != "" ? message_entry.text : _("The timer you set has completed."));
            notification.set_icon(new GLib.ThemedIcon("appointment"));
            this.send_notification("com.github.volfpeter.timer", notification);
        });
        var pause_button = new Gtk.Button.from_icon_name("media-playback-pause-symbolic");
        var reset_button = new Gtk.Button.from_icon_name("edit-undo-symbolic");

        var top_row = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 6);
        top_row.homogeneous = true;
        top_row.add(hours_entry);
        top_row.add(minutes_entry);
        top_row.add(seconds_entry);

        var bottom_row = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 6);
        bottom_row.homogeneous = true;
        bottom_row.add(clock_button);
        bottom_row.add(start_button);
        bottom_row.add(pause_button);
        bottom_row.add(reset_button);

        var column = new Gtk.Box(Gtk.Orientation.VERTICAL, 6);
        column.margin = 6;
        column.add(top_row);
        column.add(bottom_row);
        column.add(message_entry);

        window.add(column);
    }

    private Gtk.SpinButton _create_spin_button(int min, int max) {
        var button = new Gtk.SpinButton.with_range(min, max, 1);
        button.snap_to_ticks = true;
        button.wrap = true;
        return button;
    }

    private void _set_custom_actions(Gtk.ApplicationWindow window) {
        // -- Quit on Control + Q
        var quit_action = new SimpleAction("quit", null);
        quit_action.activate.connect(() => {
            if (window != null) {
                window.destroy();
            }
        });
        this.add_action(quit_action);
        this.set_accels_for_action("app.quit", {"<Control>q"});

    }

    private void _set_window_properties(Gtk.ApplicationWindow window) {
        window.title = "Timer";
    }

    public static int main(string[] args) {
        var app = new MyApp();
        return app.run(args);
    }
}
