project('com.github.volfpeter.timer', 'vala', 'c')

i18n = import('i18n')

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

dependencies = [
    dependency('gtk+-3.0'),
    dependency('granite'),
    dependency('unity')
]

subdir('src')

executable(
    meson.project_name(),
    sources,
    dependencies: dependencies,
    install: true
)

subdir('data')
subdir('po')

meson.add_install_script('meson/post_install.py')