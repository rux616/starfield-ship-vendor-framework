# Copyright 2024 Dan Cassidy

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# SPDX-License-Identifier: GPL-3.0-or-later


# example of a map of GitHub in-repo image URLs to Nexus Mods image URLs, for use in the markdown-to-nexusbbcode script

# the keys should be the GitHub in-repo file paths, and the values should be the corresponding Nexus Mods URLs
$nexus_image_map = @{
    # readme
    "/support/packaging/svf-npc-form-list.jpg"                                             = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1787910135-1696394439.jpg"
    "/support/packaging/svf-npc-form-list-FreeLanes.jpg"                                   = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1787910080-1463907282.jpg"
    "/support/packaging/svf-npc-form-list-ShatteredSpace.jpg"                              = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1776201400-1499281488.jpg"
    "/support/packaging/svf-npc-form-list-DarkStarAstrodynamics.jpg"                       = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758690462-441494414.jpg"
    "/support/packaging/svf-npc-form-list-FalklandSystems.jpg"                             = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758690440-150465271.jpg"
    "/support/packaging/svf-npc-form-list-Watchtower.jpg"                                  = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1765403468-2063053105.jpg"

    # howto
    ## add ships to vendor
    "/support/packaging/svf-how-to-ship-1a-load-ck.jpg"                                    = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1721942591-312643742.jpeg"
    "/support/packaging/svf-how-to-ship-2a-create-spaceship.jpg"                           = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1721942605-691502869.jpeg"
    "/support/packaging/svf-how-to-ship-3a-lvlb-location.jpg"                              = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1776222755-350937584.jpg"
    "/support/packaging/svf-how-to-ship-3b-new-lvlb.jpg"                                   = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1776222916-1658047423.jpg"
    "/support/packaging/svf-how-to-ship-3c-duplicate-lvlb.jpg"                             = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1776223139-206198183.jpg"
    "/support/packaging/svf-how-to-ship-3d-change-edid.jpg"                                = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1776225596-1312957673.jpg"
    "/support/packaging/svf-how-to-ship-3e-lvlb-delete-existing.jpg"                       = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1776225601-1581985146.jpg"
    "/support/packaging/svf-how-to-ship-3f-lvlb-add-new.jpg"                               = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1776223199-449705653.jpg"
    "/support/packaging/svf-how-to-ship-3g-lvlb-change-object.jpg"                         = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1776225607-1374934730.jpg"
    "/support/packaging/svf-how-to-ship-3h-lvlb-change-object-form.jpg"                    = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1776225613-1731705436.jpg"
    "/support/packaging/svf-how-to-ship-3i-lvlb-change-level.jpg"                          = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1776225618-1003081228.jpg"
    "/support/packaging/svf-how-to-ship-4a-flst-location.jpg"                              = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1776226655-530618172.jpg"
    "/support/packaging/svf-how-to-ship-4b-flst-new.jpg"                                   = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1776226655-2017775888.jpg"
    "/support/packaging/svf-how-to-ship-4c-blank-form-list.jpg"                            = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1776226660-98154083.jpg"
    "/support/packaging/svf-how-to-ship-4d-add-to-flst.jpg"                                = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1776226659-1702976581.jpg"
    "/support/packaging/svf-how-to-ship-4e-select-form-type.jpg"                           = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1776226664-972740216.jpg"
    "/support/packaging/svf-how-to-ship-4f-select-form.jpg"                                = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1776226665-1621372468.jpg"
    "/support/packaging/svf-how-to-ship-4g-add-to-list-location.jpg"                       = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1776226670-646571253.jpg"
    "/support/packaging/svf-how-to-ship-4h-add-to-list-filtered.jpg"                       = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1776226670-1069041000.jpg"
    "/support/packaging/svf-how-to-ship-4i-convert-plugin.jpg"                             = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1776226674-1990355738.jpg"
    ## vendor set up - vendor data map
    "/support/packaging/svf-how-to-vendor-map-1a.jpg"                                      = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758706409-1414994907.jpg"
    "/support/packaging/svf-how-to-vendor-map-2a-create-min-max-options.jpg"               = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758706492-1934340497.jpg"
    "/support/packaging/svf-how-to-vendor-map-2b-rename-forms.jpg"                         = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758706517-1550077560.jpg"
    "/support/packaging/svf-how-to-vendor-map-2c-customize-min-max-options.jpg"            = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758706542-2115368012.jpg"
    "/support/packaging/svf-how-to-vendor-map-3a-new-gameplay-option-group.jpg"            = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758778464-1126947296.jpg"
    "/support/packaging/svf-how-to-vendor-map-3b-populate-gameplay-option-group.jpg"       = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758778472-1538921665.jpg"
    "/support/packaging/svf-how-to-vendor-map-4a-create-formlist.jpg"                      = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758781216-1294962684.jpg"
    "/support/packaging/svf-how-to-vendor-map-4b-populate-shipvendorlist.jpg"              = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758781226-515829392.jpg"
    "/support/packaging/svf-how-to-vendor-map-5a-create-formlist.jpg"                      = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1788165136-743324726.jpg"
    "/support/packaging/svf-how-to-vendor-map-5b-populate-vendorkeywordslist.jpg"          = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1788164953-541152137.jpg"
    "/support/packaging/svf-how-to-vendor-map-6a-create-formlist.jpg"                      = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1776246363-931927246.jpg"
    "/support/packaging/svf-how-to-vendor-map-6b-populate-randomshipsforsale.jpg"          = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758784402-160024135.jpg"
    "/support/packaging/svf-how-to-vendor-map-6c-populate-shiplists.jpg"                   = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758784416-1017880171.jpg"
    "/support/packaging/svf-how-to-vendor-map-6d-open-cell-view.jpg"                       = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758784428-6105545.jpg"
    "/support/packaging/svf-how-to-vendor-map-6e-filter-cell-view.jpg"                     = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758784439-1101570346.jpg"
    "/support/packaging/svf-how-to-vendor-map-6f-populate-vendorcontainer.jpg"             = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1758784452-137422332.jpg"
    "/support/packaging/svf-how-to-vendor-map-6g-populate-vendorkeywords.jpg"              = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1788252558-625154506.jpg"
    "/support/packaging/svf-how-to-vendor-map-7a-create-formlist.jpg"                      = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1776246393-2023002372.jpg"
    "/support/packaging/svf-how-to-vendor-map-7b-add-vendordata-to-vandormapadd-1.jpg"     = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1759071549-1310188835.jpg"
    "/support/packaging/svf-how-to-vendor-map-7c-add-vendordata-to-vandormapadd-2.jpg"     = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1759071565-1696964893.jpg"
    ## vendor set up - direct
    "/support/packaging/svf-how-to-vendor-direct-1a.jpg"                                   = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1776244814-2115491136.jpg"
    "/support/packaging/svf-how-to-vendor-direct-2a-create-formlist.jpg"                   = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1776244975-219623544.jpg"
    "/support/packaging/svf-how-to-vendor-direct-2b-populate-shipvendorlist.jpg"           = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1776245247-628091642.jpg"
    "/support/packaging/svf-how-to-vendor-direct-3a-create-formlist.jpg"                   = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1788168592-125820815.jpg"
    "/support/packaging/svf-how-to-vendor-direct-3b-populate-vendorkeywordslist.jpg"       = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1788168611-1885851381.jpg"
    "/support/packaging/svf-how-to-vendor-direct-4a-find-actor.jpg"                        = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1759072771-1410823434.jpg"
    "/support/packaging/svf-how-to-vendor-direct-4b-open-script-properties.jpg"            = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1759072788-104466543.jpg"
    "/support/packaging/svf-how-to-vendor-direct-4c-script-properties-datasets.jpg"        = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1759072802-1587812210.jpg"
    "/support/packaging/svf-how-to-vendor-direct-4d-script-properties-vendorcontainer.jpg" = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1759072814-1588839804.jpg"
    "/support/packaging/svf-how-to-vendor-direct-4e-script-properties-vendorkeywords.jpg"  = "https://staticdelivery.nexusmods.com/mods/2295/images/969/969-1788167662-656101961.jpg"
    ## npc ship list
    ### see "readme" above
}
