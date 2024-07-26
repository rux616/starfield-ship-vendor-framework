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
- Neon [ShipServices_Neon (NPC_:002A0EA3)]
- Taiyo [Staryard_VeronicaYoung (NPC_:0027A98C)]
- Akila City [ShipServices_AkilaCity (NPC_:002A0EA1)]

| EditorID                    |     FormID      | Location                                     |
|-----------------------------|:---------------:|----------------------------------------------|
| CF_JasmineDurand            | `NPC_:0001539E` | The Key                                      |
| HT_InayaRehman              | `NPC_:0028ACA7` | Hope Town, HopeTech HQ                       |
| NeonStroudStore_KioskVendor | `NPC_:00151488` | Neon, Stroud-Ecklund Showroom                |
| OutpostShipbuilderVendor    | `NPC_:0002F8FD` | Player Outpost (Dynamic)                     |
| RM_LonAnderssen             | `NPC_:002B2BEC` | Red Mile, Main Building                      |
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


## starting script states
ship services actors can have a number of starting states when SVF is installed, consisting of "origin", "state", and "override"

"origin" possibilities: "vanilla", "dlc", or "mod"
"state" possibilities: "initialized" or "uninitialized"
"override status" possibilities: "not overridden at all", "overridden with SVF changes", "overridden with SVF changes _not_ forwarded"

"origin" doesn't really matter, since a mod is a mod is a mod
"state" matters a _lot_
"override status" also matters a lot. if SVF changes are overridden and not forwarded (effectively removed), then the new formlists aren't going to be used. for vanilla records, can probably have a call back to the quest script for them to populate the properties. probably also for dlc-added records too. mod-added isn't practical. can probably use a const struct (actor, always_list, random_list, never_list)
