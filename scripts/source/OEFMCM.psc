ScriptName OEFMCM Extends SKI_ConfigBase

GlobalVariable Property OEFDebugLevel Auto
GlobalVariable Property OEFScanFreq Auto
GlobalVariable Property OEFAllowPlayer Auto
GlobalVariable Property OEFPlayerChance Auto
GlobalVariable Property OEFUseRelationship Auto

Int OID_DebugLevel
Int OID_ScanFreq
Int OID_AllowPlayer
Int OID_PlayerChance
Int OID_UseRelationship

Event OnPageReset(string page)
	if page == ""
		SetCursorFillMode(TOP_TO_BOTTOM)

		SetCursorPosition(0) 
		AddHeaderOption("Configuration")

		OID_AllowPlayer = AddToggleOption("Allow Player to be included", OEFAllowPlayer.GetValue())
		OID_PlayerChance = AddSliderOption("Chance for Player to be included", OEFPlayerChance.GetValue(), "{0}%")
		OID_UseRelationship = AddToggleOption("Use NPC-NPC relationships", OEFUseRelationship.GetValue())
		OID_ScanFreq = AddSliderOption("Frequency of scanning followers", OEFScanFreq.GetValue(), "{0}S")

		SetCursorPosition(1) 
		AddHeaderOption("Debug")

		OID_DebugLevel = AddSliderOption("Debug Level", OEFDebugLevel.GetValue(), "{0}")
	endif
EndEvent

Event OnOptionSelect(Int option)
	if (option == OID_AllowPlayer)
        OEFAllowPlayer.SetValue(1 - OEFAllowPlayer.GetValue())
        SetToggleOptionValue(OID_AllowPlayer, OEFAllowPlayer.GetValue())
	elseif (option == OID_UseRelationship)
        OEFUseRelationship.SetValue(1 - OEFUseRelationship.GetValue())
        SetToggleOptionValue(OID_UseRelationship, OEFUseRelationship.GetValue())
	endif
EndEvent

Event OnOptionSliderOpen(Int option)
	if (option == OID_PlayerChance)
        SetSliderDialogStartValue(OEFPlayerChance.GetValue())
        SetSliderDialogDefaultValue(50)
        SetSliderDialogRange(0, 100)
        SetSliderDialogInterval(1)
	elseif (option == OID_ScanFreq)
        SetSliderDialogStartValue(OEFScanFreq.GetValue())
        SetSliderDialogDefaultValue(90)
        SetSliderDialogRange(10, 300)
        SetSliderDialogInterval(10)
	elseif (option == OID_DebugLevel)
        SetSliderDialogStartValue(OEFDebugLevel.GetValue())
        SetSliderDialogDefaultValue(0)
        SetSliderDialogRange(0, 5)
        SetSliderDialogInterval(1)      
	endif
EndEvent

Event OnOptionSliderAccept(Int Option, Float Value)
	if (option == OID_PlayerChance)
        OEFPlayerChance.SetValue(Value)
        SetSliderOptionValue(option, value, "{0}%")
	elseif (option == OID_ScanFreq)
        OEFScanFreq.SetValue(Value)
        SetSliderOptionValue(option, value, "{0}S")
	elseif (option == OID_DebugLevel)
	    OEFDebugLevel.SetValue(Value)
        SetSliderOptionValue(option, value, "{0}")
	endif
EndEvent
