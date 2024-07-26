Ship Vendor Framework
=====================
by rux616

Version: 1.0.0

Table Of Contents
-----------------
- Ship Vendor Framework
    - Table Of Contents
- Overview
    - Summary
    - How To (Lite)
    - Compatibility
    - Known Issues
    - NPC Ship Lists
- Installation
    - Requirements
    - Recommendations
    - Upgrading
    - Mod Manager
    - Manual
    - Archive Invalidation
- License
- Credits and Acknowledgements
- Contact


Overview
========

Summary
-------
(A framework to easily add ships for sale without conflicts.)

The system that Bethesda designed for selling ships is interesting, but it lacks a crucial element: Changeability. In vanilla Starfield, once a ship vendor has been loaded the first time, the list of ships they offer for sale is locked in forever.

That's where this mod comes in. I've designed a system such that mod authors can easily add ships for sale to the various ship vendors without either conflicting with other mods that do the same or requiring the set up of a script. It will also refresh the vendor's list of ships if a change is detected in the vendor's "always" or "unique" lists. (A ship vendor's inventory is composed of three lists: always a.k.a. priority, random, and unique.)

NOTE: The "random" ships are only regenerated every 7 days (by default).

How To (Lite)
-------------
Mod authors, want to use the framework? It's easy, and you can do it in just three steps:

1. Design your ship.
2. Add your ship to a leveled base form.
3. Put that leveled base form into a form list and set one of the form lists included with this mod (SVF_ShipVendorList_*) as the target in the "add to list" box.

More detailed instructions are included in the HOWTO.txt document, and in the "How to Utilize the Ship Vendor Framework" article (https://www.nexusmods.com/starfield/articles/624) on Nexus Mods.

Compatibility
-------------
This mod alters NPCs that offer ship services, as well as some of the leveled lists for spaceships that vendors use. Any other mods that also alter those objects may conflict without patches.

Known Issues
------------
None

NPC Ship Lists
--------------
Note: All form list editor IDs start with "SVF_ShipVendorList_". This prefix has been removed from the lists as presented in the following table for sake of brevity.

| NPC                                             | Always List                    | Random List                      | Unique List                    |
|-------------------------------------------------|--------------------------------|----------------------------------|--------------------------------|
| Havershaw (Stroud-Eklund Staryard)              | Location_StroudStaryard_Always | Manufacturer_Stroud              | Location_StroudStaryard_Unique |
| Inaya Rehman (HopeTech HQ)                      | Location_HopeTechHQ_Always     | Manufacturer_HopeTech            | Location_HopeTechHQ_Unique     |
| Jasmine Durand (The Key)                        | Location_KeyThe_Always         | Faction_CrimsonFleet             | Location_KeyThe_Unique         |
| Lon Anderssen (Red Mile)                        | Location_RedMile_Always        | Faction_Unaffiliated_BlackMarket | Location_RedMile_Unique        |
| Nikau Henderson (Deimos Staryard)               | Location_DeimosStaryard_Always | Manufacturer_Deimos              | Location_DeimosStaryard_Unique |
| Player Outpost Shipbuilder                      | Location_PlayerOutpost_Always  | Collection_Generic               | Location_PlayerOutpost_Unique  |
| Ship Services Technician (Akila City)           | Location_AkilaCity_Always      | Faction_FreestarCollective       | Location_AkilaCity_Unique      |
| Ship Services Technician (Cydonia)              | Location_Cydonia_Always        | Faction_UnitedColonies_Limited   | Location_Cydonia_Unique        |
| Ship Services Technician (Eleos Retreat)        | Location_EleosRetreat_Always   | Faction_Unaffiliated_Limited     | Location_EleosRetreat_Unique   |
| Ship Services Technician (Gagarin)              | Location_Gagarin_Always        | Faction_UnitedColonies_Limited   | Location_Gagarin_Unique        |
| Ship Services Technician (HopeTown)             | Location_HopeTown_Always       | Faction_FreestarCollective       | Location_HopeTown_Unique       |
| Ship Services Technician (Neon)                 | Location_Neon_Always           | Faction_Unaffiliated_Full        | Location_Neon_Unique           |
| Ship Services Technician (New Atlantis)         | Location_NewAtlantis_Always    | Faction_UnitedColonies_Full      | Location_NewAtlantis_Unique    |
| Ship Services Technician (New Homestead)        | Location_NewHomestead_Always   | Faction_UnitedColonies_Limited   | Location_NewHomestead_Unique   |
| Ship Services Technician (Paradiso)             | Location_Paradiso_Always       | Faction_Unaffiliated_Full        | Location_Paradiso_Unique       |
| Ship Services Technician (Red Devils HQ)        | Location_RedDevilsHQ_Always    | Faction_UnitedColonies_Limited   | Location_RedDevilsHQ_Unique    |
| Ship Services Technician (The Clinic)           | Location_ClinicThe_Always      | Faction_FreestarCollective       | Location_ClinicThe_Unique      |
| Ship Services Technician (The Den)              | Location_DenThe_Always         | Faction_UnitedColonies_Limited   | Location_DenThe_Unique         |
| Stroud Kiosk Vendor (Stroud-Eklund Store, Neon) | Location_StroudStore_Always    | Manufacturer_Stroud              | Location_StroudStore_Unique    |
| Veronica Young (Taiyo Store, Neon)              | Location_TaiyoStore_Always     | Manufacturer_Taiyo               | Location_TaiyoStore_Unique     |


Installation
============

Requirements
------------
None

Recommendations
---------------
None

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

Mod Manager
-----------
Download and install the archive with either Mod Organizer 2 (https://github.com/ModOrganizer2/modorganizer/releases) (version 2.5.0 or later) or Vortex (https://www.nexusmods.com/site/mods/1). I personally recommend Mod Organizer 2 (with the optional Root Builder (https://kezyma.github.io/?p=rootbuilder) plugin to use with SFSE or any other mod that requires files be put directly in the game's installation folder).

Manual
------
Unsupported.

Archive Invalidation
--------------------
Make sure your `StarfieldCustom.ini` file in the "Documents\My Games\Starfield" folder (or your profile folder if using a mod manager and profiles) contains the following:

    [Archive]
    bInvalidateOlderFiles=1
    sResourceDataDirsFinal=


License
=======
- All code files are copyright 2024 Dan Cassidy, and are licensed under the GPL v3.0 or later (https://www.gnu.org/licenses/gpl-3.0.en.html). The sole exceptions to this are the "ShipVendorScript.psc" and "OutpostShipbuilderMenuActivator.psc" files, as they are built upon the base that BGS provided and so are covered by their licenses.
- All non-code files are copyright 2024 Dan Cassidy, and are licensed under the CC BY-NC-SA 4.0 (https://creativecommons.org/licenses/by-nc-sa/4.0/) license.


Credits and Acknowledgements
============================
ElminsterAU: For xEdit and BSArch
Mod Organizer 2 team: For Mod Organizer 2
Nexus Mods: For mod hosting and for the Vortex Mod Manager
Noggog: For Spriggit


Contact
=======
If you find a bug or have a question about the mod, please post it on the mod page at Nexus Mods (https://www.nexusmods.com/starfield/mods/10057), or in the GitHub project (https://github.com/rux616/starfield-ship-vendor-framework).

If you need to contact me personally, I can be reached through one of the following means:
- Nexus Mods: rux616 (https://www.nexusmods.com/users/124191) (Send a message via the "CONTACT" button.)
- Email: rux616-at-pm-dot-me (replace `-at-` with `@` and `-dot-` with `.`)
- Discord: rux616 (user ID 234489279991119873) - make sure to "@" me
    - Lively's Modding Hub (https://discord.gg/livelymods)
    - Nexus Mods (https://discord.gg/nexusmods)
    - Collective Modding (https://discord.gg/pF9U5FmD6w) ("🔧-chaotic-cognitions" channel)
    - Starfield Modding (https://discord.gg/6R4Yq5KjW2)
