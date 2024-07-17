ScriptName ShipVendorFramework:SVF_Utility


; log function
; aiSeverity values: 0 = info, 1 = warning, 2 = error, 3 = debug
; aiSeverityThreshold values: 0 = info, 1 = warning, 2 = error, 3 = debug, -1 = none (suppress)
Function Log(string asScriptName, int aiSource, string asFunctionName, string asLogMessage, int aiSeverity = 0, int aiSeverityThreshold = 0, string asLogName = "ShipVendorFramework") Global
    aiSeverityThreshold = ClampInt(aiSeverityThreshold, -1, 3)
    aiSeverity = ClampInt(aiSeverity, -1, 3)
    If aiSeverity > aiSeverityThreshold
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
    Log("SVF_Utility", 0, asFunctionName, asLogMessage, aiSeverity, 2)
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
; large arrays, but it should still be good enough for our purposes
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
    string fnName = "ShuffleArrayFront" Const
    int LL_INFO = 0 Const
    int LL_WARNING = 1 Const
    int LL_ERROR = 2 Const
    int LL_DEBUG = 3 Const
    _Log(fnName, "begin", LL_DEBUG)
    ; _Log(fnName, "avArray.Length=" + avArray.Length + ", aiSteps=" + aiSteps + ", aiIndexStart=" + aiIndexStart, LL_DEBUG)

    int MAX_RANDOM_INTS = 128 Const
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
        _Log(fnName, "array length will exceed maximum", LL_ERROR)
    EndIf

    int i = 0
    While i < avAppendFrom.Length
        avAppendTo.Add(avAppendFrom[i])
        i += 1
    EndWhile

    _Log(fnName, "end", LL_DEBUG)
    Return avAppendTo
EndFunction
