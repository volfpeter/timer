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

public class TimerApp : Gtk.Application {

    public TimerApp () {
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
        var app = new TimerApp();
        return app.run(args);
    }
}

private class MainWindow : Gtk.ApplicationWindow {

    private Timer timer;
    private Control control;
    private Gtk.Entry message_entry;

    public MainWindow(Gtk.Application application) {
        Object(
            application: application,
            title: _("Timer")
        );
    }

    construct {
        timer = new Timer();
        timer.timer_completed.connect(send_notification);

        control = new Control();
        control.start_pause_button.clicked.connect(timer.start_or_pause);
        control.reset_button.clicked.connect(timer.reset);

        timer.is_running_changed.connect(() => {
            if (timer.is_running) {
                control.use_pause_button();
            } else {
                control.use_start_button();
            }

            control.enable_start(timer.can_start);
            control.enable_reset(timer.can_reset);
        });
        timer.can_reset_changed.connect(() => {
            control.enable_reset(timer.can_reset);
        });
        timer.can_start_changed.connect(() => {
            control.enable_start(timer.can_start);
        });

        message_entry = new Gtk.Entry();
        message_entry.placeholder_text = _("Notification message");

        var column = new Gtk.Box(Gtk.Orientation.VERTICAL, 6);
        column.margin = 6;
        column.add(timer);
        column.add(control);
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

private class Timer : Gtk.Box {

    public Timer() {
        Object(
            orientation: Gtk.Orientation.HORIZONTAL,
            homogeneous: true,
            spacing: 6
        );
    }

    construct {
        hours_entry = create_spin_button(0, 99);
        hours_entry.value_changed.connect(update_base_seconds);
        minutes_entry = create_spin_button(0, 59);
        minutes_entry.value_changed.connect(update_base_seconds);
        seconds_entry = create_spin_button(0, 59);
        seconds_entry.value_changed.connect(update_base_seconds);

        // Connect the entries
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

    private uint timer_id;

    private Gtk.SpinButton hours_entry;
    private Gtk.SpinButton minutes_entry;
    private Gtk.SpinButton seconds_entry;


    private int _base_seconds = 0;

    protected int base_seconds {
        get {
            return _base_seconds;
        }

        set {
            if (value != _base_seconds) {
                _base_seconds = value;
                can_start_changed();
                can_reset_changed();
            }
        }
    }

    private int entries_as_seconds {
        get {
            return hours_entry.get_value_as_int() * 3600 + minutes_entry.get_value_as_int() * 60 + seconds_entry.get_value_as_int();
        }
    }

    public bool can_start {
        get {
            return minutes_entry.value > 0 || seconds_entry.value > 0 || hours_entry.value > 0;
        }
    }

    public bool can_reset {
        get {
            return _base_seconds > 0;
        }
    }

    private bool _is_running = false;

    /**
     * Whether the timer is running.
     */
    public bool is_running {
        get {
            return _is_running;
        }

        set {
            if (value != _is_running) {
                _is_running = value;
                hours_entry.sensitive = minutes_entry.sensitive = seconds_entry.sensitive = !value;
                is_running_changed();
            }
        }
    }

    public signal void can_reset_changed();

    public signal void can_start_changed();

    public signal void is_running_changed();

    public signal void timer_completed();

    public void start_or_pause() {
        if (is_running) {
            pause();
        } else if (can_start) {
            timer_id = GLib.Timeout.add_seconds(1, tick_handler);
            is_running = true;
        }
    }

    public void reset() {
        pause();

        int remainder = base_seconds;
        int seconds = remainder % 60;
        remainder = (remainder - seconds) / 60;
        int minutes = remainder % 60;
        remainder = (remainder - minutes) / 60;
        int hours = remainder;

        hours_entry.value = hours;
        minutes_entry.value = minutes;
        seconds_entry.value = seconds;

        can_start_changed();
    }

    private Gtk.SpinButton create_spin_button(int min, int max) {
        var button = new Gtk.SpinButton.with_range(min, max, 1);
        button.snap_to_ticks = true;
        button.wrap = true;
        return button;
    }

    private void pause() {
        if (is_running) {
            GLib.Source.remove(timer_id);
            is_running = false;
        }
    }

    private bool tick_handler() {
        seconds_entry.spin(Gtk.SpinType.STEP_BACKWARD, 1);
        if (!can_start) {
            is_running = false;
            timer_completed();
            return false;
        }
        return true;
    }

    private void update_base_seconds() {
        if (!is_running) {
            base_seconds = entries_as_seconds;
        }
    }
}

private class Control : Gtk.Box {

    public Gtk.Button clock_button;
    public Gtk.Button start_pause_button;
    public Gtk.Button reset_button;

    public Control() {
        Object(
            orientation: Gtk.Orientation.HORIZONTAL,
            homogeneous: true,
            spacing: 6
        );
    }

    construct {
        clock_button = new Gtk.Button.from_icon_name("tools-timer-symbolic");
        start_pause_button = new Gtk.Button.from_icon_name("media-playback-start-symbolic");
        start_pause_button.sensitive = false;
        reset_button = new Gtk.Button.from_icon_name("edit-undo-symbolic");
        reset_button.sensitive = false;

        add(clock_button);
        add(start_pause_button);
        add(reset_button);
    }

    public void enable_reset(bool value) {
        reset_button.sensitive = value;
    }

    public void enable_start(bool value) {
        start_pause_button.sensitive = value;
    }

    public void use_pause_button() {
        start_pause_button.set_image(
            new Gtk.Image.from_icon_name("media-playback-pause-symbolic", Gtk.IconSize.BUTTON)
        );
    }

    public void use_start_button() {
        start_pause_button.set_image(
            new Gtk.Image.from_icon_name("media-playback-start-symbolic", Gtk.IconSize.BUTTON)
        );
    }
}
