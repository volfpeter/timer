# Timer

Minimalist timer application that stays out of your way.

Use it as your flexible pomodoro timer or just set a reminder so you don't forget about your next task.

Not safe for rocket launch countdowns and the like :rocket:.

<p align="center">
  <img src="data/screenshots/Timer-default-theme.png" width="45%"/>
  <img src="data/screenshots/Timer-dark-theme.png" width="45%" />
</p>


## elementary OS

The application is written and officially supported for [elementary OS](https://elementary.io/).

[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/com.github.volfpeter.timer)


## Building and Installation

Dependencies required for building the application:

- `granite`
- `libgtk-3-dev`
- `libunity-dev`
- `meson`
- `valac`

Run `meson build --prefix=/usr` in the project folder to set up the build environment. Then change to the `build` directory and finally build and install the application with the `sudo ninja install` command.

For additional information, see elementary OS' [Getting Started guide](https://elementary.io/docs/code/getting-started#developer-sdk).

## Contributors

- [NathanBnm](https://github.com/NathanBnm): Project structure and build upgrades, French translation.
