# notes

## general flow
- load
- check flst
    - can i use some sort of checksum to see if it's changed since last loading?
- process flst
    - FLST should consist of either SpaceshipBase or other FLST records
        - if SpaceshipBase
            - should have a SVF_Level_* keyword (if none, then level 1)
            - should have at least 1 SVF_Vendor_* keyword (if none, ...?)
            - can have one or more SVF_Special_*
    - add things to those ACTI objects
    - ~~trigger inventory refresh for affected vendors~~
    -


how ship vendors currently work
ships to be sold is an array of ShipVendorListScript:ShipToSell structs consisting of a leveled base form and a minimum level
this array lives on a number of ACTI objects and is designated as "const", so in-game changes aren't saved
the ShipVendorScript script reads these ACTI objects _once_ upon initialization and copies that array to an internal array
there're a few functions that then set up the ships for sale, populate another array, etc.


things to investigate:
- how do custom outpost ship vendors work?

List of vanilla ship vendors:

| EditorID                    |     FormID      | Location                                     |
|-----------------------------|:---------------:|----------------------------------------------|
| CF_JasmineDurand            | `NPC_:0001539E` | The Key                                      |
| HT_InayaRehman              | `NPC_:0028ACA7` | Hope Town, HopeTech HQ                       |
| NeonStroudStore_KioskVendor | `NPC_:00151488` | Neon, Stroud-Ecklund Showroom                |
| OutpostShipbuilderVendor    | `NPC_:0002F8FD` | Player Outpost (Dynamic)                     |
| RM_LonAnderssen             | `NPC_:002B2BEC` | Red Mile, Main Building                      |
| SFBGS001_HV_DumarHasadi     | `NPC_:xx0470E4` | Dazra [Shattered Space]                      |
| ShipServices_AkilaCity      | `NPC_:002A0EA1` | Akila City, Spaceport                        |
| ShipServices_Cydonia        | `NPC_:00206704` | Mars, Cydonia Spaceport                      |
| ShipServices_EleosRetreat   | `NPC_:000D87A4` | Eleos Retreat                                |
| ShipServices_Gagarin        | `NPC_:0015CF3D` | Gagarin Spaceport                            |
| ShipServices_HopeTown       | `NPC_:001FE736` | Hope Town                                    |
| ShipServices_Neon           | `NPC_:002A0EA3` | Neon, Spaceport                              |
| ShipServices_NewAtlantis    | `NPC_:0005C81C` | Jemison, New Atlantis Spaceport              |
| ShipServices_NewHomestead   | `NPC_:00146DCA` | New Homestead                                |
| ShipServices_Paradiso       | `NPC_:0015D3C6` | Paradiso                                     |
| ShipServices_RHQ            | `NPC_:00064EE9` | Mars, (Red Devils HQ Exit)                   |
| ShipServices_TheClinic      | `NPC_:002A0E9F` | The Clinic                                   |
| ShipServices_TheDen         | `NPC_:002A0EA0` | Wolf, The Den                                |
| Staryard_Havershaw          | `NPC_:0027A98F` | Stroud-Eklund Staryard                       |
| Staryard_NikauHenderson     | `NPC_:0027A992` | Mars, Orbit, Deimos Staryard                 |
| Staryard_VeronicaYoung      | `NPC_:0027A98C` | Neon, Ryujin Enterprises, Taiyo Astroneering |

NPC Form List

| NPC                                             | Always List                    | Random List                      | Unique List                    |
|-------------------------------------------------|--------------------------------|----------------------------------|--------------------------------|
| Dumar Hasadi (Dazra) \*                         | Location_Dazra_Always          | Collection_Generic2              | Location_Dazra_Unique          |
| Havershaw (Stroud-Eklund Staryard)              | Location_StroudStaryard_Always | Manufacturer_Stroud              | Location_StroudStaryard_Unique |
| Inaya Rehman (HopeTech HQ)                      | Location_HopeTechHQ_Always     | Manufacturer_HopeTech            | Location_HopeTechHQ_Unique     |
| Jasmine Durand (The Key)                        | Location_KeyThe_Always         | Faction_CrimsonFleet             | Location_KeyThe_Unique         |
| Lon Anderssen (Red Mile)                        | Location_RedMile_Always        | Faction_Unaffiliated_BlackMarket | Location_RedMile_Unique        |
| Lt. Jillian Toft (UC Vigilance) \*\*            | Location_UCVigilance_Always    | Faction_CrimsonFleet             | Location_UCVigilance_Unique    |
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
| Stroud Kiosk Vendor (Neon, Stroud-Eklund Store) | Location_StroudStore_Always    | Manufacturer_Stroud              | Location_StroudStore_Unique    |
| Veronica Young (Neon, Taiyo Store)              | Location_TaiyoStore_Always     | Manufacturer_Taiyo               | Location_TaiyoStore_Unique     |

\* Shattered Space
\*\* Must complete Crimson Fleet quest line first

| NPC                         | Always List                                | Random List                                | Unique List                                |
|-----------------------------|--------------------------------------------|--------------------------------------------|--------------------------------------------|
| Falkland Sales Rep          | Location_FalklandSystemsNewAtlantis_Always | Location_FalklandSystemsNewAtlantis_Random | Location_FalklandSystemsNewAtlantis_Unique |
| Falkland Systems Ship Kiosk | Location_FalklandSystemsNewAtlantis_Always | Location_FalklandSystemsNewAtlantis_Random | Location_FalklandSystemsNewAtlantis_Unique |

| NPC                      | Always List                      | Random List                      | Unique List                      |
|--------------------------|----------------------------------|----------------------------------|----------------------------------|
| DSA Shipbuilding Console | Mod_DarkStarAstrodynamics_Always | Mod_DarkStarAstrodynamics_Random | Mod_DarkStarAstrodynamics_Unique |

| NPC     | Always List                   | Random List                    | Unique List                   |
|---------|-------------------------------|--------------------------------|-------------------------------|
| B.A.B.S | Location_StardockAlpha_Always | Faction_UnitedColonies_Limited | Location_StardockAlpha_Unique |

game option pretty ordering (vanilla):
- Akila City Ship Services
- Cydonia Ship Services
- Eleos Retreat Ship Services
- Gagarin Ship Services
- Havershaw
- HopeTown Ship Services
- Inaya Rehman
- Jasmine Durand
- Lon Anderssen
- Lt. Jillian Toft
- Neon Ship Services
- New Atlantis Ship Services
- New Homestead Ship Services
- Nikau Henderson
- Outpost Shipbuilder
- Paradiso Ship Services
- Red Devils HQ Ship Services
- Stroud-Eklund Neon Kiosk
- The Clinic Ship Services
- The Den Ship Services
- Veronica Young


## NPC Script Differences (outside of ship lists)
0x002a0ea0 Ship Services Technician (The Den):
- BuysShips: False -> (removed - defaults to True)
- SellsShips: False -> (removed - defaults to True)
- ShipsForSaleMax: (removed - defaults to 8) -> 2
- ShipsForSaleMin: (removed - defaults to 4) -> 1
0x002a0e9f Ship Services Technician (The Clinic):
- BuysShips: False -> (removed - defaults to True)
- SellsShips: False -> (removed - defaults to True)
- ShipsForSaleMax: (removed - defaults to 8) -> 1
- ShipsForSaleMin: (removed - defaults to 4) -> 0
0x00064ee9 Ship Services Technician (Red Devils HQ)
- BuysShips: False -> (removed - defaults to True)
- SellsShips: False -> (removed - defaults to True)
- ShipsForSaleMax: (removed - defaults to 8) -> 1
- ShipsForSaleMin: (removed - defaults to 4) -> 0
0x0002f8fd Outpost Ship Builder:
- ShipsForSaleMin: 4 -> (removed - defaults to 4)
0x0001539e Jasmine Durand (The Key):
- BuysShips: True -> (removed - defaults to True)
- SellsShips: True -> (removed - defaults to True)
- ShipsForSaleMax: (removed - defaults to 8) -> 6
- ShipsForSaleMin: 6 -> (removed - defaults to 4)

how to deal with these? could create a custom override system based on formlists. `BuysShips` and `SellsShips` can't be included in the form lists because those variables are used by some dialog checks directly

use gameplayoption forms
- [svf]
    - rich ship vendors
    - debug logging (?)
    - allow unique ships to regenerate
    - random ships for sale:
        - min: choice of 0, 1, 2, ..., 32 (all vendors)
        - max: choice of 0, 1, 2, ..., 32 (all vendors)


## how uniques should work v2
general:
- player loads into area where a vendor has a unique for sale
- script checks to see if it should refresh inventory
    - if the inventory should be refreshed
        - if the vendor has a unique LVLB in their inventory that matches an entry in the tracking array:
            - remove (and nuke) that REF
        - if the vendor does not have a unique LVLB in their inventory that matches an entry in the tracking array, but wants to generate one:
            - block generation of that LVLB
        - if the vendor has a unique LVLB that they want to generate that does not match an entry in the tracking array:
            - do so
        - if the vendor has a unique LVLB in inventory that
buying:
-
selling:
- player loads into area where a vendor is located
- script checks to see if it should refresh inventory
- script looks at unique LVLB/REF tracking array
    - if the vendor has a unique LVLB in their inventory that matches an entry in the tracking array:
        - remove (and nuke) that REF
    - if the vendor does not have a unique LVLB in their inventory that matches an entry in the tracking array, but wants to generate one:
        - block generation of that LVLB
    - if the vendor has a unique LVLB that they want to generate that does not match an entry in the tracking array:
        - do so


## starting script states
ship services actors can have a number of starting states when SVF is installed, consisting of "origin", "state", and "override"

"origin" possibilities: "vanilla", "dlc", or "mod"
"state" possibilities: "initialized" or "uninitialized"
"override status" possibilities: "not overridden at all", "overridden with SVF changes", "overridden with SVF changes _not_ forwarded"

"origin" doesn't really matter, since a mod is a mod is a mod
"state" matters a _lot_
"override status" also matters a lot. if SVF changes are overridden and not forwarded (effectively removed), then the new formlists aren't going to be used. for vanilla records, can probably have a call back to the quest script for them to populate the properties. probably also for dlc-added records too. mod-added isn't practical. can probably use a const struct (actor, always_list, random_list, never_list)


## scenarios to test when SVF installed
kiosk vendor not initialized at all
kiosk vendor already initialized
kiosk vendor already initialized and loaded
outpost vendor created
outpost vendor already initialized
outpost vendor already initialized and loaded
standard vendor not initialized at all
standard vendor already initialized
standard vendor already initialized and loaded


## voice lines for toft

| original ID | text                                  |  mod ID  |
|:-----------:|---------------------------------------|:--------:|
|  0034D418   | All right, let's see what you need.   | 0009D5C6 |
|  00694785   | Let's see what we can do for you.     | 005BC37C |
|  000AF511   | We'll do our best to accommodate you. | 004BE129 |


## possible method for getting container for vendor

part 1:
- make SVF_VendorData_*_Container form lists
- add the object reference (if one exists) to that form list for each vendor

part 2:
- expand "ShipVendorDataMap" with another member "VendorContainer" or something like that
- expand vendor data map function in svf_control to also give container
- add a function or property to get the container in ShipVendorScript
- check the new ShipVendorScript function from inside ShipVendorInfoScript/ShipbuilderMenuActivator/OutpostShipbuilderActivator scripts to get the container (None means use the actor)

procedure to add ref to form list:
- open form list
- find ref in cell view
- drag ref to form list (the ref will not show up, this is normal)
- in form list window, click the "paste selected element" button (or right click -> paste)

note: might need to change RHQ ship services tech, as its container is gagarin's
