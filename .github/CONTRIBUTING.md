# Contributing Guidelines

All code in this repository should be neat and tidy.

More important than being beautiful is being functional. This repository is primarily shell scripts and YAML files.

## Shell scripts

- Remeber [Shell Scripts Matter](https://dev.to/thiht/shell-scripts-matter)
- [Use the Unofficial Bash Strict Mode](http://redsymbol.net/articles/unofficial-bash-strict-mode/)
- Follow the [Shell Style Guide](https://google.github.io/styleguide/shell.xml)
- Use [Defensive BASH Programming](https://web.archive.org/web/20180917174959/http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/)
- Should be validated using the following tools (recommended to be installed locally):
  - [bashate](https://github.com/openstack-dev/bashate)
  - [shellcheck](https://github.com/koalaman/shellcheck)
  - [shfmt](https://github.com/mvdan/sh)
- [Travis CI](https://travis-ci.com/GhostWriters/DockSTARTer) will perform tests on each commit using [ShellSuite](https://github.com/nemchik/ShellSuite) to confirm validity with the above tools. You may use ShellSuite to run tests locally, but traditional installation of each tool is still recommended for ease of use

## YAML files

- Should be formatted with [https://prettier.io/](https://prettier.io/)
- Should be sorted alphabetically
- Should follow the docker-compose structure
  - `<appname>.yml` is the main YAML template for an app and should have elements in the following order:
    - `name` should match `<appname>`
    - `labels` should contain the labels used by the app
      - `com.appstarter.appinfo.description: "<Description>"` will show the description in the menus
      - `com.appstarter.appinfo.nicename: "<AppName>"` must match `<appname>` exactly but can have mixed case. Ex: Portainer vs PORTAINER
      - See the template folder in .apps and files for more information

## .env.example file

- Contains environment variables to be used in the YAML templates
- All variables should be UPPERCASE
- Variables are split into sections with a comment to indicate the section name.
- Sections should be in the following order
  - `# Universal Settings`
  - `# Backup Settings`
  - `# VPN Settings`
  - `# App Settings`
    - Apps should have sub sections commented as `### <APPNAME>` (in caps)
    - App sub sections should be in the following order
      - `<APPNAME>_ENABLED=false` is always included and defaults to false for everything except Portainer and Watchtower
      - `<APPNAME>_BACKUP_CONFIG=` is always included and defaults to true
      - `<APPNAME>_NETWORK_MODE=` is always included and defaults to blank
      - `<APPNAME>_PORT_<ORIGINAL_PORT>=<USER_PORT>` (optional) is included based on what is needed by the app. There can be multiple ports. Ports should be sorted numerically. `<ORIGINAL_PORT>` is whatever port the app uses inside the container. `<USER_PORT>` is the port the user will use, and should default to be the same as the `<ORIGINAL_PORT>` unless it is a [Well-known port](https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers#Well-known_ports) in which case it should be moved to another port. Certain rare exceptions are made where the primary function of an app requires it be using a specific port
      - `<APPNAME>_ANYTHING_ELSE` (optional) is any other variable needed by the app. There can be multiple additional variables. Additional variables should be sorted alphabetically
  - `# END OF DEFAULT SETTINGS` should be the last non-blank line in the file and followed by a blank line. Users may define their own variables after this point in their .env file

We use Travis CI to run tests on the code in the repository. Code must pass tests run by Travis CI in order to merge to the `master` branch of the repository. Travis CI has a limit on requests to GitHub which can cause certain tests to fail. If this happens we can easily restart the build and try again until we get a true pass or fail.

Try not to [code like a cowboy](https://en.wikipedia.org/wiki/Cowboy_coding).
