Version: 1.5.0

Summary
-----
The system that Bethesda designed for selling ships is interesting, but it lacks a crucial element: Changeability. In vanilla Starfield, once a ship vendor has been loaded the first time, the list of ships they offer for sale is locked in forever until starting a new game (or new game plus).

That's where this mod comes in. I've designed a system such that mod authors can easily add ships for sale to the various ship vendors without either conflicting with other mods that do the same or requiring the set up of a script. It will also refresh the vendor's list of ships if a change is detected in the vendor's "always" or "unique" lists. (A ship vendor's inventory is composed of three lists: always a.k.a. priority, random, and unique.)

NOTE: The "random" ships are only regenerated every 7 days (by default).

Detailed instructions are included in the "How to Utilize the Ship Vendor Framework" article (https://www.nexusmods.com/starfield/articles/624) on Nexus Mods.

This is a limited version of the README. The full version can be found at the mod's page on Nexus Mods (https://www.nexusmods.com/starfield/mods/10057), or in the GitHub project (https://github.com/rux616/starfield-ship-vendor-framework).

Load Order
-----
For best results, put this mod last in your load order, followed by other mods that have it as a master.

For patches, the load order should be as follows:
- ShipVendorFramework.esm
- (SVF Capability Patches, if any)
- (SVF Generic Patches, if any)
- (SVF Compatibility Patches, if any)

Compatibility
-----
This mod alters NPCs that offer ship services, as well as some of the leveled lists for spaceships that vendors use. Any other mods that also alter those objects may conflict without patches.

Additionally, this mod alters 3 vanilla scripts, "OutpostShipbuilderMenuActivator", "ShipBuilderMenuActivator", and "ShipVendorScript". As a result, any other mod that alters any of those scripts by definition will conflict. This also means that when the game is updated, script changes by Bethesda will not be present in this mod until it is updated.

Mods that are known to conflict:
- "SGC Deadalus & Battlestar added to New Atlantis & Outpost Ship Vendor" by Rechi03 [Creations (https://creations.bethesda.net/en/starfield/details/0993fb17-f960-4869-b417-485d129567f8/SGC_Deadalus__amp__Battlestar_added_to_New_Atlanti)]: Use SVF Capability Patch - Daedalus and Battlestar and one of the SVF Generic Patches that fits what you need.
- "Dominion" by rhart317 [Creations (https://creations.bethesda.net/en/starfield/details/97f792d0-d078-4a50-aa32-f03cc054e241/Dominion)]: Use SVF Capability Patch - Dominion.
- "Iconic Ships" by ShipTechnician [Creations (https://creations.bethesda.net/en/starfield/details/569e938e-228c-42fb-91ba-c6967575bcf3/Iconic_Ships)]: Use SVF Capability Patch - Iconic Ships, and one of the SVF Generic Patches that fits what you need.
- "L-K Ships" by Lighthorse and KeithVSmith1977 [Creations (https://creations.bethesda.net/en/starfield/details/f287801b-a863-48fb-b796-1eeaeda4eab3/L_K_Ships) / Nexus (https://www.nexusmods.com/starfield/mods/7433)]: Use SVF Capability Patch - L-K Ships.
- "Lower Landing Pad" by SenterPat [Nexus (https://www.nexusmods.com/starfield/mods/8363)]: Use one of the "Lower Landing Pad" SVF Capability Patches.
- "Outpost Vendor New Ships" by nefurun [Creations (https://creations.bethesda.net/en/starfield/details/b5723c97-fb67-46ed-9833-07d4e1d8ced1/Outpost_Vendor_New_Ships)]: Use SVF Capability Patch - Outpost Vendor New Ships, and one of the SVF Generic Patches that fits what you need.
- "Outpost Shipbuilder Unlocked ESM" by goldenchrome [Nexus (https://www.nexusmods.com/starfield/mods/5667)]: Use SVF Generic Patch - All Ship Modules Unlocked (Outpost Only).
- "Rich Outpost Shipbuilder" by LilithMotherOfAll [Nexus (https://www.nexusmods.com/starfield/mods/5492)]: No patch. If you loaded a save at an outpost after installing SVF, go to another world (one of the big cities is best), then back to your outpost.
- "Starvival" by lKocMoHaBTl [Creations (https://creations.bethesda.net/en/starfield/details/cb70aedd-4793-4e05-be51-b5a4987d6b71/Starvival___Immersive_Survival_Addon) / Nexus (https://www.nexusmods.com/starfield/mods/6890)]: Use SVF Compatibility Patch - Starvival.
- "The Den Astrodynamics" by VoodooChild [Nexus (https://www.nexusmods.com/starfield/mods/8809)]: Use SVF Compatibility Patch - The Den Astrodynamics.
- "Ultimate Shipyards Unlocked" by JustAnOrdinaryGuy [Nexus (https://www.nexusmods.com/starfield/mods/4723)]: Use one of the "All Ship Modules Unlocked" SVF Generic Patches.

Known Issues
-----
None

Requirements
-----
None


Credits and Acknowledgements
-----
Bethesda Game Studios: For Starfield itself and the Creation Kit
ElminsterAU: For xEdit and BSArch
Lively: For helping explain some of the odd nuances of an infrequently-used-by-me FOMOD feature
Mod Organizer 2 team: For Mod Organizer 2
Nexus Mods: For mod hosting and for the Vortex Mod Manager
Noggog: For Spriggit
perchik71: For Creation Kit Platform Extended
Scrivener07: For some advice and clarification on papyrus matters


Contact
-----
If you find a bug or have a question about the mod, please post it on the mod page at Nexus Mods (https://www.nexusmods.com/starfield/mods/10057), or in the GitHub project (https://github.com/rux616/starfield-ship-vendor-framework).

If you need to contact me personally, I can be reached through one of the following means:
- **Nexus** Mods: rux616 (https://www.nexusmods.com/users/124191) (Send a message via the "CONTACT" button.)
- **Email**: rux616-at-pm-dot-me (replace `-at-` with `@` and `-dot-` with `.`)
- **Discord**: rux616 (user ID 234489279991119873) - make sure to "@" me
    - Lively's Modding Hub (https://discord.gg/livelymods)
    - Nexus Mods (https://discord.gg/nexusmods)
    - Collective Modding (https://discord.gg/pF9U5FmD6w) ("🔧-chaotic-cognitions" channel)
    - Starfield - Ship Distribution (https://discord.gg/wuvaYAsuAc)
    - Starfield Modding (https://discord.gg/6R4Yq5KjW2)
