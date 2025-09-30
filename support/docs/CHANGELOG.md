Ship Vendor Framework
=====================

Table Of Contents
-----------------
- [Ship Vendor Framework](#ship-vendor-framework)
    - [Table Of Contents](#table-of-contents)
- [Changelog](#changelog)
    - [v1.6.1](#v161)
    - [v1.6.0](#v160)
    - [v1.5.4](#v154)
    - [v1.5.3](#v153)
    - [v1.5.2](#v152)
    - [v1.5.1](#v151)
    - [v1.5.0](#v150)
    - [v1.4.0](#v140)
    - [v1.3.1](#v131)
    - [v1.3.0](#v130)
    - [v1.2.0](#v120)
    - [v1.1.1](#v111)
    - [v1.1.0](#v110)
    - [v1.0.1](#v101)
    - [v1.0.0](#v100)


Changelog
=========

v1.6.1
------
- Fixed DarkStar Astrodynamics and The Den Astrodynamics patches always being initially selected in FOMOD installer
- Fixed Markdown image to BBCode image conversion regex

([TOC](#table-of-contents))

v1.6.0
------
Main mod:
- Implemented a "Vendor Data Map" concept to allow the mod to be as conflict-free as possible, and as a result, was able to remove all direct vendor record edits
- Set Lt. Jillian Toft on the Vigilance to function as a ship vendor once the Crimson Fleet quest line concludes (modifies `CF_Post` dialogue `[QUST:00143472]` and `CF_Post_Toft_TL_ShipServices` scene `[SCEN:001F88DD]`)
- Added a gameplay option to allow unique ships to regenerate after purchase, instead of being a one-and-done thing
- Added a "Rich Ship Vendors" gameplay option; the amount of credits ship vendors have is controlled by a different gameplay option
- Added gameplay options to control the minimum and maximum number of ships in the "random" category that a ship vendor will attempt to sell
- Added more variable caching to try and minimize calls to potentially expensive external functions
- Added sanity checks (with messages if they fail) to support new conflict-free methodologies and records
- Added a toast-style message that pop up if a ship vendor is accessed before it's ready and another toast-style message that will then pop up when the vendor is ready
- Changed how the unique ships are tracked so that they are tracked across vendors
- Made a pass for style consistency in all scripts
- Updated auxiliary scripts to use their own internal logging function
- Added many comments to the code to clarify things where needed and to make certain bits of logic (hopefully) easier to follow
- Removed OnInit event code from SVF_Control script to clean things up
- Made sure that all calls to local _Log function have a log level specified
- Re-worked log levels to function more like other languages
- Fixed an issue where ShipVendorScript could attempt to register for a remote event on a variable that was None.

Patches:
- Added DarkStar Astrodynamics patch
- Updated Falkland Systems Ship Services patch to utilize the "Vendor Data Map" concept
- Updated Lower Landing Pad patch to utilize the "Vendor Data Map" concept
- Updated Shattered Space patch to utilize the "Vendor Data Map" concept
- Updated Starvival patch
- Fixed The Den Astrodynamics patch to remove a couple of mistakenly-added ships
- Removed no-longer-necessary "Generic" compatibility patches
- Removed no-longer-necessary Lower Landing Pad (Unlocked) patch

Miscellaneous:
- Updated README
- Updated HOWTO with sections on configuring a vendor to use Ship Vendor Framework lists, both using the "Vendor Data Map" concept, and direct
- Updated spelling list

([TOC](#table-of-contents))

v1.5.4
------
- Fixed master file reference in the SVF Starvival Patch to the newly-renamed SVF Shattered Space patch

([TOC](#table-of-contents))

v1.5.3
------
- Fixed misnamed plugin reference in FOMOD file

([TOC](#table-of-contents))

v1.5.2
------
- Renamed the Shattered Space patch (plugins with filenames ending in "ShatteredSpace.esm" apparently get disappeared from the Creations Load Order screen as of patch 1.15.216)

([TOC](#table-of-contents))

v1.5.1
------
- Fixed The Den Astrodynamics compatibility patch

([TOC](#table-of-contents))

v1.5.0
------
- Updated Starvival patch to be compatible with Starvival v10.5.0

([TOC](#table-of-contents))

v1.4.0
------
- Added Shattered Space patches
- Fixed some initialization bugs with kiosk vendors, including outpost vendors
- Fixed some ship vendors constantly regenerating their ships
- Updated Starvival compatibility patch to be compatible with Starvival v10.1.5
- Re-saved all plugin files in newest CK to fix some potential internal file structure weirdness

([TOC](#table-of-contents))

v1.3.1
------
- Update verbiage in FOMOD files to match readme

([TOC](#table-of-contents))

v1.3.0
------
- Updated Starvival compatibility patch for Starvival v8
- Updated some backend stuff (spriggit, helper scripts, etc.)

([TOC](#table-of-contents))

v1.2.0
------
- Small update to make troubleshooting Ship Vendor Framework a bit easier

([TOC](#table-of-contents))

v1.1.1
------
- Fixed issue where internal array was getting populated by SpaceshipReference objects referencing None
- Fixed issue where if the player purchased a ship from a vendor's "always" list, the vendor would always reset that list the next time it was loaded, instead of when the vendor was scheduled to reset
- Fixed issue where vendor could remain registered for OnPlayerLoadGame event even if not actually loaded
- Fixed issue where ships could be spuriously duplicated in the vendor menu by forcing a full (instead of partial) vendor refresh when a new ship is added to either of the vendor's "always" or "unique" lists
- Mitigated a potential race condition when vendor gets loaded
- Added patch for [Nexus] The Den Astrodynamics

([TOC](#table-of-contents))

v1.1.0
------
- Added patches for the following mods (note: some of these may require a generic patch as well for full functionality)
    - [Creations] Deadalus and Battlestar
    - [Creations] Dominion
    - [Creations] Iconic Ships
    - [Creations/Nexus] L-K Ships
    - [Nexus] Lower Landing Pad
    - [Creations] Outpost Vendor New Ships
    - [Creations/Nexus] Starvival (Spaceship Systems Module)
- Added generic patches
    - All Ship Modules Unlocked (All Ship Vendors)
    - All Ship Modules Unlocked (Outpost Only)
    - Ship Vendors

([TOC](#table-of-contents))

v1.0.1
------
- Updated documentation

([TOC](#table-of-contents))

v1.0.0
------
- Initial release

([TOC](#table-of-contents))
