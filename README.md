# Welcome to AppSTARTer

[![Discord chat](https://img.shields.io/discord/477959324183035936.svg?logo=discord)](https://discord.gg/YFyJpmH) [![GitHub last commit](https://img.shields.io/github/last-commit/GhostWriters/AppSTARTer/master.svg)](https://github.com/GhostWriters/AppSTARTer/commits/master) [![GitHub license](https://img.shields.io/github/license/GhostWriters/AppSTARTer.svg)](https://github.com/GhostWriters/AppSTARTer/blob/master/LICENSE.md) [![Travis (.com) branch](https://img.shields.io/travis/com/GhostWriters/AppSTARTer/master.svg?logo=travis)](https://travis-ci.com/GhostWriters/AppSTARTer)

# What is AppSTARTer?

AppSTARTer is a new script from GhostWriters!

The main goal of AppSTARTer is to make it quick and easy to get up and running with natively installed applications.

You may choose to rely on AppSTARTer for various changes to your system's native installs, or use AppSTARTer as a stepping stone and learn to do more advanced configurations.

Currently, AppSTARTer will install the applications but doesn't do any configuration changes, like ports. Everything is currently installed with default values, but that will change over time.

# Getting Started

## System Requirements

- You must be running a supported system (listed below).
- You must be logged in as a non-root user with sudo permissions.

## One Time Setup (required)

- APT Systems (Debian, Ubuntu, etc)

```bash
sudo apt-get install curl git
bash -c "$(curl -fsSL https://ghostwriters.github.io/AppSTARTer/main.sh)"
sudo reboot
```

- DNF Systems (Fedora)

Not currently supported, but planned to be in the future!

- YUM Systems (CentOS)

Not currently supported, but planned to be in the future!

## Running AppSTARTer

```bash
sudo apps
```

To run AppSTARTer use the command above. You should now see the main menu.

Currently, it is recommended to do Configuration > Select Apps as any other menu option just takes you through prompts to set variables that aren't currently used.
