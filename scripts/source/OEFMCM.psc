ScriptName OEFMCM Extends SKI_ConfigBase

;;;;; config
GlobalVariable Property OEFDebugLevel Auto
GlobalVariable Property OEFScanFreq Auto
GlobalVariable Property OEFAllowPlayer Auto
GlobalVariable Property OEFAllowNPC Auto
GlobalVariable Property OEFPlayerChance Auto
GlobalVariable Property OEFUseRelationship Auto
GlobalVariable Property OEFMaxGroups Auto
GlobalVariable Property OEFSearchRadius Auto
GlobalVariable Property OEFWT_MM Auto
GlobalVariable Property OEFWT_FF Auto
GlobalVariable Property OEFWT_MF Auto
GlobalVariable Property OEFImmersive Auto

Int OID_DebugLevel
Int OID_ScanFreq
Int OID_AllowPlayer
Int OID_AllowNPC
Int OID_Immersive
Int OID_PlayerChance
Int OID_UseRelationship
Int OID_MaxGroups
Int OID_SearchRadius
Int OID_WT_FF
Int OID_WT_MF
Int OID_WT_MM

Event OnPageReset(string page)
	if page == ""
		SetCursorFillMode(TOP_TO_BOTTOM)

		SetCursorPosition(0) 

		AddHeaderOption("general")
		OID_Immersive = AddToggleOption("No Noticiations", OEFImmersive.GetValue())
		OID_AllowNPC = AddToggleOption("Allow non-follower NPCs", OEFAllowNPC.GetValue())
		OID_UseRelationship = AddToggleOption("Use NPC-NPC relationship values", OEFUseRelationship.GetValue())
		OID_MaxGroups = AddSliderOption("Max groups allowed", OEFMaxGroups.GetValue(), "{0}")
		OID_SearchRadius = AddSliderOption("Radius to search for available NPCs", OEFSearchRadius.GetValue())
		OID_ScanFreq = AddSliderOption("Frequency of scanning followers", OEFScanFreq.GetValue(), "{0}S")
		AddEmptyOption()

		AddHeaderOption("player")
		OID_AllowPlayer = AddToggleOption("Allow Player to be included", OEFAllowPlayer.GetValue())
		OID_PlayerChance = AddSliderOption("Chance for Player to be included", OEFPlayerChance.GetValue(), "{0}%")

		SetCursorPosition(1) 

		AddHeaderOption("categories")
		OID_WT_FF = AddSliderOption("F-F weight", OEFWT_FF.GetValue(), "{0}")
		OID_WT_MF = AddSliderOption("M-F weight", OEFWT_MF.GetValue(), "{0}")
		OID_WT_MM = AddSliderOption("M-M weight", OEFWT_MM.GetValue(), "{0}")
		AddEmptyOption()
		AddEmptyOption()
		AddEmptyOption()

		AddHeaderOption("debug")
		OID_DebugLevel = AddSliderOption("Debug Level", OEFDebugLevel.GetValue(), "{0}")
	endif
EndEvent

Event OnOptionHighlight(int option)
	if (option == OID_UseRelationship)
		SetInfoText("Only NPCs who have a relationship with each other will engage in sex")
	endif
EndEvent

Event OnOptionSelect(Int option)
	if (option == OID_AllowPlayer)
        OEFAllowPlayer.SetValue(1 - OEFAllowPlayer.GetValue())
        SetToggleOptionValue(OID_AllowPlayer, OEFAllowPlayer.GetValue())
    elseif (option == OID_AllowNPC)
    	OEFAllowNPC.SetValue(1 - OEFAllowNPC.GetValue())
    	SetToggleOptionValue(OID_AllowNPC, OEFAllowNPC.GetValue())
    elseif (option == OID_Immersive)
    	OEFImmersive.SetValue(1 - OEFImmersive.GetValue())
    	SetToggleOptionValue(OID_Immersive, OEFImmersive.GetValue())
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
    elseif (option == OID_MaxGroups)
    	SetSliderDialogStartValue(OEFMaxGroups.GetValue())
        SetSliderDialogDefaultValue(2)
        SetSliderDialogRange(0, 5)
        SetSliderDialogInterval(1)
    elseif (option == OID_SearchRadius)
    	SetSliderDialogStartValue(OEFSearchRadius.GetValue())
        SetSliderDialogDefaultValue(300)
        SetSliderDialogRange(100, 3000)
        SetSliderDialogInterval(10)
    elseif (option == OID_WT_FF)
    	SetSliderDialogStartValue(OEFWT_FF.GetValue())
        SetSliderDialogDefaultValue(20)
        float smin = 1 - OEFWT_MF.GetValue() - OEFWT_MM.GetValue()
        if smin < 0
        	smin = 0
        endif
        SetSliderDialogRange(smin, 100)
        SetSliderDialogInterval(1)
    elseif (option == OID_WT_MF)
    	SetSliderDialogStartValue(OEFWT_MF.GetValue())
        SetSliderDialogDefaultValue(60)
        float smin = 1 - OEFWT_FF.GetValue() - OEFWT_MM.GetValue()
        if smin < 0
        	smin = 0
        endif
        SetSliderDialogRange(smin, 100)
        SetSliderDialogInterval(1)
    elseif (option == OID_WT_MM)
    	SetSliderDialogStartValue(OEFWT_MM.GetValue())
        SetSliderDialogDefaultValue(20)
        float smin = 1 - OEFWT_FF.GetValue() - OEFWT_MF.GetValue()
        if smin < 0
        	smin = 0
        endif
        SetSliderDialogRange(smin, 100)
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
	elseif (option == OID_MaxGroups)
	    OEFMaxGroups.SetValue(Value)
        SetSliderOptionValue(option, value, "{0}")
	elseif (option == OID_SearchRadius)
	    OEFSearchRadius.SetValue(Value)
        SetSliderOptionValue(option, value, "{0}")
	elseif (option == OID_WT_FF)
	    OEFWT_FF.SetValue(Value)
        SetSliderOptionValue(option, value, "{0}")
	elseif (option == OID_WT_MF)
	    OEFWT_MF.SetValue(Value)
        SetSliderOptionValue(option, value, "{0}")
	elseif (option == OID_WT_MM)
	    OEFWT_MM.SetValue(Value)
        SetSliderOptionValue(option, value, "{0}")
	endif
EndEvent
