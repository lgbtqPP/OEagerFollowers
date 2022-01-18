ScriptName OEFScript extends Quest

;;;;; config
GlobalVariable Property OEFDebugLevel Auto
GlobalVariable Property OEFScanFreq Auto
GlobalVariable Property OEFAllowPlayer Auto
GlobalVariable Property OEFPlayerChance Auto
GlobalVariable Property OEFUseRelationship Auto
GlobalVariable Property OEFMaxGroups Auto

float Function DebugLevel()
	return OEFDebugLevel.GetValue()
EndFunction

float Function ScanFreq()
	return OEFScanFreq.GetValue()
EndFunction

bool Function AllowPlayer()
	return (OEFAllowPlayer.GetValue() == 1)
EndFunction

float Function PlayerChance()
	return OEFPlayerChance.GetValue()
EndFunction

bool Function UseRelationship()
	return OEFUseRelationship.GetValue() == 1
EndFunction

float Function MaxGroups()
	return OEFMaxGroups.GetValue()
EndFunction
;;;;;

; variables
actor playerRef

OsexIntegrationMain ostim

ReferenceAlias Nav1
ReferenceAlias Nav2
ReferenceAlias TargetRef

actor[] actors

faction followerFaction

int sexCount = 0

bool scanning = false

; debug
string debugString = "Eager Followers: "
function oefConsole(int d, string msg)
	if (d <= DebugLevel())
		OsexIntegrationMain.Console(debugString + msg)
	endif 
EndFunction

function oefMessage(int d, string msg)
	if (d <= DebugLevel())
		debug.MessageBox(debugString + msg)
	endif
EndFunction

function oefNotification(int d, string msg)
	if (d <= DebugLevel())
		debug.Notification(debugString + msg)
	endif
EndFunction

; init
Event OnInit()
	ostim = game.GetFormFromFile(0x000801, "Ostim.esp") as OsexIntegrationMain

	if ostim.getAPIVersion() < 13
		oefMessage(0, "OStim version is out of date and not supported.")
	endif

	playerRef = game.GetPlayer()

	quest q = self as quest 
	Nav1 = q.GetAliasById(0) as ReferenceAlias
	Nav2 = q.GetAliasById(1) as ReferenceAlias
	TargetRef = q.GetAliasById(2) as ReferenceAlias

	followerFaction = Game.GetFormFromFile(0x05C84E, "Skyrim.esm") as faction

	RegisterForModEvent("ostim_start", "OstimStart")
	RegisterForModEvent("ostim_end", "OstimEnd")

	oefNotification(0, "Initialized")

	OnLoad()
EndEvent

Function OnLoad()
	RegisterForSingleUpdate(10)
EndFunction

Event OnUpdate()
	oefConsole(1, "Running update")

	oefConsole(1, "DebugLevel = " + (DebugLevel() as string))
	oefConsole(1, "ScanFreq = " + (ScanFreq() as string))
	oefConsole(1, "AllowPlayer = " + (AllowPlayer() as string))
	oefConsole(1, "PlayerChance = " + (PlayerChance() as string))
	oefConsole(1, "UseRelationship = " + (UseRelationship() as string))

	;If !scanning && !playerRef.IsInCombat()
	;	ScanForSex()
	;EndIf

	RegisterForSingleUpdate(10)
EndEvent

Function OnLocChange(Location NewLoc)
 	oefConsole(3, "Changed location to " + NewLoc.GetName())
 	RegisterForSingleUpdate(10)
EndFunction

; Function ScanForSex()
; 	oefNotification(1, "Starting a scan")
; 	scanning = True
; 	actor act = GetRandomFollower()
; 	If !act 
; 		return 
; 	endif
; 	actor partner  = FindCompatiblePartner(act)
; 	if partner 
; 		doSex(act, partner)
; 	endif 
; 	scanning = false
; EndFunction

; Actor[] Function ShuffleActorArray(Actor[] arr)
    
;     int i = arr.length
;     int j ; an index

;     actor temp
;     While (i > 0)
;         i -= 1
;         j = OStim.RandomInt(0, i)

;         temp = arr[i]
;         arr[i] = arr[j]
;         arr[j] = temp 

;     EndWhile
;     return arr
; EndFunction

; float radi = 0.0

; Actor Function GetRandomFollower()
; 	actors = MiscUtil.ScanCellNPCsByFaction(FindFaction = followerFaction, CenterOn = playerRef, radius = radi)
; 	actors = ShuffleActorArray(actors)

; 	int i = 0
; 	int l = actors.length 

; 	While i < l 
; 		If !IsActorInvalid(actors[i])
; 			return actors[i]
; 		else 
; 			actors[i] = none
; 		endif 
; 		i += 1
; 	EndWhile

; 	return none
; EndFunction

; Actor Function FindCompatiblePartner(actor act)
; 	oefConsole(1, "Getting partner for " + act.GetDisplayName())

; 	actors = ShuffleActorArray(actors)

; 	int i = 0
; 	int l = actors.length 

; 	actor partner
; 	While i < l 
; 		partner = actors[i]
; 		if !IsActorInValid(partner) && partner != act && ( true || act.GetRelationshipRank(partner) >= 4) ;!UseRelationship
; 			return partner
; 		endif
; 		i += 1
; 	EndWhile

; 	return none
; EndFunction

; float targetDistance = 256.0

; Function DoSex(actor dom, actor sub)
; 	oefNotification(0, dom.GetDisplayName() + " is having sex with " + sub.GetDisplayName())
; 	If IsInBed(dom)

; 		if !IsInBed(sub) || (dom.GetDistance(sub) > 400)
; 			Seduce(sub, dom)
; 		EndIf 

; 		StartScene(dom, sub, FindBed(dom, 400, true))

; 		return
; 	elseif IsInBed(sub)
		
; 		if !IsInBed(dom) || (dom.GetDistance(sub) > 400)
; 			Seduce(dom, sub)
; 		EndIf

; 		StartScene(dom, sub, FindBed(sub, 400, true))

; 		return
; 	endif 

; 	ObjectReference bed = FindBed(sub, 2500)

; 	if !bed 
; 		bed = FindBed(dom, 2500)
; 	endif


; 	If bed == none 
; 		Seduce(dom, sub)
; 		StartScene(dom, sub)
; 	else 
; 		Seduce(dom, sub)
; 		if dom.GetDistance(sub) < 400
; 			TravelToBed(dom, sub, bed)
; 	    EndIf
; 		StartScene(dom, sub, bed)
; 	endif 

; EndFunction

; Function StartScene(actor dom, actor sub, ObjectReference bed = none)
; 	if dom.Is3DLoaded() && sub.Is3DLoaded()
; 		ostim.StartScene(dom, sub, bed = bed)
; 	endif
; EndFunction 

; Function TravelToBed(actor act1, actor act2, ObjectReference bed)
; 	PathTo(act1, bed)
; 	PathTo(act2, bed)


; 	int stuckCheckCount = 0
; 	float x = act1.x 

; 	While (act1.GetDistance(bed) > targetDistance) && act1.Is3DLoaded()
; 		Utility.Wait(1)

; 		if x == act1.X 
; 			stuckCheckCount += 1

; 			if stuckCheckCount > 10
; 				ClearAliases()
; 				return
; 				;stuckCheckCount = 0
; 			endif 
; 		else 
; 			stuckCheckCount = 0
; 			x = act1.x
; 		endif 
; 	EndWhile

; 	 stuckCheckCount = 0
; 	 x = act2.x 

; 	While (act2.GetDistance(bed) > targetDistance) && act2.Is3DLoaded()
; 		Utility.Wait(1)

; 		if x == act2.X 
; 			stuckCheckCount += 1

; 			if stuckCheckCount > 10
; 				ClearAliases()
; 				return
; 			endif 
; 		else 
; 			stuckCheckCount = 0
; 			x = act2.x
; 		endif
; 	EndWhile

; 	ClearAliases()
; EndFunction 

; Function Seduce(actor act1, actor act2)
; 	Pathto(act1, act2)

; 	int stuckCheckCount = 0
	 
; 	float x = act1.X
; 	While (act1.GetDistance(act2) > targetDistance) && act1.Is3DLoaded()
; 		Utility.Wait(1)

; 		if x == act1.X 
; 			stuckCheckCount += 1

; 			if stuckCheckCount > 10
; 				ClearAliases()
; 				return 
; 			elseif stuckCheckCount > 5
; 				;debug.SendAnimationEvent(act1, "IdleForceDefaultState")
; 				;stuckCheckCount = 0
; 			endif 
; 		else 
; 			stuckCheckCount = 0
; 			x = act1.x
; 		endif 
; 	EndWhile

; 	act1.SetLookAt(act2, abPathingLookAt = false)
; 	Utility.Wait(0.5)
; 	act2.SetLookAt(act1, abPathingLookAt = false)
; 	debug.SendAnimationEvent(act1, "IdleComeThisWay")
; 	Utility.Wait(2)

; 	ClearAliases()
; EndFunction

; bool Function IsInBed(actor act)
; 	return (act.GetSleepState() > 2)
; EndFunction

; Actor Function GetBedPartner(actor act)
; 	Actor[] actorsz = MiscUtil.ScanCellNPCS(act, radius = 64.0, HasKeyword = none)

; 	if actorsz.length > 1
; 		If actorsz[0] == act 
; 			return actorsz[1]
; 		else 
; 			return actorsz[0]
; 		endif 
; 	else 
; 		return none
; 	endif 
; EndFunction

; ObjectReference Function FindBed(ObjectReference CenterRef, Float Radius = 0.0, bool AllowUsed = false)
; 	objectreference[] Beds = OSANative.FindBed(CenterRef, Radius, 1000.0)

; 	ObjectReference NearRef = None

; 	Int i = 0
; 	Int L = Beds.Length
; 	While (i < L)
; 		ObjectReference Bed = Beds[i]
; 		If AllowUsed || (!Bed.IsFurnitureInUse())
; 			NearRef = Bed
; 			i = L
; 		Else
; 			i += 1
; 		EndIf
; 	EndWhile


; 	If (NearRef)
; 		Return NearRef
; 	EndIf

; 	Return None ; Nothing found in search loop
; EndFunction

; Bool Function IsActorInvalid(actor act)
; 	If  (act == none) || (act.IsInCombat()) || (act.IsGhost()) || (act.IsDead())  || (act.IsDisabled())|| !(act.is3dloaded()) || ostim.IsChild(act) || !(act.GetRace().HasKeyword(Keyword.GetKeyword("ActorTypeNPC"))) || act.IsInDialogueWithPlayer() || ostim.IsActorActive(act)
; 		oefConsole(3, "Invalid: " + act.GetDisplayName())
; 		return true
; 	else
; 		oefConsole(3, "Valid: " + act.GetDisplayName())		
; 		return false
; 	endif
; Endfunction

; Function PathTo(actor act, ObjectReference obj)
; 	oefConsole(4, "Pathing...")

; 	act.StartCombat(act)

; 	;act.EnableAI(false)
; 	;act.EnableAI(true)
; 	debug.SendAnimationEvent(act, "IdleForceDefaultState")

; 	TargetRef.ForceRefTo(obj)

; 	if Nav1.GetReference() == none
; 		Nav1.ForceRefTo(act)
; 	else 
; 		Nav2.ForceRefTo(act)
; 	endif

; 	act.EvaluatePackage()
; EndFunction 

; Function ClearAliases()
; 	Nav1.Clear()
; 	Nav2.Clear()
; 	TargetRef.clear()
; EndFunction

; Event OStimStart(string eventName, string strArg, float numArg, Form sender)
; 	sexCount += 1
; EndEvent

; Event OStimEnd(string eventName, string strArg, float numArg, Form sender)
; 	sexCount -= 1
; EndEvent 
