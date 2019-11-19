# Changelog

Notable changes to this project will be documented here. Or see the [full commit history](https://github.com/Hambrook/Syn/commits/master).


## UPCOMING

### Fixed

- [core] Fix summary not showing all config files that were loaded


## [1.0.1] 2019-11-19

### Fixed

- [core] Fix notifications not working via BurntToast (artifact of debugging)


## [1.0.0] 2019-11-19

### BREAKING CHANGES

- [core] Changed `--file` var to `--config`
- [rsync] `dirs` config has been renamed to `paths` and a deprecation notice has been added
- [rsync] Folder paths should now **end with a trailing slash** so paths without trailing slashes are presumed to be files

### Added

- [core] Add `⚠` icon to error message
- [core] Add autocompletion for `--config` (formerly `--file`)
- [core] Add `syn_copy_config()` function. Available for use in `.syn` files and useful for inheriting configs between entries
- [core] Add notification support for WSL on Windows 10 (via BurntToast). See `syn --notifications` or ReadMe for more info
- [core] Add `syn_cli_info()` function for displaying a yellow info box
- [mysql] Add `flags+` option and move flags to end of the command (for _very_ crude use of `sed` etc)
- [mysql] Add ability to override default values
- [rsync] Add ability to override default flags
- [mysql] Add connectivity check to DST before connecting to SRC

### Changed

- [mysql] Change how command is compiled to remove extra whitespaces

### Fixed

- [core] Fix error display not parsing new lines
- [core] Fix config hierarchy not working as expected
- [core] Fix colour output (and r_bold) for help and info
- [mysql] Fix default config not applying to aliased keys
- [rsync] Fix remote to remote transfers


## [0.6.2] 2018-12-06

### Added

- [core] Add `!` prefix (to mark as non-default) support for actions
- [core] Add `--plus` support to core
- [core] Stop further processing if a plugin reports an error
- [core] Add `--actions-all` command to list all actions for the specified environments (with prefix)

### Changed

- [core] Restructure how actions are stored
- [core] Improve actions parsing
- [core] Consolidated a lot of KV filtering logic
- [core] Any `syn_cmd_` prefixed command can be run but only commands with help text will show in the commands list
- [core] Added more colours to help screen and command/flag/var lists


## [0.6.1] 2018-05-31

### Added

- [core] Add core functions to take weight off the plugins (mostly with kv fields)
- [core] Add autocomplete for `--only`
- [core] Add `--<plugin>-plus` to specify items to process in addition to defaults (autocomplete only suggests non-defaults)
- [core] Add `--version`
- [core] Add `--self-update`
- [core] Moved to semantic versioning (tempted to bump to 1.0.0 but not quite yet)

### Fixed

- [rsync] Fix `--rsync-only` not processing non-default dirs even when told to
- [docs] Fix documenation and add "zero dependencies" line
- [docs] Remove `chmod` line from installation instructions

### Changed

- [core] Move lots of functions to lib files :)
- [docs] Big update of the README and help text


## [0.6.0] 2018-05-24

### Added

- Add **CLI TAB COMPLETION**. Full tab completion. And if you put a comma at the end of a var property, it'll suggest the other vars too... eg `--rsync-only dir1,` will suggest `dir1,dir2` and `dir1,dir3`. Use `--install` to install the bash tab completion file to your system.
- [after] Add `after` plugin for running commands after other actions (also supports `!` prefix like `rsync`)
- [before] Add `before` plugin for running commands before other actions (also supports `!` prefix like `rsync`)
- [core] Add more colours to output (eg plugin output is on grey)
- [rsync] Prefix `!` to the name of a dir to have it not included by default (eg `!uploads=path/to/dir`)
- [core] Added lots of bugs to find later

### Fixed

- [core] Fix some shellcheck issues


## [0.5.0] 2018-05-19

### Added

- [docs] Add changelog (this thing)
- [core] Add icon to notification
- [rsync] Add `--rsync-list` command to list dirs
- [rsync] Add `--rsync-dryrun` flag to show changes without making them

### Changed

- [mysql] MySQL configurations no longer require a password
- [rsync] Changed default flags to `-acEhlrtuz --progress --no-motd`
- [rsync] Removed `.git` from the default ignore list


## [0.4.0] 2018-03-07

### Added

- Add summary with list of config files used
- Add hidden `--debug` flag
- [rsync] Add `--rsync-only` parameter to specify specific named dirs to process

### Fixed

- Fix load order of configs/plugins


## [0.3] 2017-11-29

### Added

- Add notify-send support if available
- Add `--force` flag to push to live/prod and "warn" environments without prompt
- Add plugin aliases, see [readme](https://github.com/Hambrook/Syn#plugin-aliasing) for more info
- Add support for coloured output, with helpful aliases for use in plugins
- Add support for `--key=value` as well as `--key value`
- Add tunnel support for when you can only rsync to an environment **through** another one
- Add basic installer. Run `path/to/syn --install` once, then just `syn` after that
- Add ascii banner

### Changed

- **BREAKING CHANGE:** Config path uses slashes instead of commas now
- Dryrun notification now more obvious
- Author URL to https
- Moved plugins to their own files

### Fixed

- `in_array` function
- Various formating issues
- Use `printf` instead of `echo`
- Better directory detection
- Var escaping


## [0.2]

- _No documented changes_
