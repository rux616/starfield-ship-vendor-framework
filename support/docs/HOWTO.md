Ship Vendor Framework How To
============================

Table Of Contents
-----------------
- [Ship Vendor Framework How To](#ship-vendor-framework-how-to)
    - [Table Of Contents](#table-of-contents)
- [Steps](#steps)
    - [Step 1: Load the Starfield Creation Kit](#step-1-load-the-starfield-creation-kit)
    - [Step 2: Create Spaceship](#step-2-create-spaceship)
    - [Step 3: Create Leveled Base Form](#step-3-create-leveled-base-form)
    - [Step 4: Create Form List](#step-4-create-form-list)
- [NPC Ship Lists](#npc-ship-lists)


Steps
=====

Step 1: Load the Starfield Creation Kit
---------------------------------------
Load up the Starfield Creation Kit, making sure that you have ShipVendorFramework.esm active in your mod manager, then double click to make sure that ShipVendorFramework.esm has an "X" next to it.

![Load the ESM](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1721942591-312643742.jpeg)

Click the "OK" button to load up the plugins.

([TOC](#table-of-contents))


Step 2: Create Spaceship
------------------------
Go to "Generic Forms" => "Base Forms" => "Spaceship" in the Object Window, right click, and select "New". From there, create your spaceship. Use the existing spaceships as references if you need to.

Note: Unique spaceships generally go in the "Aspirational" category under "Spaceship".

![Create Spaceship](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1721942605-691502869.jpeg)

([TOC](#table-of-contents))


Step 3: Create Leveled Base Form
--------------------------------
Go to "Generic Forms" => "Leveled Base Forms" in the Object Window, right click, and select "New".

![Create Leveled Base Form 1](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1722316034-46029659.jpeg)

From there, add your ship to the lower left pane. Note that you can also add conditions to each entry, just like a normal leveled list. For example, you can require that the player be level 50 or higher before the ship will show.

![Create Leveled Base Form 2](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1722316054-838272.jpeg)

([TOC](#table-of-contents))


Step 4: Create Form List
------------------------
Before getting into the details of this step, there's some important information you need to know about the way that ship vendors work. A ship vendor sells a number of ships composed from up to 3 different lists: an "always" list, a "random" list, and a "unique" list, **in that order**. So when generating ships for sale, the script attempts to generate all of the "always" ships, a random number of the "random" ships, and all of the "unique" ships. You should consider this when determining which form list you wish to add your ship to. Please see the [NPC Ship Lists](#npc-ship-lists) section for a full breakdown as to what vendor uses which lists.

Go to "Miscellaneous" => "FormList" in the Object Window, right click, and select "New".

![Create Form List](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1721942663-1160920978.jpeg)

Add the new Leveled Base Form you just created to the list.

![Add Leveled Base Form](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1721942673-1816070178.jpeg)

Set the "Add To List" target of your form list. All of the lists added by Ship Vendor Framework have a prefix of "SVF_ShipVendorList_", and from there are broken down into things like location, manufacturer, faction, etc.

![Set "Add To List" Target](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1721942682-1441125928.jpeg)

([TOC](#table-of-contents))


NPC Ship Lists
==============
Note: All form list editor IDs start with "SVF_ShipVendorList_". This prefix has been removed from the lists as presented in the following table for the sake of brevity.

![NPC Ship List Table](https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1721963709-844221600.jpeg)

([TOC](#table-of-contents))
