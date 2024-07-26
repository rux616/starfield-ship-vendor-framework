# To Do List

- [-] remove [LShip_Vendor_BlackMarket_Trader_A_Cargo_Railstar (LVLB:00086ECE)] from either RedMile_Always or BlackMarket_Random
    - no need, ShipVendorScript automatically removes duplicates during generation
- [-] remove [LShip_Vendor_Stroud_B_Privateer (LVLB:001EAA83)] from either [ShipVendorList_Staryard_Stroud_Random (ACTI:001F7679)] or [ShipVendorList_Staryard_Stroud_Always (ACTI:001F7680)]
    - no need, ShipVendorScript automatically removes duplicates during generation
- [X] add unique dataset to [NeonStroudStore_KioskVendor (NPC_:00151488)]
- [X] check that condition functions on Hammerhead/Falcon (Taiyo - Veronic Young) and Phalanx/Hoplite (Deimos - Nikau Henderson) work for low levels
- [X] check stroud privateer leveled ship base to see if it needs special lvl1 handling
- [X] clear out formlist 0x003 after testing
- [X] add version in SVF_Control.psc to version updater schema
- [X] add licensing to top of scripts
- [X] make it so that purchased unique ships are removed from the uniques list BEFORE the random list is de-duped
