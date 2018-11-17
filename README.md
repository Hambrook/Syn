# Syn for Content Synchronisation

Built for website developers to easily synchronise content and files between environments. Pull the database and uploaded files down from live so you're always testing with real data.

It will sync between local and remote environments, even between two remote environments. It even supports Docker containers and SSH tunnels.

Syn is fully extendable via plugins so you can add your own actions and flags.

Built in Bash with **zero** script dependencies. No avalanch of crap required. No PHP, NPM, etc. You just need `mysql` and `rsync` if you're using those plugins.

By Rick Hambrook (rick@rickhambrook.com)

----
## Platforms

Syn was built for Bash on Linux. It should also work in Bash on Mac and Windows 10 with Windows Subsystem for Linux (though this has not been tested). 

----
## Installation

Put Syn in a tools folder somewhere outside of your regular projects.

    $ git clone https://github.com/Hambrook/Syn.git
    $ Syn/syn --install

----
## Quick Start

### Example configuration (`.syn` file in project root)

    # Live config
    config[live/mysql/_ssh]=user@livehost
    config[live/mysql/name]=LIVENAME
    config[live/mysql/user]=LIVEUSER
    config[live/mysql/pass]=LIVEPASS
    config[live/rsync/dirs]="
        uploads=/absolute/path-to/uploads
        config=relative/path-to/config
    "
    config[live/mysql/skip]="
        oldtable
    "
    config[live/mysql/stru]="
        cache
        eventlog
    "

    # Local config
    config[local/mysql/name]=mydb
    #default user/pass of root/none will be used for db if not specified
    config[local/rsync/_docker]=my_container_name
    config[local/rsync/dirs]="
        uploads=relative/path-to/uploads
        config=/absolute/path-to/config
    "

### Usage

Simply specify your source and destination environments

    $ syn live local

Or to *see* the commands that will be run without actually running them, you can add `--dryrun`

    $ syn live local --dryrun

### Configuration Notes

Settings are configured by adding to the global `config` variable with a key in the format of `<environment>/<plugin>/<setting>`, eg

    config[live/mysql/user]=LIVEUSER
            |    |     |     |
            |    |     |     `Value
            |    |     |
            |    |     `Setting name
            |    |
            |    `Plugin
            |
            `Environment

Environment names can be whatever you want. As long as you only use alphanumeric characters.

Settings starting with an underscore (`_`) are connection config instead of specific to a plugin action.

Comment lines start with `#` and you cannot use spaces either side of the `=` sign.

For full configuration options for each plugin, use `--help`

    $ syn --help rsync

### Escaping Special Characters

Most variables can handle being surrounded in double quotes, but especially for passwords, it's best to leave the quotes off and single escape any special characters (`$;()|\`, etc), eg

    config[live/mysql/pass]=with\$pecial\;chars

----
## Core Commands, Vars, and Flags

_Note: use `syn --help` to see all vars, flags and more. Even those that aren't listed here._

### Commands

#### `--actions`
_Show the actions that are configured for the src, dst, or both_

#### `--envs`
_List available environments for the current location_

#### `--help`
_Show this help (or append a plugin name for specific help, eg "syn --help mysql")_

#### `--install`
_Installs Syn to the local path so you can use it simply by typing 'syn'_

#### `--plugins`
_Show all the loaded plugins_

#### `--self-update`
_Prompts to update Syn using Git (not elegant but it works)_

#### `--version`
_Shows the version and exits_

### Flags

#### `--dryrun`
_Show the commands that will be used, but don't actually run them_

#### `--force`
_Push to live/prod/"warn" without confirmation prompt (if applicable)_

### Vars

#### `--file`
_Specify an additional config file to load (after other attempts). Can be full or relative path, or the name of a file in your SYN_DEFAULT_PATH (see below). This is useful if you aren't storing the syn configuration files in the project folder. You can also use `--file .` to use the current directory name as the filename for a config file in your SYN_DEFAULT_PATH dir_

#### `--only`
_Select only the actions you want to take, comma separated_

----
## Plugins

Syn includes a few plugins by default (see the `plugins/` directory) and also supports third-party plugins. For more information, see `syn --help <plugin>`

#### `after`
Run commands after all other actions, eg turn off maintenance mode, clear the cache, etc.

#### `before`
Same as `after` but... *before* the other actions, eg turn on maintenance mode.

#### `mysql`
Copy database content between environments. You can specify tables to be ignored or to have their structure copied without their content.

#### `rsync`
Copies files efficiently using `rsync`. You can specify multiple sets of directories.

#### Third-party
Third-party plugins are all loaded from one directory (and that directory path must be set in your Bash environment).

----
## Creating Plugins

For example, if creating a plugin called "**foo**"...

1. Create a shared third-party plugins directory, eg `~/MySynPlugins` if you don't already have one
2. Add the path your Bash environment, eg open up `.bashrc` and add

    export SYN_PLUGIN_PATH="~/MySynPlugins"

3. Create a file in that directory named after your plugin, with the `.synPlugin` suffix, eg `foo.synPlugin`
4. Open up your plugin file and add two functions
    * `syn_plugin_foo()`
    * `syn_plugin_foo_help()`

The help function will be called from Syn's help system when requested by the user (`syn --help foo`). It should describe what your plugin does and provide an example configuration.

The other function will be called when it's time for you plugin to do its thing. It will have access to the `config` global variable which contains the entire merged configuration for Syn.

For reference, see the included plugins in the `plugins/` directory.

----
## `!` Prefix and List Values

Some plugins that list named items (such as `rsync` dirs or `before`/`after` commands) support the `!` prefix on the item name.

    config[live/rsync/dirs]="
        uploads=path/to/dir
        !configs=/root/based/path
        !app=/app
    "

The `!` means that this dir will not be processed unless you explicitly tell it to. So if you simply run `syn local staging` then the `rsync` plugin will only process the `uploads` dir by default. If you want the `app` dir too then you can do so by using `--rsync-only` or `--rsync-plus` as below.

#### `--<plugin>-only` (eg `--rsync-only configs,app`)
Will process **only** the items you specify, all others are ignored. So only `configs` and `app`.

#### `--<plugin>-plus` (eg `--rsync-plus app`)
Will process the default items **plus** any you specify. So `uploads` and `app`. Note that autocomplete won't suggest the default directories items they're already included.

#### `--<plugin>-list` (eg `--rsync-list`)
Will list the available values (dirs for `rsync`, commands for `before` and `after`) so you don't have to open up your config files to review them.

### Autocomplete

These values will auto-complete on the CLI. So if you type `syn local live --rsync-only` and press TAB, then you'll get the following suggestions:

    app config uploads

If you type `syn local live --rsync-plus config,` (note the comma) and press TAB, then you'll get these suggestions so you can easily build a comma separated list:

    config,app config,uploads

### More

The command examples above are for `rsync`, but the same commands are applicable for the `before` and `after` plugins, eg `--after-plus build`

    config[live/before/_ssh]=user@prodserver.com
    config[live/before/dst]="
        maintenance_on=php /path/to/project/bin maintenance_mode:enable
    "
    config[live/after/_ssh]=user@prodserver.com
    config[live/after/dst]="
        !build=php path/to/script tasks:build
        maintenance_off=php /path/to/project/bin maintenance_mode:disable
    "

----
## Configuration (Advanced)

### Example of Multiple Configuration Files

Syn will load settings from `.syn`, `.syn.local` and `.syn.global` from the current directory up to the root. This gives you many levels of overrides from files both in and out of Git repositories.

You can either put all your environment configs in one file, ot you can have a few configurations set up such as...

 * `.syn` file (in your project root, added to your repo so everyone can use it) containing the config for your live and staging environments
 * `.syn.local` file (in your project root, ignored by Git) with settings for your local environment
 * `.syn.global` file (above your project root) with config data shared for all projects (eg root database details)

The configuration will be built in the following order with each file overriding and extending the last

1. Default, built into the script and plugins (eg root/none for MySQL)
2. `.syn.global`
3. `.syn`
4. `.syn.local`

### Plugin Aliasing

You can also add aliases to your config files so that you can run the same plugin multiple times with completely different configurations.

Simply put your alphanumeric alias after the plugin name (separated by a period) and the differently aliased plugins will get run separately.

    config[live/rsync.web/_flags+]="--chmod=644"
    config[live/rsync.nonweb/_flags+]="--chmod=600"

### Warnings and Protections

Syn will automatically warn you before trying to synchronise TO any environment called "live" or "prod". But using the `_allow` setting, you can completely disallow or show warning prompts for any environment.

    config[live/_allow]=false
    config[staging/_allow]=warn

----
## Default Path

You can specify a default path which Syn will look in (as well as the current directory) when using the `--file` parameter. For example, add this to your `.bashrc` file:

    export SYN_DEFAULT_PATH=~/MySynConfigs  # if you use '~' then DO NOT use quotes!

----
## Warranty

No warranty, expressed or implied. Use at your own risk and always keep a fire extinguisher nearby.

----
## Credits

Icons made by [Eleonor Wang](https://www.flaticon.com/authors/eleonor-wang) from [Flaticon](https://www.flaticon.com/) and licensed by [CC 3.0](http://creativecommons.org/licenses/by/3.0/).

----
## License

Licensed under the [GPL-3.0 license](http://opensource.org/licenses/GPL-3.0).
