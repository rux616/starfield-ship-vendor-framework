Version: 1.7.0

Summary
-----
The system that Bethesda designed for selling ships is interesting, but it lacks a crucial element: Changeability. In vanilla Starfield, once a ship vendor has been loaded the first time, the list of ships they offer for sale is locked in forever until starting a new game (or new game plus).

That's where this mod comes in. I've designed a system such that mod authors can easily add ships for sale to the various ship vendors without either conflicting with other mods that do the same or requiring the set up of a script. It will also refresh the vendor's list of ships if a change is detected in the vendor's "always" or "unique" lists. (A ship vendor's inventory is composed of three lists: always a.k.a. priority, random, and unique.)

**NOTE:** Vendors refresh their ship inventory every 7 days by default.

Detailed instructions are included in the "How to Utilize the Ship Vendor Framework" article (https://www.nexusmods.com/starfield/articles/624) on Nexus Mods.

This is a limited version of the README. The full version can be found at the mod's page on Nexus Mods (https://www.nexusmods.com/starfield/mods/10057), or in the GitHub project (https://github.com/rux616/starfield-ship-vendor-framework).

Load Order
-----
For best results, put this mod last in your load order, followed by other mods that have it as a master.

For patches, the load order should be as follows:
- ShipVendorFramework.esm
- (SVF Expansion Patches, if any)
- (SVF Capability Patches, if any)
- (SVF Compatibility Patches, if any)

Compatibility
-----
This mod alters most of the leveled lists for spaceships that vendors use to add proper level gates, as well as the `CF_Post` dialogue `[QUST:00143472]` and `CF_Post_Toft_TL_ShipServices` scene `[SCEN:001F88DD]` to allow for Lt. Jillian Toft to function as a ship vendor once the Crimson Fleet quest line concludes. Any other mods that also alter those records may conflict without patches.

Additionally, this mod alters 4 vanilla scripts, "OutpostShipbuilderMenuActivator", "ShipBuilderMenuActivator", "ShipVendorInfoScript", and "ShipVendorScript". As a result, a mod that alters any of those scripts will conflict by definition. This also means that when the game is updated, script changes by Bethesda will not be present in this mod until it is updated.

Mods that are known to conflict:
- "DarkStar" by WykkydGaming [Creations (https://creations.bethesda.net/en/starfield/details/f082c443-5f3e-4528-b03e-10c319d01ddf/DarkStar)]: No patch. There are no lists for mod authors to add ships to, the "Rich Ship Vendors" option doesn't work with the DarkStar ship vendors, and not all ships may be immediately available to purchase if the "buy ships" option is accessed too soon after the vendor's ship inventory is refreshed or the vendor is initially created.
- "Rich Outpost Shipbuilder" by LilithMotherOfAll [[Nexus](https://www.nexusmods.com/starfield/mods/5492)]: No patch. Uninstall this mod if you have it. Ship Vendor Framework now has this functionality built in.
- "Starvival" by lKocMoHaBTl [Creations (https://creations.bethesda.net/en/starfield/details/cb70aedd-4793-4e05-be51-b5a4987d6b71/Starvival___Immersive_Survival_Addon) / Nexus (https://www.nexusmods.com/starfield/mods/6890)]: Use SVF Compatibility Patch - Starvival.

Mods that I have created capability patches for:
- "DarkStar Astrodynamics" by WykkydGaming [Creations (https://creations.bethesda.net/en/starfield/details/cfca357a-7226-4cae-bd16-3575069dcf2e/DarkStar_Astrodynamics) / Nexus (https://www.nexusmods.com/starfield/mods/9458)]
- "Dominion" by rhart317 [Creations (https://creations.bethesda.net/en/starfield/details/97f792d0-d078-4a50-aa32-f03cc054e241/Dominion)]
- "Falkland Systems Ship Services" by Hjalmere [Creations (https://creations.bethesda.net/en/starfield/details/6cbf2c64-b736-4d95-bf06-38183a94b359/Falkland_Systems_Ship_Services)]
- "Iconic Ships" by ShipTechnician [Creations (https://creations.bethesda.net/en/starfield/details/569e938e-228c-42fb-91ba-c6967575bcf3/Iconic_Ships)]
- "L-K Ships" by Lighthorse and KeithVSmith1977 [Creations (https://creations.bethesda.net/en/starfield/details/f287801b-a863-48fb-b796-1eeaeda4eab3/L_K_Ships) / Nexus (https://www.nexusmods.com/starfield/mods/7433)]
- "Lower Landing Pad" by SenterPat [Nexus (https://www.nexusmods.com/starfield/mods/8363)]
- "Outpost Shipbuilder Unlocked ESM" by goldenchrome [Nexus (https://www.nexusmods.com/starfield/mods/5667)]
- "Outpost Vendor New Ships" by nefurun [Creations (https://creations.bethesda.net/en/starfield/details/b5723c97-fb67-46ed-9833-07d4e1d8ced1/Outpost_Vendor_New_Ships)]
- "SGC Deadalus & Battlestar added to New Atlantis & Outpost Ship Vendor" by Rechi03 [Creations (https://creations.bethesda.net/en/starfield/details/0993fb17-f960-4869-b417-485d129567f8/SGC_Deadalus__amp__Battlestar_added_to_New_Atlanti)]
- "The Den Astrodynamics" by VoodooChild [Nexus (https://www.nexusmods.com/starfield/mods/8809)]
- "Watchtower" by kinggath_creations [Creations (https://creations.bethesda.net/en/starfield/details/5d455df7-d99f-4619-a383-f2b39aa21e00/Watchtower__Orbital_Strike__Fleet_Command)]

Known Issues
-----
None

Requirements
-----
None

Enabling Logs
-----
**NOTE:** This section only applies to PC users.

In your StarfieldCustom.ini file, make sure you have the following section:

    [Papyrus]
    bEnableLogging=1
    bEnableProfiling=1
    bEnableTrace=1
    bLoadDebugInformation=1

This will ensure that the game writes logs. If I request them in order to help you, I will be looking for "Papyrus.X.log" in the "%UserProfile%\Documents\My Games\Starfield\Logs" directory, and "ShipVendorFramework.X.log" in the "%UserProfile%\Documents\My Games\Starfield\Logs\Script\User" directory, where "X" represents a number 0-3.


Credits and Acknowledgements
-----
Bethesda Game Studios: For Starfield itself and the Starfield Creation Kit
ElminsterAU: For xEdit and BSArch
Lively: For helping explain some of the odd nuances of an infrequently-used-by-me FOMOD feature
Mod Organizer 2 team: For Mod Organizer 2
Nexus Mods: For mod hosting and for the Vortex Mod Manager
Noggog: For Spriggit
perchik71: For Creation Kit Platform Extended
Scrivener07: For some advice and clarification on papyrus matters


Contact
-----
If you find a bug or have a question about the mod, please post it on the mod page at Nexus Mods (https://www.nexusmods.com/starfield/mods/10057), the GitHub project (https://github.com/rux616/starfield-ship-vendor-framework), or on Reddit in r/StarfieldMods (https://www.reddit.com/r/starfieldmods/) (make sure to tag me: u/rux616).

If you need to contact me personally, I can be reached through one of the following means:
- **Nexus Mods**: rux616 (https://www.nexusmods.com/users/124191) (Click the "Message" button.)
- **Email**: rux616-at-pm-dot-me (replace `-at-` with `@` and `-dot-` with `.`)
- **Reddit**: u/rux616
- **Discord**: rux616 (user ID 234489279991119873) - make sure to "@" me
    - Lively's Modding Hub (https://discord.gg/livelymods)
    - Nexus Mods (https://discord.gg/nexusmods)
    - Collective Modding (https://discord.gg/pF9U5FmD6w) ("🔧-chaotic-cognitions" channel)
    - Starfield - Ship Distribution (https://discord.gg/wuvaYAsuAc)
    - Starfield Modding (https://discord.gg/6R4Yq5KjW2)
