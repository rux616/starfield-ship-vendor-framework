Ship Vendor Framework
=====================
by rux616

Version: 1.0.1

Table Of Contents
-----------------
- [Ship Vendor Framework](#ship-vendor-framework)
    - [Table Of Contents](#table-of-contents)
- [Overview](#overview)
    - [Summary](#summary)
    - [How To (Lite)](#how-to-lite)
    - [Compatibility](#compatibility)
    - [Known Issues](#known-issues)
    - [NPC Ship Lists](#npc-ship-lists)
- [Installation](#installation)
    - [Requirements](#requirements)
    - [Recommendations](#recommendations)
    - [Upgrading](#upgrading)
    - [Mod Manager](#mod-manager)
    - [Manual](#manual)
    - [Archive Invalidation](#archive-invalidation)
- [License](#license)
- [Credits and Acknowledgements](#credits-and-acknowledgements)
- [Contact](#contact)


Overview
========

Summary
-------
(A framework to easily add ships for sale without conflicts.)

The system that Bethesda designed for selling ships is interesting, but it lacks a crucial element: Changeability. In vanilla Starfield, once a ship vendor has been loaded the first time, the list of ships they offer for sale is locked in forever.

That's where this mod comes in. I've designed a system such that mod authors can easily add ships for sale to the various ship vendors without either conflicting with other mods that do the same or requiring the set up of a script. It will also refresh the vendor's list of ships if a change is detected in the vendor's "always" or "unique" lists. (A ship vendor's inventory is composed of three lists: always a.k.a. priority, random, and unique.)

NOTE: The "random" ships are only regenerated every 7 days (by default).

([TOC](#table-of-contents))

How To (Lite)
-------------
Mod authors, want to use the framework? It's easy, and you can do it in just three steps:

1. Design your ship.
2. Add your ship to a leveled base form.
3. Put that leveled base form into a form list and set one of the form lists included with this mod (SVF_ShipVendorList_*) as the target in the "add to list" box.

More detailed instructions are included in the HOWTO.txt document, and in the ["How to Utilize the Ship Vendor Framework" article](https://www.nexusmods.com/starfield/articles/624) on Nexus Mods.

([TOC](#table-of-contents))

Compatibility
-------------
This mod alters NPCs that offer ship services, as well as some of the leveled lists for spaceships that vendors use. Any other mods that also alter those objects may conflict without patches.

([TOC](#table-of-contents))

Known Issues
------------
None

([TOC](#table-of-contents))

NPC Ship Lists
--------------
Note: All form list editor IDs start with "SVF_ShipVendorList_". This prefix has been removed from the lists as presented in the following table for the sake of brevity.

![NPC Ship List Table](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1721963709-844221600.jpeg)

([TOC](#table-of-contents))


Installation
============

Requirements
------------
None

([TOC](#table-of-contents))

Recommendations
---------------
None

([TOC](#table-of-contents))

Upgrading
---------
When upgrading non-major versions (for example v2.something to v2.something-else), you don't need to do anything except replace the installed mod files.

When upgrading major versions (for example v1.whatever to v2.whatever), you need to do a clean install:
- Open the game and load your latest save
- Save your game, then quit
- Uninstall the previous version of the plugin and all its files
- Open the game and load your last save
- You will see a warning about missing the plugin you just uninstalled, choose to continue
- Save your game again, then quit
- Install the new version of the plugin

([TOC](#table-of-contents))

Mod Manager
-----------
Download and install the archive with either [Mod Organizer 2](https://github.com/ModOrganizer2/modorganizer/releases) (version 2.5.0 or later) or [Vortex](https://www.nexusmods.com/site/mods/1). I personally recommend Mod Organizer 2 (with the optional [Root Builder](https://kezyma.github.io/?p=rootbuilder) plugin to use with SFSE or any other mod that requires files be put directly in the game's installation folder).

([TOC](#table-of-contents))

Manual
------
Unsupported.

([TOC](#table-of-contents))

Archive Invalidation
--------------------
Make sure your `StarfieldCustom.ini` file in the "Documents\My Games\Starfield" folder (or your profile folder if using a mod manager and profiles) contains the following:

    [Archive]
    bInvalidateOlderFiles=1
    sResourceDataDirsFinal=

([TOC](#table-of-contents))


License
=======
- All code files are copyright 2024 Dan Cassidy, and are licensed under the [GPL v3.0 or later](https://www.gnu.org/licenses/gpl-3.0.en.html). The sole exceptions to this are the "ShipVendorScript.psc" and "OutpostShipbuilderMenuActivator.psc" files, as they are built upon the base that BGS provided and so are covered by their licenses.
- All non-code files are copyright 2024 Dan Cassidy, and are licensed under the [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/) license.

([TOC](#table-of-contents))


Credits and Acknowledgements
============================
ElminsterAU: For xEdit and BSArch
Mod Organizer 2 team: For Mod Organizer 2
Nexus Mods: For mod hosting and for the Vortex Mod Manager
Noggog: For Spriggit

([TOC](#table-of-contents))


Contact
=======
If you find a bug or have a question about the mod, please post it on the [mod page at Nexus Mods](https://www.nexusmods.com/starfield/mods/10057), or in the [GitHub project](https://github.com/rux616/starfield-ship-vendor-framework).

If you need to contact me personally, I can be reached through one of the following means:
- **Nexus Mods**: [rux616](https://www.nexusmods.com/users/124191) (Send a message via the "CONTACT" button.)
- **Email**: rux616-at-pm-dot-me (replace `-at-` with `@` and `-dot-` with `.`)
- **Discord**: rux616 (user ID 234489279991119873) - make sure to "@" me
    - [Lively's Modding Hub](https://discord.gg/livelymods)
    - [Nexus Mods](https://discord.gg/nexusmods)
    - [Collective Modding](https://discord.gg/pF9U5FmD6w) ("🔧-chaotic-cognitions" channel)
    - [Starfield Modding](https://discord.gg/6R4Yq5KjW2)

([TOC](#table-of-contents))
