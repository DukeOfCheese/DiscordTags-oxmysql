# DiscordTags System

A FiveM resource that adds customizable head tags above players with ace-based permissions with the ability to connect to an external database.

Original FiveM code is an amalgamation and optimisation of code from [JoeV2's headtag](https://github.com/Joe-Development/Headtag-Menu) and [JoeV2's gangtag](https://github.com/Joe-Development/Gangtag-Menu) repositories!

Compatible with this pre-made [Discord Bot]

![Version](https://img.shields.io/badge/version-1.3.0-blue.svg)

## Overview

DiscordTags allows server administrators to display custom tags above players' heads based on their roles / ACEs. Perfect for roleplay servers to identify staff members and special roles at a glance.

## Features

- Ace-based headtags using ACE permissions
- Configurable display format and height
- Toggle individual or all headtags
- Search functionality for tags
- Speaking indicator changes color when players talk
- Noclip compatibility
- ox_mysql compatibility for external tag management

## Dependencies

- [ox_lib](https://github.com/overextended/ox_lib)
- [RageUI](https://github.com/Joe-Development/Headtag-Menu/releases/download/release/RageUI.zip)
- [oxmysql](https://github.com/overextended/oxmysql)

## Quick Start

1. Download the latest release
2. Extract to your resources folder
3. Add to your `server.cfg`:
   ```
   ensure ox_lib
   ensure oxmysql
   ensure RageUI
   ensure DiscordTags
   ```
4. Configure permissions in your server.cfg (see documentation)
5. Use `/headtags` and `/gangtags` in-game to access the menus

## Documentation

For detailed configuration options, commands, and developer information, please refer to the [documentation](./docs/documentation.md).

## Support

Discord Bot / oxmysql / script combination issues or support:
- [Discord Server](https://discord.gg/6wxdQMrruw)
- DukeOfCheese @ Atlas Development

Original Repository:
For support or to report issues:
- [Discord Server](https://discord.gg/TZFPF2n5Ys)
- Created by JoeV2@Joe Development
