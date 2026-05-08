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


# write known masters to a .spriggit file


import argparse
import sys


def main(
    papyrus_file: str,
    marker_template: str,
    list_add_code_template: str,
    mod_file_variable: str,
    patch_file_variable: str,
    mod_files: list[str],
    patch_files: list[str],
) -> int:
    # do a quick check on the lists to ensure they are the same size
    if len(mod_files) != len(patch_files):
        print("[ERROR] The number of mod files and patch files must be the same.")
        return 1
    if len(mod_files) > 128:
        print("[ERROR] Papyrus cannot handle user-made arrays with more than 128 elements.")
        return 1

    # read papyrus file into memory
    try:
        with open(papyrus_file, "r", encoding="utf-8") as f:
            data = f.read()
    except FileNotFoundError:
        print(f"[ERROR] File not found: '{papyrus_file}'")
        return 1
    except Exception as e:
        print(f"[ERROR] Error reading '{papyrus_file}': {e}")
        return 1
    print(f"loaded '{papyrus_file}' into memory")

    for var_name, file_list in [
        (mod_file_variable, mod_files),
        (patch_file_variable, patch_files),
    ]:
        begin_marker = marker_template.replace("<VAR>", var_name).replace("<BOOKEND>", "begin")
        end_marker = marker_template.replace("<VAR>", var_name).replace("<BOOKEND>", "end")
        if begin_marker not in data or end_marker not in data:
            print(f"[ERROR] Insertion markers not found in '{papyrus_file}': {begin_marker} and/or {end_marker}")
            return 1
        marker_begin_index = data.find(begin_marker)
        indentation = data[:marker_begin_index].split("\n")[-1]
        data = (
            data.split(f"{indentation}{begin_marker}\n")[0]
            + f"{indentation}{begin_marker}\n"
            + f"{indentation}"
            + f"\n{indentation}".join(
                list_add_code_template.replace("<VAR>", var_name).replace("<FILE>", file) for file in file_list
            )
            + f"\n{indentation}{end_marker}"
            + data.split(end_marker)[1]
        )
        print(f"inserted {len(file_list)} entries for variable '{var_name}'")

    with open(papyrus_file, "w", encoding="utf-8") as f:
        f.write(data)
    print(f"wrote updated data to '{papyrus_file}'")

    return 0


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Populate mods and patches in a papyrus file based on provided details"
    )

    parser.add_argument("--papyrus-file", help="Path to papyrus file", metavar="PAPYRUS_FILE", default="")
    parser.add_argument(
        "--marker-template",
        help=f"Templated marker string to check for in the papyrus file. Value '<VAR>' will be replaced with the specific variable and '<BOOKEND>' will be replaced with 'begin' or 'end'. Default: '%(default)s'",
        metavar="MARKER_TEMPLATE",
        default="; --> <VAR> list <BOOKEND> <--",
    )
    parser.add_argument(
        "--list-add-code_template",
        help="Templated code to add each mod/patch file to the list variable. Value '<VAR>' will be replaced with the specific variable, and '<FILE>' will be replaced by the mod/patch file.",
        metavar="LIST_ADD_CODE_TEMPLATE",
        default='<VAR>.Add("<FILE>")',
    )
    parser.add_argument(
        "--mod-file-variable", help="Papyrus variable name for mod files", metavar="MOD_VARIABLE", default="modsToCheck"
    )
    parser.add_argument(
        "--patch-file-variable",
        help="Papyrus variable name for patch files",
        metavar="PATCH_VARIABLE",
        default="patchesToCheck",
    )
    parser.add_argument(
        "--mod-patch-pairs",
        help='list of mod/patch pairs. Every mod and patch should be their own entry, but the order should be mod, patch, mod, patch, etc. "patch" values can be "NONE" to indicate a patch does not exist, "N/A" to indicate that a patch is not needed, or "PATCH" to indicate that the mod is a patch itself. Example: --mod-patch-pairs "Mod1.esm" "Patch1.esm" "Mod2.esm" "NONE" "Mod3.esm" "N/A"',
        nargs="+",
        metavar="MOD_OR_PATCH",
        default=[],
    )

    args = parser.parse_args()

    sys.exit(
        main(
            papyrus_file=args.papyrus_file,
            marker_template=args.marker_template,
            list_add_code_template=args.list_add_code_template,
            mod_file_variable=args.mod_file_variable,
            patch_file_variable=args.patch_file_variable,
            mod_files=args.mod_patch_pairs[0::2],  # take every other entry starting with the first for mod files
            patch_files=args.mod_patch_pairs[1::2],  # take every other entry starting with the second for patch files
        )
    )
