# Changelog

Notable changes to this project will be documented here. Or see the [full commit history](https://github.com/Hambrook/Syn/commits/master).

### [_next release_]

###### Added

- [after] Add `after` plugin for running commands after other actions (also supports `!` prefix like `rsync`)
- [before] Add `before` plugin for running commands before other actions (also supports `!` prefix like `rsync`)
- [core] Add more colours to output (eg plugin output is on grey)
- [rsync] Prefix `!` to the name of a dir to have it not included by default (eg `!uploads=path/to/dir`)

###### Fixed

- [core] Fix some shellcheck issues

-

### [0.5.0] 2018-05-19

###### Added

- Add changelog (this thing)
- [core] Add icon to notification
- [rsync] Add `--rsync-list` command to list dirs
- [rsync] Add `--rsync-dryrun` flag to show changes without making them

###### Changed

- [mysql] MySQL configurations no longer require a password
- [rsync] Changed default flags to `-acEhlrtuz --progress --no-motd`
- [rsync] Removed `.git` from the default ignore list


### [0.4.0] 2018-03-07

###### Added

- Add summary with list of config files used
- Add hidden `--debug` flag
- [rsync] Add `--rsync-only` parameter to specify specific named dirs to process

###### Fixed

- Fix load order of configs/plugins


### [0.3] 2017-11-29

###### Added

- Add notify-send support if available
- Add `--force` flag to push to live/prod and "warn" environments without prompt
- Add plugin aliases, see [readme](https://github.com/Hambrook/Syn#plugin-aliasing) for more info
- Add support for coloured output, with helpful aliases for use in plugins
- Add support for `--key=value` as well as `--key value`
- Add tunnel support for when you can only rsync to an environment **through** another one
- Add basic installer. Run `path/to/syn --install` once, then just `syn` after that
- Add ascii banner

###### Changed

- **BREAKING CHANGE:** Config path uses slashes instead of commas now
- Dryrun notification now more obvious
- Author URL to https
- Moved plugins to their own files

###### Fixed

- `in_array` function
- Various formating issues
- Use `printf` instead of `echo`
- Better directory detection
- Var escaping


### [0.2]

- _No documented changes_
