Table Of Contents
=================
- [Table Of Contents](#table-of-contents)
- [Start Here](#start-here)
- [Add Ships To Vendor](#add-ships-to-vendor)
    - [Step 1: Load the Starfield Creation Kit](#step-1-load-the-starfield-creation-kit)
    - [Step 2: Create Spaceship](#step-2-create-spaceship)
    - [Step 3: Create Leveled Base Form](#step-3-create-leveled-base-form)
    - [Step 4: Create FormList](#step-4-create-formlist)
- [Set Vendor To Use SVF - Vendor Data Map (Recommended)](#set-vendor-to-use-svf---vendor-data-map-recommended)
    - [Step 1: Load the Starfield Creation Kit](#step-1-load-the-starfield-creation-kit-1)
    - [Step 2: Create Min/Max Gameplay Options (Optional)](#step-2-create-minmax-gameplay-options-optional)
    - [Step 3: Create Gameplay Option Group (Optional)](#step-3-create-gameplay-option-group-optional)
    - [Step 4: Create "ShipVendorList" FormLists](#step-4-create-shipvendorlist-formlists)
    - [Step 5: Create "VendorData" FormLists](#step-5-create-vendordata-formlists)
    - [Step 6: Create "VendorMapAdd" FormLists](#step-6-create-vendormapadd-formlists)
- [Set Vendor To Use SVF - Direct](#set-vendor-to-use-svf---direct)
    - [Step 1: Load the Starfield Creation Kit](#step-1-load-the-starfield-creation-kit-2)
    - [Step 2: Create "ShipVendorList" FormLists](#step-2-create-shipvendorlist-formlists)
    - [Step 3: Edit Vendor](#step-3-edit-vendor)
- [NPC Ship Lists](#npc-ship-lists)


Start Here
==========
This document is meant to show you how to create mods utilizing the Ship Vendor Framework. To learn how to add your ships to a vendor, proceed to the "[Add Ships To Vendor](#add-ships-to-vendor)" section. To learn how to add Ship Vendor Framework capabilities to any of your own ship vendors, proceed to the "[Set Vendor To Use SVF - Vendor Data Map](#set-vendor-to-use-svf---vendor-data-map-recommended)" section (recommended) if you want to avoid the hassle of modifying the actor directly, or the "[Set Vendor To Use SVF - Direct](#set-vendor-to-use-svf---direct)" section if you are okay with modifying the actor directly.

If you have a question about this document or need help with any of the process, please add a comment on the ["Posts" tab](https://www.nexusmods.com/starfield/mods/10057?tab=posts) of the Ship Vendor Framework mod.

If you would like to consume the "Add Ships To Vendor" section of this document in video format, check out [this great tutorial video](https://www.youtube.com/watch?v=dfM2OqBzbxQ) done by YouTuber "Art Toots"!

([TOC](#table-of-contents))


Add Ships To Vendor
===================

Step 1: Load the Starfield Creation Kit
---------------------------------------
Load up the Starfield Creation Kit, making sure that you have ShipVendorFramework.esm active in your mod manager, then double click to make sure that ShipVendorFramework.esm has an "X" next to it.

![Load the ESM](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1721942591-312643742.jpeg)

Click the "OK" button to load up the plugins.

([TOC](#table-of-contents))


Step 2: Create Spaceship
------------------------
Go to "Generic Forms" => "Base Forms" => "Spaceship" in the Object Window, right click, and select "New". From there, create your spaceship. Use the existing spaceships as references if you need to.

**NOTE:** Unique spaceships generally go in the "Aspirational" category under "Spaceship".

![Create Spaceship](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1721942605-691502869.jpeg)

([TOC](#table-of-contents))


Step 3: Create Leveled Base Form
--------------------------------
Go to "Generic Forms" => "Leveled Base Forms" in the Object Window, right click, and select "New".

![Create Leveled Base Form 1](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1722316034-46029659.jpeg)

From there, add your ship to the lower left pane. Note that you can also add conditions to each entry, just like a normal leveled list. For example, you can require that the player be level 50 or higher before the ship will show.

![Create Leveled Base Form 2](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1722316054-838272.jpeg)

([TOC](#table-of-contents))


Step 4: Create FormList
------------------------
Before getting into the details of this step, there's some important information you need to know about the way that ship vendors work. A ship vendor sells a number of ships composed from up to 3 different lists: an "always" list, a "random" list, and a "unique" list, **in that order**. So when generating ships for sale, the script attempts to generate all of the "always" ships, a random number of the "random" ships, and all of the "unique" ships. You should consider this when determining which formlist you wish to add your ship to. Please see the [NPC Ship Lists](#npc-ship-lists) section for a full breakdown as to what vendor uses which lists.

Go to "Miscellaneous" => "FormList" in the Object Window, right click, and select "New".

![Create FormList](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1721942663-1160920978.jpeg)

Add the new Leveled Base Form you just created to the list.

![Add Leveled Base Form](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1721942673-1816070178.jpeg)

Set the "Add To List" target of your formlist. All of the lists added by Ship Vendor Framework have a prefix of "SVF_ShipVendorList_", and from there are broken down into things like location, manufacturer, faction, etc.

![Set "Add To List" Target](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1721942682-1441125928.jpeg)

([TOC](#table-of-contents))


Set Vendor To Use SVF - Vendor Data Map (Recommended)
=====================================================
Before you continue this section, it might be a good idea to familiarize yourself with the vendor data map concept introduced in v1.6 of Ship Vendor Framework.

Step 1: Load the Starfield Creation Kit
---------------------------------------
Load up the Starfield Creation Kit, making sure that you have ShipVendorFramework.esm and the mod you wish to add SVF vendor capabilities to active in your mod manager, then double click to make sure that both mods have an "X" next to them.

![Load the ESMs](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758706409-1414994907.jpg)

([TOC](#table-of-contents))


Step 2: Create Min/Max Gameplay Options (Optional)
--------------------------------------------------
This step is optional, but will allow you to enable users to change the minimum and maximum number of ships that an enhanced ship vendor will attempt to sell from the set of "random" ships. If you choose to not use Gameplay Options for this, you can also use Globals to set numbers that the user can't change dynamically, or nothing at all in which case the Ship Vendor Framework will default to a minimum of 4 and a maximum of 8.

Go to "Miscellaneous" => "Gameplay Options" in the Object Window, pick the two items that begin with "SVF_Option_TEMPLATE", right click them, and choose "Duplicate and Rename".

![Duplicate and rename](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758706492-1934340497.jpg)

In the "Rename" window, change "Count" to 0, enter "TEMPLATE" into the "Search" field and enter whatever the editor ID of your vendor is into the "Replace" field (for example, for the Shattered Space ship vendor, you would enter "SFBGS001_HV_DumarHasadi").

![Rename](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758706517-1550077560.jpg)

Open up the two newly-created Gameplay Options and change the "CHANGE ME" text to the name of your vendor, and double check that the default is what you want (it will be 4 or 8 for min or max, respectively). Look at the other records if you need an example. I would recommend not messing with the "Rewards" section unless you really know what you're doing.

![Customize Min/Max Options](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758706542-2115368012.jpg)

([TOC](#table-of-contents))


Step 3: Create Gameplay Option Group (Optional)
-----------------------------------------------
NOTE: You only need to do this step if you created Gameplay Options in the previous step.

Go to "Miscellaneous" => "Gameplay Option Group" in the Object Window, right click, and select "New". For the ID, I would suggest something like "SVF_Group_Main_<ModFileName>".

![Create New Gameplay Option Group](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758778464-1126947296.jpg)

Open up the Gameplay Option Group you just created and add the 2 Gameplay Options you created in the previous step. Make sure to arrange them in the order they should appear in game, that is, the "Min" option, then the "Max" option. Leave the "Root Group" option unchecked.

![Populate Gameplay Option Group](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758778472-1538921665.jpg)

([TOC](#table-of-contents))


Step 4: Create "ShipVendorList" FormLists
-----------------------------------------
A ship vendor can use up to 3 lists: 1 list for ships that the vendor always sells, 1 list for unique ships that the vendor sells, and 1 list from which the vendor will sell a random number of them. We will designate these as the "always", "unique", and "random" lists, respectively.

In the main Ship Vendor Framework mod, I set these lists to have a naming format of "SVF_ShipVendorList_<List_Type>_<List_Designator>". "<List_Type>" is something like "Manufacturer_Deimos", "Faction_UnitedColonies", or simply "Collection". "<List_Designator>" is something like "Generic", "Always", "Unique", things like that. Feel free to look at the existing lists for inspiration.

Create each list by going to "Miscellaneous" => "FormList" in the Object Window, right clicking, and selecting "New".

![Create New FormList](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758781216-1294962684.jpg)

Set the ID of the lists, then fill them your desired "Leveled Base Form" entries, much like step 4 of the "Add Ships To Vendor" section, except you will leave the "Add To List" field as "None".

![Populate ShipVendorList FormList](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758781226-515829392.jpg)

([TOC](#table-of-contents))


Step 5: Create "VendorData" FormLists
-------------------------------------
These formlists are pointers to the data that Ship Vendor Framework needs to work with a specified vendor. These formlists **MUST** be created. Additionally, the "ShipListAlways", "ShipListRandom", and "ShipListUnique" formlists **MUST** be populated by a "SVF_ShipVendorList_[...]"-type list, though it doesn't have to be one you create. For example, you could choose to use "SVF_ShipVendorList_Faction_UnitedColonies_Limited" in the "ShipListRandom" formlist.

Go to "Miscellaneous" => "FormList" in the Object Window, right click, and select "New".

![Create New FormList](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758781216-1294962684.jpg)

For the ID, I would recommend something like "SVF_VendorData_<Vendor_Editor_ID>_<Map_Type>", where "<Vendor_Editor_ID>" is the ID of the actor that is the vendor, and "<Map_Type>" is one of the following:

- RandomShipsForSaleMax
- RandomShipsForSaleMin
- ShipListAlways
- ShipListRandom
- ShipListUnique
- VendorContainer

Populate each of the formlists as follows:

- RandomShipsForSaleMax/RandomShipsForSaleMin: the gameplay options you created in step 2
    - ![Populate RandomShipsForSale(...) FormLists](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758784402-160024135.jpg)
- ShipListAlways/ShipListRandom/ShipListUnique: the ShipVendorList formlist you created in step 4, or one of the existing ones
    - ![Populate ShipList(...) FormLists](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758784416-1017880171.jpg)
- VendorContainer: the object reference of your vendor's container (a note about this: at least as of CK v1.15.222.0, you can't just drag and drop the reference, you need to engage in some shenanigans to do it)
    - Make sure you have the "Cell View" window open (you can make sure it's shown by going to the "View" menu and selecting "Cell View"
    - ![Open Cell View](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758784428-6105545.jpg)
    - Filter the Cell View window however you need to in order to find your vendor's vendor container
    - ![Filter Cell View](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758784439-1101570346.jpg)
    - Open the VendorContainer formlist you created, drag the vendor container reference into the list box (above the Conditions box), then click the "Paste selected element" button on the right side of the list box (it looks like a clipboard)
    - ![Populate VendorContainer FormList](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758784452-137422332.jpg)
    - Yes, this is stupidly convoluted. No, I have no idea when or even if Bethesda will ever fix it. If you have a proven better way, please let me know.

([TOC](#table-of-contents))


Step 6: Create "VendorMapAdd" FormLists
---------------------------------------
These are the lists used to add the "VendorData" lists to the "VendorMap" lists in the main mod. You **MUST** create 1 for each type listed below.

Go to "Miscellaneous" => "FormList" in the Object Window, right click, and select "New".

![Create New FormList](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758781216-1294962684.jpg)

For the ID, I would recommend something like "SVF_VendorMapAdd_<Map_Type>_<Mod_FileName>", where "<Map_Type>" is one of the vendor maps:

- RandomShipsForSaleMax
- RandomShipsForSaleMin
- ShipListsAlways
- ShipListsRandom
- ShipListsUnique
- VendorContainers
- Vendors

To each of these lists, add the respective formlist created in Step 5 (with the exception of the "Vendors" list - you just add the vendor actor itself), and then set the "add to list" box to the appropriate "SVF_VendorMap_[...]" list from the main mod. For example, if you create a "SVF_VendorMapAdd_VendorContainers_MyAwesomeMod" formlist, you would set the "add to list" box to "SVF_VendorMap_VendorContainers".

![Example "VendorMapAdd" FormList (Not Vendor)](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1759071549-1310188835.jpg)

![Example "VendorMapAdd" FormList (Vendor)](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1759071565-1696964893.jpg)


([TOC](#table-of-contents))


Set Vendor To Use SVF - Direct
==============================

Step 1: Load the Starfield Creation Kit
---------------------------------------
Load up the Starfield Creation Kit, making sure that you have ShipVendorFramework.esm and the mod you wish to add SVF vendor capabilities to active in your mod manager, then double click to make sure that both mods have an "X" next to them.

![Load the ESMs](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758706409-1414994907.jpg)

([TOC](#table-of-contents))


Step 2: Create "ShipVendorList" FormLists
------------------------------------------
A ship vendor can use up to 3 lists: 1 list for ships that the vendor always sells, 1 list for unique ships that the vendor sells, and 1 list from which the vendor will sell a random number of them. We will designate these as the "always", "unique", and "random" lists, respectively.

Technically, the vendor doesn't need all 3 lists, but for the sake of extensibility, I would HIGHLY recommend you set all 3 of them up. That way, if someone else creates a ship and wishes to sell it at your vendor, they can do so easily.

In the main Ship Vendor Framework mod, I set these lists to have a naming format of "SVF_ShipVendorList_<List_Type>_<List_Designator>". "<List_Type>" is something like "Manufacturer_Deimos", "Faction_UnitedColonies", or simply "Collection". "<List_Designator>" is something like "Generic", "Always", "Unique", things like that. Feel free to look at the existing lists for inspiration.

Create each list by going to "Miscellaneous" => "FormList" in the Object Window, right clicking, and selecting "New".

![Create New FormList](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758781216-1294962684.jpg)

Set the ID of the lists, then fill them your desired "Leveled Base Form" entries, much like step 4 of the "Add Ships To Vendor" section, except you will leave the "Add To List" field as "None".

![Populate ShipVendorList FormList](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758781226-515829392.jpg)

([TOC](#table-of-contents))


Step 3: Edit Vendor
-------------------
**NOTE:** This step assumes you've already created your vendor.

Once you've created the lists, you need to find your vendor actor in "Actor" => "Actors" in the Object Window.

![Find The Vendor Actor](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1759072771-1410823434.jpg)

Open up your vendor, go to the "Scripts" area, and double click "sq_shipservicesactorscript". This will open up the script properties.

![Open Script Properties](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1759072788-104466543.jpg)

At the top of this window, you should notice a group called "ShipVendorFramework" with a few properties underneath. Set the values for the "SVFShipsToSellList{Always,Random,Unique}Dataset" properties to their respective formlists you created in the last step.

![Set "Dataset" Properties](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1759072802-1587812210.jpg)

Set the "VendorContainer" property to your vendor's vendor container. (This is important for the "Rich Ship Vendors" option.)

![Set "VendorContainers" Property](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1759072814-1588839804.jpg)

Click "OK" to close the Properties window, then click "OK" again to close the Actor window.

Save your plugin, then export to whatever size master is appropriate. That's it. You're done.

([TOC](#table-of-contents))


NPC Ship Lists
==============
**NOTE:** All formlist editor IDs start with "SVF_ShipVendorList_". This prefix has been removed from the lists as presented in the following table for the sake of brevity.

![NPC Ship List Table](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758690728-542329203.jpg)

([TOC](#table-of-contents))
