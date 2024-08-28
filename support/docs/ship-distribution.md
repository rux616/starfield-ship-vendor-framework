# 0-ship-vendor-framework
[UNDER CONSTRUCTION]


# 1-starting-out
For those of you who prefer a video guide versus written instructions, please see [this](https://www.youtube.com/watch?v=dfM2OqBzbxQ) excellent video by Art Toots.

So as to not duplicate effort, please head over to the [#⁠starting-out](https://discord.com/channels/1267527145996030064/1267608664185897094) channel in the "The Giving Process" category. When you've finished reading everything that channel has to offer, continue here.

One thing to add is that when you're using the Ship Vendor Framework, when starting up the Creation Kit and loading files you need to make sure that "ShipVendorFramework.esm" has an "X" next to it.
(add image: 1-load-ck)

Once you've got the Creation Kit loaded up, proceed to [#2-create-ships](https://discord.com/channels/1267527145996030064/1270964004910530641).


# 2-create-ships
So as to not duplicate effort, please head over to the [#create-ships](https://discord.com/channels/1267527145996030064/1267531062175727708) channel in the "The Giving Process" category, then proceed to [#3-create-leveled-base-form](https://discord.com/channels/1267527145996030064/1270965320311640064),


# 3-create-leveled-base-forms
Once you have your ship created, you need to add it to a Leveled Base Form. You can find this section in the Object Window, in the "Generic Forms" section.
(add image: lvlb-location)

You can either create a new form by right clicking in the right pane of the Object Window and selecting "New", or by duplicating an existing leveled base form.
(add images: new-lvlb, duplicate-lvlb)

If you choose to duplicate a form, I suggest using one of the ones that start with "LShip\_Vendor\_".

If you duplicated a form, open up the new form (if you chose "New", a new form is automatically opened for you) and change the Editor ID.
(add image: change-edid)

The usual template for this for unique ships is "LShip\_Vendor\_Aspirational\_<GeneralFunction>\_<ShipClass>\_<Manufacturer>\_<BaseHullName>\_<UniqueShipName>".

* <GeneralFunction>: What it sounds like. Is this a cargo ship? Maybe use "Cargo" or "Hauler" or something similar. A fighter? Use "Fighter" or "Combat", and so on.
* <ShipClass>: This is the 1-letter designator of the ship's class: "A", "B", or "C". (Could also possibly be "M" if you intend to add M-class ships.)
* <Manufacturer>: Pretty self-explanatory. "Nova", "Deimos", "Taiyo", etc. "Generic" is generally used for ships that don't have a predominate theme.
* <BaseHullName>: The hull name that the unique ship was based off of. For example, the "Shieldbreaker" unique ship is based off the "Warhammer" hull, so "Warhammer" would go here in that case.
* <UniqueShipName>: The unique ship name. For example, "Shieldbreaker".

For general ships the template is generally "LShip\_Vendor\_<Manufacturer>\_<ShipClass>\_<GeneralFunction>\_<HullName>".

* <Manufacturer>: See above.
* <ShipClass>: See above.
* <GeneralFunction>: See above.
* <HullName>: The name of the hull. For example, Deimos has an A-class fighter hull called "Gladius".

Look at the existing leveled base forms if you need ideas.

In either case, I would recommend prefixing the Editor ID with some sort of unique identifier which will make it easier to filter for your stuff. (For example, in my "Warhawk" ship, I use the prefix "warhawk_".)

If you chose to duplicate a form, now is the time to clean out the existing ships. You can do this by right clicking on them and selecting "Delete".
(add image: lvlb-delete-existing)

Now that you have a clean slate, you should right click in the lower left hand corner and choose "New".
(add image: lvlb-add-new)

In the middle area of the window, you can choose the ship and the level. Go ahead and choose the ship you just created as per the instructions in the [#2-create-ships](https://discord.com/channels/1267527145996030064/1270964004910530641) channel. Also choose what level you want this ship to spawn.
(add images: lvlb-change-object, lvlb-change-object-form, lvlb-change-level)

NOTE: When using the Ship Vendor Framework, ships don't generally instantly appear at a vendor once a player reaches the required level. Ship vendors are on a 7 day (by default) timer to update their inventory, which means it could take up to that length of time to see the ship appear, possibly more if the ship you're adding is going into one of the lists used for choosing random ships to spawn at a vendor.

You can also add additional conditions to either the ship specifically, or the leveled base form as a whole. There's a whole raft of options to play with, and you can do some interesting things with conditions, but that is out of scope of this particular guide. There are other guides and videos out there on the internet that do a very good job of explaining them.

Click the "OK" button to save your changes to the leveled base form.

This would also be a good time to save your mod as well.

Now that you've created a leveled base form, it's time to integrate it with the Ship Vendor Framework. Please proceed to [#4-create-form-list](https://discord.com/channels/1267527145996030064/1270965360530690139).


# 4-create-form-list
Once you have your leveled base form and your ship added to it, you need to integrate it into the Ship Vendor Framework. That's where the Form List comes in. You can find the "Form List" section inside the "Miscellaneous" section in the Object Window.
(add image: 4a)

Right click in the right hand pane and select "New". This will pop up a new "FormList [Untitled]" window.
(add image: 4b, 4c)

Just like when you created your leveled base form, you need to give this a unique Editor ID (shown as simply "ID" in the window). I recommend the following template for the ID: "<ModPrefix>\_ShipVendorDistribution\_<ListCategory>\_<Specifier1>[\_<Specifier2>]".

* <ModPrefix>: This is the prefix you chose when creating your ship or creating the leveled base form.
* <ListCategory>: This is the category of list. The Ship Vendor Framework includes 4 categories, "Collection", "Faction", "Location", and "Manufacturer".
* <Specifier1>: For a list category such as "Manufacturer", this is something like "Stroud" or "Nova". For a category such as "Faction", "CrimsonFleer" or "Unaffiliated" would be used.
* <Specifier2>: This particular part may not be used, depending on which category and specifier1 you've chosen. For a "Location" category, this part will be either "Always" or "Unique", whereas for a "UnitedColonies" faction category, "Full" or "Limited" could be used.

As an example, let's again use my "Warhawk" mod. The form list in that mod has the Editor ID of "warhawk\_ShipVendorDistribution\_Location\_NewAtlantis\_Unique".

Have a look at the form lists in the Ship Vendor Framework (they start with "SVF\_ShipVendorList\_") if you need ideas.

Don't forget this is _your_ mod though. You can name this form list however you want!

Once you've changed the Editor ID, you need to add your ship to the list. You can do this in 2 ways, right click and select "Add", or drag and drop your leveled base form into the list.
(add image: 4d)

If you choose "Add", in the "Select Form" window that pops up, choose "Leveled Base Forms" and then click the "OK" button. (You can also simply double click "Leveled Base Forms".)
(add image: 4e)

Now find your leveled base form in the next window that shows up. This is where that special prefix you added might come in handy. Anyway, click your leveled base form to select it, then click the "OK" button. (Again, you can also just double click the leveled base form.)
(add image: 4f)

Once that is done, your leveled base form is added to the Form List. Now turn your attention to the "Add To List" box down towards the bottom of the window.
(add image: 4g)

Double click into it to highlight the "None", then start typing "SVF\_ShipVendorList\_". A list will pop up and automatically filter itself using what you've typed so far. Choose one of those lists to add your leveled base form to. (I'd recommend you pick the list that matches what you set the Editor ID to earlier.)
(add image: 4h)

Check this table for which list belongs to which vendor. (Note that the "SVF\_ShipVendorList\_" prefix has been left off for the sake of brevity.)
(add image: npc-form-list)

Click the "OK" button to close and save the list.

Save your mod.

Export your mod to ESM by going to the "File" menu, then to "Convert Active File to ...", followed by "<Small/Medium/Full> Master".
(add image: 4i)

Once you've converted the file, make sure you immediately exit out of the Creation Kit (without saving again), as there's a bug that can occur which sets erroneous flags in your ESP file and requires hex editing to fix.

:tada: That's it! You're done! :tada:
