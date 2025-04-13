; Copyright 2024 Dan Cassidy

; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <https://www.gnu.org/licenses/>.

; SPDX-License-Identifier: GPL-3.0-or-later



ScriptName ShipVendorFramework:SVF_Control Extends Quest

int Property SVFControlVersion = 1 Auto Const Hidden
{ The desired version of the SVF_Control script. }

; The current version of the SVF_Control script.
int SVFControlVersionCurrent = 0

string Property SVFVersion = "1.5.0" Auto Const Hidden
{ The Ship Vendor Framework version. }

Actor Property PlayerRef Auto
{ The player reference. }

GlobalVariable Property UniverseVariant Auto Const

ActorValue Property PlayerUnityTimesEntered Auto Const

int Property LogLevel = 2 Auto Const
{ The log level for the script. -1=none, 0=info, 1=warning, 2=error, 3=debug. }

; log levels
; "info" log level
int LL_INFO = 0 Const
; "warning" log level
int LL_WARNING = 1 Const
; "error" log level
int LL_ERROR = 2 Const
; "debug" log level
int LL_DEBUG = 3 Const

FormList property test_list auto const


; local opinionated log function
Function _Log(string asFunctionName, string asLogMessage, int aiSeverity = 0)
    ShipVendorFramework:SVF_Utility.Log("SVF_Control", GetFormID(), asFunctionName, asLogMessage, aiSeverity, LogLevel)
EndFunction


Event OnInit()
    string fnName = "OnInit" Const
    _Log(fnName, "begin", LL_DEBUG)
    VersionInfo(false)
    _Log(fnName, "end", LL_DEBUG)
EndEvent


Event OnQuestInit()
    string fnName = "OnQuestInit" Const
    _Log(fnName, "begin", LL_DEBUG)
    Initialize()
    _Log(fnName, "end", LL_DEBUG)
EndEvent


Event Actor.OnPlayerLoadGame(Actor akPlayer)
    string fnName = "Actor.OnPlayerLoadGame" Const
    _Log(fnName, "begin", LL_DEBUG)
    VersionInfo()
    Initialize()
    _Log(fnName, "end", LL_DEBUG)
EndEvent


Function Initialize()
    string fnName = "Initialize" Const
    _Log(fnName, "begin", LL_DEBUG)
    _Log(fnName, "SVF_Control version: current=" + SVFControlVersionCurrent + ", desired=" + SVFControlVersion)

    If SVFControlVersionCurrent != SVFControlVersion
        If SVFControlVersionCurrent == 0
            _Log(fnName, "SVF_Control initializing")
            PlayerRef = Game.GetPlayer()  ; temporary until the CK can save Actor properties to scripts
            RegisterForRemoteEvent(PlayerRef, "OnPlayerLoadGame")
            SVFControlVersionCurrent = SVFControlVersion
            _Log(fnName, "SVF_Control initialized")
        EndIf
    EndIf

    _Log(fnName, "end", LL_DEBUG)
EndFunction


; print version and misc debug into to the log
Function VersionInfo(bool abFull = true)
    ShipVendorFramework:SVF_Utility.Log("", 0, "", "Log level: " + LogLevel, -1)
    ShipVendorFramework:SVF_Utility.Log("", 0, "", "Starfield version: " + Debug.GetVersionNumber(), -1)
    ShipVendorFramework:SVF_Utility.Log("", 0, "", "Ship Vendor Framework version: " + SVFVersion, -1)
EndFunction
