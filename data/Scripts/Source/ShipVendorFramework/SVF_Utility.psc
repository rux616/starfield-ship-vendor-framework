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



ScriptName ShipVendorFramework:SVF_Utility


; log function
; aiSeverity: severity of the log message
; aiSeverity values: 0 = info, 1 = warning, 2 = error, 3 = debug
; aiSeverityLimit: limits the level of severity that will be logged to the given level and below
; aiSeverityLimit values: -1 = none (suppress), 0 = info, 1 = warning, 2 = error, 3 = debug
Function Log(string asScriptName, int aiSource, string asFunctionName, string asLogMessage, int aiSeverity = 0, int aiSeverityLimit = 2, string asLogName = "ShipVendorFramework") Global
    aiSeverityLimit = ClampInt(aiSeverityLimit, -1, 3)
    aiSeverity = ClampInt(aiSeverity, -1, 3)
    If aiSeverity > aiSeverityLimit
        Return
    EndIf
    If asScriptName != "" && aiSource != 0
        asScriptName = asScriptName + "[0x" + Utility.IntToHex(aiSource) + "]"
    EndIf
    If asFunctionName != ""
        asFunctionName = "." + asFunctionName + "(): "
    EndIf
    string asSeverity = ""
    If aiSeverity == 0
        asSeverity = "NFO"
    ElseIf aiSeverity == 3
        asSeverity = "DBG"
        aiSeverity = 0
    ElseIf aiSeverity == 1
        asSeverity = "WRN"
    ElseIf aiSeverity == 2
        asSeverity = "ERR"
    EndIf
    If asSeverity != ""
        asSeverity = asSeverity + ": "
    EndIf
    asLogMessage = asSeverity + asScriptName + asFunctionName + asLogMessage
    If ! Debug.TraceUser(asLogName, asLogMessage, aiSeverity)
        ; if log wasn't open, open it, then send trace again
        Debug.OpenUserLog(asLogName)
        Debug.TraceUser(asLogName, asLogMessage, aiSeverity)
    EndIf
EndFunction


; local opinionated log function
; aiSeverity values: 0 = info, 1 = warning, 2 = error, 3 = debug
Function _Log(string asFunctionName, string asLogMessage, int aiSeverity = 0) Global
    int LL_INFO = 0 Const
    int LL_WARNING = 1 Const
    int LL_ERROR = 2 Const
    int LL_DEBUG = 3 Const
    int LOG_LEVEL_THRESHOLD = LL_DEBUG Const  ; TODO change back to LL_INFO for release
    Log("SVF_Utility", 0, asFunctionName, asLogMessage, aiSeverity, LOG_LEVEL_THRESHOLD)
EndFunction


; a min function for integers
int Function MinInt(int aiValue1, int aiValue2) Global
    If aiValue1 < aiValue2
        Return aiValue1
    EndIf
    Return aiValue2
EndFunction


; a max function for integers
int Function MaxInt(int aiValue1, int aiValue2) Global
    If aiValue1 < aiValue2
        Return aiValue2
    EndIf
    Return aiValue1
EndFunction


; a clamp function for integers
int Function ClampInt(int aiValueToClamp, int aiMin, int aiMax) Global
    If aiValueToClamp < aiMin
        Return aiMin
    ElseIf aiValueToClamp > aiMax
        Return aiMax
    EndIf
    Return aiValueToClamp
EndFunction


; deduplicate an integer array (from the back, as it's more efficient)
Function DeduplicateIntArray(int[] aiArray) Global
    string fnName = "DeduplicateIntArray" Const
    int LL_INFO = 0 Const
    int LL_WARNING = 1 Const
    int LL_ERROR = 2 Const
    int LL_DEBUG = 3 Const
    _Log(fnName, "begin", LL_DEBUG)

    int i = aiArray.Length - 1
    int j = 0
    While i > 0
        ; _Log(fnName, "i=" + i + ", aiArray[i]=" + aiArray[i] + ", aiArray.Length=" + aiArray.Length, LL_DEBUG)
        j = aiArray.RFind(aiArray[i], i - 1)
        ; _Log(fnName, "j=" + j, LL_DEBUG)
        If j > -1
            aiArray.Remove(j)
        EndIf
        i += -1
    EndWhile

    _Log(fnName, "end", LL_DEBUG)
EndFunction


; shuffle an array using the Fisher-Yates algorithm, with special modifications to make it more
; performant in Papyrus. specifically, because `Utility.RandomInt()` is a delayed native function,
; using it in a loop would be slow, so we establish a self-replenishing set of seeds and random
; indices based on said seeds using `Utility.RandomIntsFromSeed()` instead.
;
; https://en.wikipedia.org/wiki/Fisher-Yates_shuffle
;
; notes:
; - YOU SHOULD _REALLY_ HAVE A LOCK GUARD ON THE ARRAY YOU'RE SHUFFLING
; - the modifications to the algorithm make it potentially not quite truly random, especially for
;   large arrays, but it should still be good enough for our purposes
; - the _Log() calls in the loop of the function are commented out so as to keep it as performant as
;   possible; uncomment them as needed for troubleshooting
;
; arguments:
; - avArray: the array to shuffle
; - aiSteps: the number of steps to shuffle the array; if less than 0 or greater than the number of
; steps required by the value of `aiIndexStart`, the array will be shuffled from `aiIndexStart` to
; the end of the array
; - aiIndexStart: the index to start shuffling from; if less than 0 or greater than the array
; length, the array will be shuffled from the beginning
;
; returns:
; - the shuffled array
var[] Function ShuffleArray(var[] avArray, int aiSteps = -1, int aiIndexStart = 0) Global
    string fnName = "ShuffleArray" Const
    int LL_INFO = 0 Const
    int LL_WARNING = 1 Const
    int LL_ERROR = 2 Const
    int LL_DEBUG = 3 Const
    _Log(fnName, "begin", LL_DEBUG)
    ; _Log(fnName, "avArray.Length=" + avArray.Length + ", aiSteps=" + aiSteps + ", aiIndexStart=" + aiIndexStart, LL_DEBUG)

    int MAX_RANDOM_INTS = 128 Const         ; arrays can only have a max of 128 elements
    int RANDOM_SEED_MIN = 0x00000000 Const  ; the RandomInt() function is weird and doesn't like 0x80000000 as min
    int RANDOM_SEED_MAX = 0x7FFFFFFE Const  ; the RandomInt() function is weird and doesn't like 0x7FFFFFFF as max

    int lastIndex = avArray.Length - 1
    ; clamp aiIndexStart in bounds
    aiIndexStart = ClampInt(aiIndexStart, 0, lastIndex)
    int swapFromIndex = aiIndexStart
    int swapToIndex = -1
    ; if aiSteps is out of bounds, set it such that the array is shuffled through to the end
    If aiSteps < 0 || aiSteps > avArray.Length
        aiSteps = lastIndex - aiIndexStart
    EndIf
    ; ensure that the ending index is not out of bounds
    int endingIndex = MinInt(aiIndexStart + aiSteps, lastIndex)

    int[] randomSeeds = None
    int[] randomIndices = None
    int indexRandomSeeds = 0x7FFFFFFE
    int indexRandomIndices = 0x7FFFFFFE

    var temp = None

    ; _Log(fnName, "swapFromIndex=" + swapFromIndex + ", endingIndex=" + endingIndex, LL_DEBUG)
    While swapFromIndex < endingIndex
        ; if the random indices are exhausted, generate a new set
        ; _Log(fnName, "swapFromIndex=" + swapFromIndex + ", checking indexRandomIndices (" + indexRandomIndices + ")", LL_DEBUG)
        If indexRandomIndices >= randomIndices.Length
            ; if the random seeds are exhausted, generate a new set
            ; _Log(fnName, "swapFromIndex=" + swapFromIndex + ", checking indexRandomSeeds (" + indexRandomSeeds + ")", LL_DEBUG)
            If indexRandomSeeds >= randomSeeds.Length
                ; _Log(fnName, "swapFromIndex=" + swapFromIndex + ", generating random seeds", LL_DEBUG)
                randomSeeds = Utility.RandomIntsFromSeed(Utility.RandomInt(RANDOM_SEED_MIN, RANDOM_SEED_MAX), MAX_RANDOM_INTS, RANDOM_SEED_MIN, RANDOM_SEED_MAX)
                indexRandomSeeds = 0
                ; _Log(fnName, "swapFromIndex=" + swapFromIndex + ", indexRandomSeeds=" + indexRandomSeeds, LL_DEBUG)
            EndIf
            ; _Log(fnName, "swapFromIndex=" + swapFromIndex + ", generating random indices", LL_DEBUG)
            randomIndices = Utility.RandomIntsFromSeed(randomSeeds[indexRandomSeeds], MinInt(avArray.Length - swapFromIndex, MAX_RANDOM_INTS), swapFromIndex, lastIndex)
            ; _Log(fnName, "swapFromIndex=" + swapFromIndex + ", randomIndices.Length=" + randomIndices.Length + ", randomIndices=" + randomIndices, LL_DEBUG)
            indexRandomIndices = 0
            indexRandomSeeds += 1
            ; _Log(fnName, "swapFromIndex=" + swapFromIndex + ", indexRandomIndices=" + indexRandomIndices, LL_DEBUG)
        EndIf

        ; find a valid index to swap with, note that it's perfectly valid to swap with the same index
        ; _Log(fnName, "swapFromIndex=" + swapFromIndex + ", looking for valid index", LL_DEBUG)
        While swapToIndex < swapFromIndex && indexRandomIndices < randomIndices.Length
            swapToIndex = randomIndices[indexRandomIndices]
            indexRandomIndices += 1
            ; _Log(fnName, "swapFromIndex=" + swapFromIndex + ", swapToIndex=" + swapToIndex + ", indexRandomIndices=" + indexRandomIndices, LL_DEBUG)
        EndWhile

        ; check to make sure that the swap indices are valid and we didn't get here by running out
        ; of random indices, and if so skip this block and generate a new set of indices
        If swapToIndex >= swapFromIndex
            ; _Log(fnName, "swapFromIndex=" + swapFromIndex + ", swapping index " + swapFromIndex + " (" + avArray[swapFromIndex] + ") with index " + swapToIndex + " (" + avArray[swapToIndex] + ")", LL_DEBUG)
            temp = avArray[swapFromIndex]
            avArray[swapFromIndex] = avArray[swapToIndex]
            avArray[swapToIndex] = temp
            swapToIndex = swapFromIndex
            swapFromIndex += 1
        EndIf
        ; _Log(fnName, "swapFromIndex=" + swapFromIndex, LL_DEBUG)
    EndWhile

    _Log(fnName, "end", LL_DEBUG)
    Return avArray
EndFunction


; append the second array to the first array
var[] Function AppendToArray(var[] avAppendTo, var[] avAppendFrom) Global
    string fnName = "AppendToArray" Const
    int LL_INFO = 0 Const
    int LL_WARNING = 1 Const
    int LL_ERROR = 2 Const
    int LL_DEBUG = 3 Const
    _Log(fnName, "begin", LL_DEBUG)

    If avAppendTo.Length + avAppendFrom.Length > 128
        _Log(fnName, "array length will exceed maximum", LL_WARNING)
    EndIf

    If avAppendTo.Length == 0
        avAppendTo = new var[0]
    EndIf

    int i = 0
    While i < avAppendFrom.Length
        avAppendTo.Add(avAppendFrom[i])
        i += 1
    EndWhile

    _Log(fnName, "end", LL_DEBUG)
    Return avAppendTo
EndFunction


; wrapper function to check if two arrays are equal. supports arrays of LeveledSpaceshipBase and
; ShipVendorListScript:ShipToSell structs, and can optionally consider order
bool Function ArraysEqual(var[] avArray1, var[] avArray2, bool abConsiderOrder = false) Global
    string fnName = "ArraysEqual" Const
    int LL_INFO = 0 Const
    int LL_WARNING = 1 Const
    int LL_ERROR = 2 Const
    int LL_DEBUG = 3 Const
    _Log(fnName, "begin", LL_DEBUG)

    ; check for length differences. by definition, if the lengths are different, the arrays cannot be equal, regardless
    ; of order or type
    If avArray1.Length != avArray2.Length
        _Log(fnName, "arrays differ in length: " + avArray1.Length + " != " + avArray2.Length, LL_DEBUG)
        Return false
    EndIf

    ; farm out the actual checking of the arrays to the appropriate function based on the type of the arrays
    If avArray1 is LeveledSpaceshipBase[] && avArray2 is LeveledSpaceshipBase[]
        Return ArraysEqualLVLB(avArray1 as LeveledSpaceshipBase[], avArray2 as LeveledSpaceshipBase[], abConsiderOrder)
    ElseIf avArray1 is ShipVendorListScript:ShipToSell[] && avArray2 is ShipVendorListScript:ShipToSell[]
        Return ArraysEqualShipToSell(avArray1 as ShipVendorListScript:ShipToSell[], avArray2 as ShipVendorListScript:ShipToSell[], abConsiderOrder)
    Else
        _Log(fnName, "unsupported array type or arrays are not of the same type", LL_ERROR)
    EndIf

    _Log(fnName, "end", LL_DEBUG)
    Return false
EndFunction


; check if two arrays of LeveledSpaceshipBase structs are equal
bool Function ArraysEqualLVLB(LeveledSpaceshipBase[] avArray1, LeveledSpaceshipBase[] avArray2, bool abConsiderOrder) Global
    string fnName = "ArraysEqualLVLB" Const
    int LL_INFO = 0 Const
    int LL_WARNING = 1 Const
    int LL_ERROR = 2 Const
    int LL_DEBUG = 3 Const
    _Log(fnName, "begin", LL_DEBUG)

    int i = 0
    If abConsiderOrder == true
        While i < avArray1.Length
            If avArray1[i] != avArray2[i]
                _Log(fnName, "arrays differ at index " + i + ": " + avArray1[i] + " != " + avArray2[i], LL_DEBUG)
                Return false
            EndIf
            i += 1
        EndWhile
    Else
        int findResult = 0
        While i < avArray1.Length
            findResult = avArray2.Find(avArray1[i])
            If findResult == -1
                _Log(fnName, avArray1[i] + " of array 1 not found in array 2", LL_DEBUG)
                Return false
            Else
                avArray2.Remove(findResult)
            EndIf
            i += 1
        EndWhile
    EndIf
    _Log(fnName, "arrays are equal", LL_DEBUG)

    _Log(fnName, "end", LL_DEBUG)
    Return true
EndFunction


; check if two arrays of ShipVendorListScript:ShipToSell structs are equal
bool Function ArraysEqualShipToSell(ShipVendorListScript:ShipToSell[] avArray1, ShipVendorListScript:ShipToSell[] avArray2, bool abConsiderOrder) Global
    string fnName = "ArraysEqualShipToSell" Const
    int LL_INFO = 0 Const
    int LL_WARNING = 1 Const
    int LL_ERROR = 2 Const
    int LL_DEBUG = 3 Const
    _Log(fnName, "begin", LL_DEBUG)

    int i = 0
    If abConsiderOrder == true
        While i < avArray1.Length
            If avArray1[i].leveledShip != avArray2[i].leveledShip || avArray1[i].minLevel != avArray2[i].minLevel
                _Log(fnName, "arrays differ at index " + i + ": " + avArray1[i] + " != " + avArray2[i], LL_DEBUG)
                Return false
            EndIf
            i += 1
        EndWhile
    Else
        bool matchFound = false
        int findResult = 0
        While i < avArray1.Length
            matchFound = false
            findResult = avArray2.FindStruct("leveledShip", avArray1[i].leveledShip)
            While findResult > -1 && matchFound == false
                If avArray1[i].minLevel == avArray2[findResult].minLevel  ; check minLevel
                    matchFound = true
                    avArray2.Remove(findResult)
                ElseIf findResult < avArray2.Length - 1  ; make sure the starting index is not the last index
                    findResult = avArray2.FindStruct("leveledShip", avArray1[i].leveledShip, findResult + 1)
                Else  ; if the starting index is the last index, break out of the loop
                    findResult = -1
                EndIf
            EndWhile
            If matchFound == false
                _Log(fnName, avArray1[i] + " of array 1 not found in array 2", LL_DEBUG)
                Return false
            EndIf
            i += 1
        EndWhile
    EndIf
    _Log(fnName, "arrays are equal", LL_DEBUG)

    _Log(fnName, "end", LL_DEBUG)
    Return true
EndFunction


; returns the last Form in a FormList, or None if the FormList is empty or None
Form Function FormListGetLast(Form akFormList) Global
    string fnName = "FormListGetLast" Const
    int LL_INFO = 0 Const
    int LL_WARNING = 1 Const
    int LL_ERROR = 2 Const
    int LL_DEBUG = 3 Const
    _Log(fnName, "begin", LL_DEBUG)

    If !(akFormList is FormList)
        _Log(fnName, "akFormList is not a FormList", LL_ERROR)
        Return None
    EndIf

    If akFormList == None
        _Log(fnName, "akFormList is None", LL_ERROR)
        Return None
    EndIf

    FormList list = akFormList as FormList
    Form[] listContents = list.GetArray()
    int size = listContents.Length
    If size == 0
        _Log(fnName, "form list " + akFormList + " is empty", LL_WARNING)
        Return None
    EndIf

    Form lastForm = listContents[size - 1]
    _Log(fnName, "form list " + list + " (size " + size + "): " + listContents, LL_DEBUG)
    _Log(fnName, "last form: " + lastForm, LL_DEBUG)

    _Log(fnName, "end", LL_DEBUG)
    Return lastForm
EndFunction


; returns the value of a GameplayOption or GlobalVariable, or a default value if the Form is not one of those types
float Function GetValue2(Form akForm, float afDefault = 0.0) Global
    string fnName = "GetValue2" Const
    int LL_INFO = 0 Const
    int LL_WARNING = 1 Const
    int LL_ERROR = 2 Const
    int LL_DEBUG = 3 Const
    _Log(fnName, "begin", LL_DEBUG)

    float toReturn = afDefault
    If akForm is GameplayOption
        toReturn = (akForm as GameplayOption).GetValue()
        _Log(fnName, akForm + " is a GameplayOption, value: " + toReturn, LL_DEBUG)
    ElseIf akForm is GlobalVariable
        toReturn = (akForm as GlobalVariable).GetValue()
        _Log(fnName, akForm + " is a GlobalVariable, value: " + toReturn, LL_DEBUG)
    Else
        _Log(fnName, "akForm is not a GameplayOption or GlobalVariable, returning default value: " + toReturn, LL_WARNING)
    EndIf

    _Log(fnName, "end", LL_DEBUG)
    _Log(fnName, "returning value: " + toReturn, LL_DEBUG)
    Return toReturn
EndFunction
