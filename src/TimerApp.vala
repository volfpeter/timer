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
        var main_window = new MainWindow(this);
        this.set_custom_actions(main_window);
        main_window.show_all();
    }

    private void set_custom_actions(Gtk.ApplicationWindow window) {
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

    public static int main(string[] args) {
        var app = new MyApp();
        return app.run(args);
    }
}

private class MainWindow : Gtk.ApplicationWindow {

    private TimerRow timer_row;
    private ControlRow control_row;
    private Gtk.Entry message_entry;

    public MainWindow(Gtk.Application application) {
        Object(
            application: application,
            title: _("Timer")
        );
    }

    construct {
        timer_row = new TimerRow();
        timer_row.timer_completed.connect(send_notification);

        control_row = new ControlRow();

        message_entry = new Gtk.Entry();
        message_entry.placeholder_text = _("Timer completed!");

        var column = new Gtk.Box(Gtk.Orientation.VERTICAL, 6);
        column.margin = 6;
        column.add(timer_row);
        column.add(control_row);
        column.add(message_entry);

        add(column);
    }

    private void send_notification() {
        var notification = new Notification(_("Timer completed"));
        notification.set_body(message_entry.text != "" ? message_entry.text : _("The timer you set has completed."));
        notification.set_icon(new GLib.ThemedIcon("appointment"));
        application.send_notification("com.github.volfpeter.timer", notification);
    }
}

private class TimerRow : Gtk.Box {

    private Gtk.SpinButton hours_entry;
    private Gtk.SpinButton minutes_entry;
    private Gtk.SpinButton seconds_entry;

    public TimerRow() {
        Object(
            orientation: Gtk.Orientation.HORIZONTAL,
            homogeneous: true,
            spacing: 6
        );
    }

    construct {
        hours_entry = create_spin_button(0, 99);
        minutes_entry = create_spin_button(0, 59);
        seconds_entry = create_spin_button(0, 59);

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

        add(hours_entry);
        add(minutes_entry);
        add(seconds_entry);
    }

    public signal void timer_completed();

    private Gtk.SpinButton create_spin_button(int min, int max) {
        var button = new Gtk.SpinButton.with_range(min, max, 1);
        button.snap_to_ticks = true;
        button.wrap = true;
        return button;
    }
}

private class ControlRow : Gtk.Box {

    private Gtk.Button clock_button;
    private Gtk.Button start_button;
    private Gtk.Button pause_button;
    private Gtk.Button reset_button;

    public ControlRow() {
        Object(
            orientation: Gtk.Orientation.HORIZONTAL,
            homogeneous: true,
            spacing: 6
        );
    }

    construct {
        clock_button = new Gtk.Button.from_icon_name("tools-timer-symbolic");
        start_button = new Gtk.Button.from_icon_name("media-playback-start-symbolic");
        pause_button = new Gtk.Button.from_icon_name("media-playback-pause-symbolic");
        reset_button = new Gtk.Button.from_icon_name("edit-undo-symbolic");

        add(clock_button);
        add(start_button);
        add(pause_button);
        add(reset_button);
    }
}
