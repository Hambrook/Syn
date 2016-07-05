# Syn for environment synchronisation

Built for website developers to easily synchronise between environments. Pull the database and uploaded files down from live so you're always testing with real data.

It will sync between local and remote environments, even between two remote environments. It even supports Docker containers.

Syn is fully extendable via plugins so you can add your own actions and flags.

By Rick Hambrook (rick@rickhambrook.com)

----
## Platforms

Syn was built for Bash on Linux. It should also work in Bash on Mac and Windows 10 Anniversary Edition (though this has not been tested). 

----
## Usage
    syn SRC DST [OPTIONS]

----
## Installation
Add (or symlink) the file to your `$PATH` variable, or simply to your `~/bin` directory. Eg `~/bin/syn`.

I may create an installer at some point.

----
## Configuration

Syn will load settings from `.syn`, `.syn.local` and `.syn.global` from the current directory up to the root. This gives you many levels of overrides from files both in and out of Git repositories.

Settings starting with an underscore (`_`) are connection config instead of specific to a plugin action.

Create a `.syn` file in your project root

    # Live config
    config[live,mysql,_ssh]=user@livehost
    config[live,mysql,name]=LIVENAME
    config[live,mysql,user]=LIVEUSER
    config[live,mysql,pass]=LIVEPASS
    config[live,rsync,dirs]="
        a=b
        foo=bar/sub
        anotherpath
    "

    # Local config
    config[local,mysql,name]=mydb
    #default user/pass of root/root will be used for db if not specified
    config[local,rsync,_docker]=my_container_name
    config[local,rsync,dirs]="
        a=c
        foo=baz/sub
        anotherotherpath
    "

### Example of multiple configuration files

You can either put all your environment configs in one file, you can have a few configurations set up such as...

 * `.syn` file (in your project root, added to your repo so everyone can use it) containing the config for your live and staging environments
 * `.syn.local` file (in your project root, ignored by Git) with settings for your local environment
 * `.syn.global` file (above your project root) with config data shared for all projects (eg root database details)

The configuration will be built in the following order with each file overriding and extending the last

1. Default, built into the script and plugins (eg root/root for MySQL)
2. `.syn.global`
3. `.syn`
4. `.syn.local`

### Escaping Special Characters

Most variables can handle being surrounded in double quotes, but especially for passwords, it's best to leave the quotes off and single escape any special characters (`$;()|\`, etc), eg

```
config[live,db,pass]=with\$pecial\;chars
```

----
## Available commands

### --actions
_Show the actions that are configured for the src, dst, or both_

### --envs
_List available environments for the current location_

### --plugins
_Show all the loaded plugins_

### --help
_Show this help (or append a plugin name for specific help, eg "syn --help mysql")_

## Available flags

### --dryrun
_Show the commands that will be used, but don't actually run them_

### --install
_Installs Syn to the local path so you can use it simply by typing 'syn'_

## Available vars

### --file
_Specify an additional config file to load (after other attempts). Can be full or relative path, or the name of a file in your SYN_DEFAULT_PATH (see below)_

### --only
_Select only the actions you want to take, comma separated_

----
## Warnings and Protections

Syn will automatically warn you before trying to synchronise TO any environment called "live" or "prod". But using the `_allow` setting, you can completely disallow or show warning prompts for any environment.

    config[live,_allow]=false
    config[staging,_allow]=warn

----
## Plugins

Syn includes `mysql` and `rsync` plugins by default. But you can easily integrate your own plugins written in Bash.

Third-party plugins are all loaded from one directory (and that directory path must be set in your Bash environment).

For example, if creating a plugin called "**foo**"...

1. Create a plugin directory, eg `~/MySynPlugins`
2. Add the path your Bash environment, eg open up `.bashrc` and add

    export SYN_PLUGIN_PATH="~/MySynPlugins"

3. Create a file in that directory named after your plugin, with the `.synPlugin` suffix, eg `Foo.synPlugin`
4. Open up your plugin file and add two functions
 * syn\_action\_foo()
 * syn\_action\_foo\_help()

The help function will be called from Syn's help system when requested by the user (`syn --help foo`). It should describe what your plugin does and provide an example configuration.

The other function will be called when it's time for you plugin to do its thing. It will have access to the `config` global variable which contains the entire merged configuration for Syn.

For reference, see the inbuilt plugins within the main Syn file.

----
## Default Path

You can specify a default path which Syn will look in (as well as the current directory) when using the `--file` parameter. For example, add this to your `.bashrc` file.

    export SYN_DEFAULT_PATH="~/MySynConfigs"

----
## Warranty

No warranty, expressed or implied. Use at your own risk and always keep a fire extinguisher nearby.

----
## License

Licensed under the [GPL-3.0 license](http://opensource.org/licenses/GPL-3.0)