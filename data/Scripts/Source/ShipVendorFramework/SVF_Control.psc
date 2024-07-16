ScriptName ShipVendorFramework:SVF_Control Extends Quest

int Property SVFControlVersion = 1 Auto Const Hidden
{ The desired version of the SVF_Control script. }

; The current version of the SVF_Control script.
int SVFControlVersionCurrent = 0

string Property SVFVersion = "0.0.0" Auto Const Hidden
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
    PlayerRef = Game.GetPlayer()  ; temporary until the CK can save Actor properties to scripts
    VersionInfo()
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
            RegisterForRemoteEvent(PlayerRef, "OnPlayerLoadGame")
            SVFControlVersionCurrent = SVFControlVersion
            _Log(fnName, "SVF_Control initialized")
        EndIf
    EndIf

    _Log(fnName, "end", LL_DEBUG)
EndFunction


; print version and misc debug into to the log
Function VersionInfo()
    ShipVendorFramework:SVF_Utility.Log("", 0, "", "Log level: " + LogLevel, -1)
    ShipVendorFramework:SVF_Utility.Log("", 0, "", "Starfield version: " + Debug.GetVersionNumber(), -1)
    ShipVendorFramework:SVF_Utility.Log("", 0, "", "Ship Vendor Framework version: " + SVFVersion, -1)
    ShipVendorFramework:SVF_Utility.Log("", 0, "", "Player: level " + PlayerRef.GetLevel() + ", " + PlayerRef.GetValue(PlayerUnityTimesEntered) as int + " Unity traversals", -1)
    ShipVendorFramework:SVF_Utility.Log("", 0, "", "Universe: " + Utility.GetCurrentGameTime() + " days old, variant " + UniverseVariant.GetValueInt(), -1)
EndFunction
