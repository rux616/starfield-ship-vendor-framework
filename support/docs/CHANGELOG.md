Ship Vendor Framework
=====================

Table Of Contents
-----------------
- [Ship Vendor Framework](#ship-vendor-framework)
    - [Table Of Contents](#table-of-contents)
- [Changelog](#changelog)
    - [v1.3.0](#v130)
    - [v1.2.0](#v120)
    - [v1.1.1](#v111)
    - [v1.1.0](#v110)
    - [v1.0.1](#v101)
    - [v1.0.0](#v100)


Changelog
=========

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
