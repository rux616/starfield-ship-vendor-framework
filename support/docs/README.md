Ship Vendor Framework
=====================
by rux616

Version: 1.10.0

Table Of Contents
-----------------
- [Ship Vendor Framework](#ship-vendor-framework)
    - [Table Of Contents](#table-of-contents)
- [Overview](#overview)
    - [Summary](#summary)
    - [How To Add Ships (Lite)](#how-to-add-ships-lite)
    - [Compatibility](#compatibility)
    - [Dealing with Corruption](#dealing-with-corruption)
    - [Known Issues](#known-issues)
    - [Enabling Logs](#enabling-logs)
    - [NPC Ship Lists](#npc-ship-lists)
- [Installation](#installation)
    - [Load Order](#load-order)
    - [Requirements](#requirements)
    - [Recommendations](#recommendations)
    - [Upgrading (General)](#upgrading-general)
    - [Upgrading to v1.6.0+ from v1.5.4 or earlier](#upgrading-to-v160-from-v154-or-earlier)
    - [Mod Manager](#mod-manager)
    - [Manual](#manual)
- [License](#license)
- [Credits and Acknowledgements](#credits-and-acknowledgements)
- [Contact](#contact)


Overview
========

Summary
-------
(A framework allowing mod authors to easily add ships for sale without conflicts.)

The system that Bethesda designed for selling ships is interesting, but it lacks a crucial element: Changeability. In vanilla Starfield, once a ship vendor has been loaded the first time, the list of ships they offer for sale is locked in forever until starting a new game (or new game plus).

That's where this mod comes in. I've designed a system such that mod authors can easily add ships for sale to the various ship vendors without either conflicting with other mods that do the same or requiring the set up of a script. It will also refresh the vendor's list of ships if a change is detected in the vendor's "always" or "unique" lists. (A ship vendor's inventory is composed of three lists: always a.k.a. priority, random, and unique.)

Additionally, mod authors can also add keywords to ship vendors, again without conflicting with other mods or requiring the use of a script. Special groups exist to target "all", "non-outpost", and "outpost" ship vendors, or specific ship vendors can be targeted individually. (Note that by default, the "outpost" ship vendor list consists of just the main vanilla outpost ship vendor, but others can be added.)

As with Ship Builder Categories, this mod is intended to be a community resource and so will always have manual donations disabled and remain opted out of the Nexus Mods Donation Point system.

**NOTE:** Vendors refresh their ship inventory every 7 days by default.

([TOC](#table-of-contents))

How To Add Ships (Lite)
-----------------------
Mod authors, want to use the framework? It's easy, and you can do it in just three steps with the Starfield Creation Kit:

1. Design your ship.
2. Add your ship to a leveled base form.
3. Put that leveled base form into a form list and set one of the form lists included with this mod (SVF_ShipVendorList_*) as the target in the "add to list" box.

More detailed instructions, including for making your own SVF-enhanced ship vendors, are included in the HOWTO.txt document, and in the ["How to Utilize the Ship Vendor Framework" article](https://www.nexusmods.com/starfield/articles/624) on Nexus Mods.

([TOC](#table-of-contents))

Compatibility
-------------
This mod alters most of the leveled lists for spaceships that vendors use to add proper level gates, as well as the `CF_Post` dialogue `[QUST:00143472]` and `CF_Post_Toft_TL_ShipServices` scene `[SCEN:001F88DD]` to allow for Lt. Jillian Toft to function as a ship vendor once the Crimson Fleet quest line concludes. Any other mods that also alter those records may conflict without patches.

Additionally, this mod alters 4 vanilla scripts, "OutpostShipbuilderMenuActivator", "ShipBuilderMenuActivator", "ShipVendorInfoScript", and "ShipVendorScript". As a result, a mod that alters any of those scripts will conflict by definition. This also means that when the game is updated, script changes by Bethesda will not be present in this mod until it is updated.

Mods that are known to conflict:
- "DarkStar" by WykkydGaming [[Creations](https://creations.bethesda.net/en/starfield/details/f082c443-5f3e-4528-b03e-10c319d01ddf/DarkStar)]: No patch. There are no lists for mod authors to add ships to, the "Rich Ship Vendors" option doesn't work with the DarkStar ship vendors, and not all ships may be immediately available to purchase if the "buy ships" option is accessed too soon after the vendor's ship inventory is refreshed or the vendor is initially created. (I would recommend using DarkStar Astrodynamics instead.)
- "DarkStar Astrodynamics" by WykkydGaming [[Creations](https://creations.bethesda.net/en/starfield/details/cfca357a-7226-4cae-bd16-3575069dcf2e/DarkStar_Astrodynamics) / [Nexus](https://www.nexusmods.com/starfield/mods/9458)]: Use SVF Compatibility Patch - DarkStar Astrodynamics.
- "Rich Outpost Shipbuilder" by LilithMotherOfAll [[Nexus](https://www.nexusmods.com/starfield/mods/5492)]: No patch. Uninstall this mod if you have it. Ship Vendor Framework now has this functionality built in.
- "Starvival" by lKocMoHaBTl [[Creations](https://creations.bethesda.net/en/starfield/details/cb70aedd-4793-4e05-be51-b5a4987d6b71/Starvival___Immersive_Survival_Addon) / [Nexus](https://www.nexusmods.com/starfield/mods/6890)]: Use SVF Compatibility Patch - Starvival.

Mods that I have created capability patches for (included in the main download):
- "Dominion" by rhart317 [[Creations](https://creations.bethesda.net/en/starfield/details/97f792d0-d078-4a50-aa32-f03cc054e241/Dominion)]
- "Falkland Systems Ship Services" by Hjalmere [[Creations](https://creations.bethesda.net/en/starfield/details/6cbf2c64-b736-4d95-bf06-38183a94b359/Falkland_Systems_Ship_Services)]
- "Iconic Ships" by ShipTechnician [[Creations](https://creations.bethesda.net/en/starfield/details/569e938e-228c-42fb-91ba-c6967575bcf3/Iconic_Ships)]
- "L-K Ships" by Lighthorse and KeithVSmith1977 [[Creations](https://creations.bethesda.net/en/starfield/details/f287801b-a863-48fb-b796-1eeaeda4eab3/L_K_Ships) / [Nexus](https://www.nexusmods.com/starfield/mods/7433)]
- "Lower Landing Pad" by SenterPat [[Nexus](https://www.nexusmods.com/starfield/mods/8363)]
- "Outpost Vendor New Ships" by nefurun [[Creations](https://creations.bethesda.net/en/starfield/details/b5723c97-fb67-46ed-9833-07d4e1d8ced1/Outpost_Vendor_New_Ships)]
- "The Den Astrodynamics" by VoodooChild [[Nexus](https://www.nexusmods.com/starfield/mods/8809)]
- "Watchtower" by kinggath_creations [[Creations](https://creations.bethesda.net/en/starfield/details/5d455df7-d99f-4619-a383-f2b39aa21e00/Watchtower__Orbital_Strike__Fleet_Command)]

([TOC](#table-of-contents))


Dealing with Corruption
-----------------------
First things first, this is not exclusive to the Ship Vendor Framework. The same thing can happen in the vanilla ship vendor script. What's different is that the SVF attempts to notify the user and the "Corruption Detected" message gives helpful information to troubleshoot this. Unfortunately, it's only half the information that is needed. The other half is your load order. I need both to help you narrow down what ship/mod is bad.

If you get the "Corruption Detected" message, don't panic! Yes, your current session is unfortunately toast, but you kept multiple saves because this is a Bethesda game and It Just Works, right? _RIGHT?_ Anyway, the last non-corrupted save is likely going to be A) the one before you entered the current area if you've been playing your current session a while, or B) your most recent save that you loaded into if you just started playing after installing additional mods.

Technical details:
The modified ship vendor script in SVF sets up a watchdog timer just before attempting to spawn a ship. In normal circumstances, the function that spawns the ship finishes in well under a second, usually within about 300 milliseconds, after which the timer is cancelled before it triggers. However, if the ship that the script tries to spawn is bad, the spawn function never finishes, thus hanging the script indefinitely and ultimately corrupting everything, which is where the timer comes into play. The timer is independent of that process and will trigger if left too long. This is what will show the "corruption detected" message.

The "Vendor ID" and "Ship ID" numbers are simply a hexadecimal form ID translated into decimal. So for instance, the Form ID for Nikau Henderson is 0027A992 in hexadecimal, but 2599314 in decimal.

([TOC](#table-of-contents))

Known Issues
------------
- When updating this mod via Creations, the process sometimes fails to actually update the mod for unknown reasons. Because of this, when doing an upgrade, I instead recommend that players simply fully remove this mod and then download it again.

([TOC](#table-of-contents))

Enabling Logs
-------------
**NOTE:** This section only applies to PC users.

In your StarfieldCustom.ini file, make sure you have the following section:

    [Papyrus]
    bEnableLogging=1
    bEnableProfiling=1
    bEnableTrace=1
    bLoadDebugInformation=1

This will ensure that the game writes logs. If I request them in order to help you, I will be looking for "Papyrus.X.log" in the "%UserProfile%\Documents\My Games\Starfield\Logs" directory, and "ShipVendorFramework.X.log" in the "%UserProfile%\Documents\My Games\Starfield\Logs\Script\User" directory, where "X" represents a number 0-3.

([TOC](#table-of-contents))

NPC Ship Lists
--------------
**NOTE:** All form list editor IDs start with `SVF_ShipVendorList_`. This prefix has been removed from the lists as presented in the following tables for the sake of brevity.

Vanilla:
![NPC Ship List Table (Vanilla)](/support/packaging/svf-npc-form-list.jpg)

Free Lanes (with patch):
![NPC Ship List Table (Free Lanes Patch)](/support/packaging/svf-npc-form-list-FreeLanes.jpg)

Shattered Space (with patch):
![NPC Ship List Table (Shattered Space Patch)](/support/packaging/svf-npc-form-list-ShatteredSpace.jpg)

DarkStar Astrodynamics (with patch):
![NPC Ship List Table (DarkStar Astrodynamics Patch)](/support/packaging/svf-npc-form-list-DarkStarAstrodynamics.jpg)

Falkland Systems Ship Services (with patch):
![NPC Ship List Table (Falkland Systems Ship Services Patch)](/support/packaging/svf-npc-form-list-FalklandSystems.jpg)

Watchtower (with patch):
![NPC Ship List Table (Watchtower Patch)](/support/packaging/svf-npc-form-list-Watchtower.jpg)

([TOC](#table-of-contents))


Installation
============

Load Order
----------
For best results, I would recommend keeping this mod and all its patches in a single block, all following any other mods that are being patched.

For patches, the load order is recommended to be as follows:
- ShipVendorFramework.esm
- (SVF Capability Patches, if any)
- (SVF Compatibility Patches, if any)
- (SVF Keyword Patches, if any)

([TOC](#table-of-contents))

Requirements
------------
- Starfield v1.11.36 (released 2024-05-15) or later

([TOC](#table-of-contents))

Recommendations
---------------
None

([TOC](#table-of-contents))

Upgrading (General)
-------------------
**NOTE:** Regardless of whether it is a minor or major version upgrade, it is recommended to do a full replacement of the mod files in your mod manager so that old files get cleaned up. (For example, in Mod Organizer 2, when you install a mod with the same name, you get an option to "Merge", "Replace", or "Rename"; choose "Replace".)

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

Upgrading to v1.6.0+ from v1.5.4 or earlier
-------------------------------------------
The v1.6.0 update of Ship Vendor Framework gets rid of the following ESM files, as they are obsolete and no longer needed:
- SVF-Generic-AllShipModulesUnlocked-AllShipVendors-Patch.esm
- SVF-Generic-AllShipModulesUnlocked-AllShipVendors-ShatteredSpace-Patch.esm
- SVF-Generic-AllShipModulesUnlocked-OutpostOnly-Patch.esm
- SVF-Generic-ShipVendors-Patch.esm
- SVF-Generic-ShipVendors-ShatteredSpace-Patch.esm
- SVF-LowerLandingPadUnlocked-Patch.esm

If you were using them, you should be able to safely ignore the "missing mod files" message when you load up your game for the first time after installing the new version (for the Lower Landing Pad patch, use the other one). That being said, you should back up your save anyway, just in case.

([TOC](#table-of-contents))

Mod Manager
-----------
**NOTE:** Support for Nexus Mod Manager (NMM) will **NOT** be provided as its FOMOD implementation is broken. Use either Mod Organizer 2 or Vortex.

Download and install the archive with either [Mod Organizer 2](https://github.com/ModOrganizer2/modorganizer/releases) (version 2.5.2 or later) or [Vortex](https://www.nexusmods.com/site/mods/1). I personally recommend Mod Organizer 2 (with the optional [Root Builder](https://kezyma.github.io/?p=rootbuilder) plugin to use with SFSE or any other mod that requires files be put directly in the game's installation folder).

([TOC](#table-of-contents))

Manual
------
Unsupported. I want nothing to do with your hand-crafted artisanal potential dumpster fire of an install.

([TOC](#table-of-contents))


License
=======
- All code files are copyright Dan Cassidy (see individual files for exact years), and are licensed under the [GPL v3.0 or later](https://www.gnu.org/licenses/gpl-3.0.en.html). The sole exceptions to this are the "OutpostShipbuilderMenuActivator", "ShipBuilderMenuActivator", "ShipVendorInfoScript", and "ShipVendorScript" files, as they are built upon the base that BGS provided and so are covered by their licenses.
- All non-code files are copyright 2024, 2025 Dan Cassidy, and are licensed under the [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/) license.

([TOC](#table-of-contents))


Credits and Acknowledgements
============================
Bethesda Game Studios: For Starfield itself and the Starfield Creation Kit
ElminsterAU: For xEdit and BSArch
Lively: For helping explain some of the odd nuances of an infrequently-used-by-me FOMOD feature
Mod Organizer 2 team: For Mod Organizer 2
Nexus Mods: For mod hosting and for the Vortex Mod Manager
Noggog: For Spriggit
perchik71: For Creation Kit Platform Extended
Scrivener07: For some advice and clarification on papyrus matters

([TOC](#table-of-contents))


Contact
=======
If you find a bug or have a question about the mod, please post it on the [mod page at Nexus Mods](https://www.nexusmods.com/starfield/mods/10057), the [GitHub project](https://github.com/rux616/starfield-ship-vendor-framework), or on Reddit in [r/StarfieldMods](https://www.reddit.com/r/starfieldmods/) (make sure to tag me: u/rux616).

If you need to contact me personally, I can be reached through one of the following means:
- **Nexus Mods**: [rux616](https://www.nexusmods.com/users/124191) (Click the "Message" button.)
- **Email**: rux616-at-pm-dot-me (replace `-at-` with `@` and `-dot-` with `.`)
- **Reddit**: u/rux616
- **Discord**: rux616 (user ID 234489279991119873) - make sure to "@" me
    - [Lively's Modding Hub](https://discord.gg/livelymods)
    - [Nexus Mods](https://discord.gg/nexusmods)
    - [Collective Modding](https://discord.gg/pF9U5FmD6w) ("🔧-chaotic-cognitions" channel)
    - [Starfield - Ship Distribution](https://discord.gg/wuvaYAsuAc)
    - [Starfield Modding](https://discord.gg/6R4Yq5KjW2)

([TOC](#table-of-contents))
