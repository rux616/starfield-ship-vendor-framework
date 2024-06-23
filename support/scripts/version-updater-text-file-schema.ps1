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


# text file schema for version updater
# note that file paths are relative to the root of the project

$text_files.Add(@{
        # .\.version.ps1
        # build_number = ...
        file               = ".\.version.ps1"
        search_and_replace = @(@{
                search  = "(build_number = )\d*"
                replace = "`${1}" + $version.BuildNumber.ToString()
            })
    })
$text_files.Add(@{
        # .\support\docs\README.md
        # Version: ...
        file               = ".\support\docs\README.md"
        search_and_replace = @(@{
                search  = "(Version: ).*"
                replace = "`${1}" + $version.ToString()
            })
    })
$text_files.Add(@{
        # .\data\fomod\info.xml
        # <Version>...</Version>
        file               = ".\data\fomod\info.xml"
        search_and_replace = @(@{
                search  = "(<Version>).*(</Version>)"
                replace = "`${1}" + $version.ToString() + "`${2}"
            })
    })
