ScriptName OEFScript extends Quest

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


float DebugLevel
float ScanFreq
bool AllowPlayer
bool AllowNPC
float PlayerChance
bool UseRelationship
float MaxGroups
float SearchRadius
float[] GroupWeights

float Function GetDebugLevel()
	return OEFDebugLevel.GetValue()
EndFunction

float Function GetScanFreq()
	return OEFScanFreq.GetValue()
EndFunction

bool Function GetAllowPlayer()
	return (OEFAllowPlayer.GetValue() == 1)
EndFunction

bool Function GetAllowNPC()
	return (OEFAllowNPC.GetValue() == 1)
EndFunction

float Function GetPlayerChance()
	return OEFPlayerChance.GetValue()
EndFunction

bool Function GetUseRelationship()
	return (OEFUseRelationship.GetValue() == 1)
EndFunction

float Function GetMaxGroups()
	return OEFMaxGroups.GetValue()
EndFunction

float Function GetSearchRadius()
	return OEFSearchRadius.GetValue()
EndFunction

Float[] Function GetGroupWeights()
	float[] weights = new Float[3]
	weights[0] = OEFWT_MM.GetValue()
	weights[1] = OEFWT_FF.GetValue()
	weights[2] = OEFWT_MF.GetValue()
	return weights
EndFunction

Function ReadConfig()
	DebugLevel = GetDebugLevel()
	ScanFreq = GetScanFreq()
	AllowPlayer = GetAllowPlayer()
	AllowNPC = GetAllowNPC()
	PlayerChance = GetPlayerChance()
	UseRelationship = GetUseRelationship()
	MaxGroups = GetMaxGroups()
	SearchRadius = GetSearchRadius()
	GroupWeights = GetGroupWeights()
EndFunction
;;;;;

;;;;; debug messages
string debugPrefix = "Eager Followers: "
function oefConsole(int d, string msg)
	if (d <= DebugLevel)
		OsexIntegrationMain.Console(debugPrefix + msg)
	endif 
EndFunction

function oefMessage(int d, string msg)
	if (d <= DebugLevel)
		debug.MessageBox(debugPrefix + msg)
	endif
EndFunction

function oefNotification(int d, string msg)
	if (d <= DebugLevel)
		debug.Notification(debugPrefix + msg)
	endif
EndFunction
;;;;;

;;;;; story messaging
function storyNotification(string msg)
	debug.Notification(msg)
EndFunction

function storyFinding(actor act)
	int i = ostim.RandomInt(0,4)
	string finding_string = ""
	if i == 0
		finding_string = " wants to fuck somebody"
	elseif i == 1
		finding_string = " is getting antsy and wants to get handsy"
	elseif i == 2
		finding_string = " is scouring for someone to get down and dirty with"
	elseif i == 3
		finding_string = " is trying to find someone for sex"
	endif
	storyNotification(act.GetDisplayName() + finding_string)
EndFunction

function storyFound(actor act, actor partner)
	int i = ostim.RandomInt(4)
	string found_string = ""
	if i == 0
		found_string = act.GetDisplayName() + " is having sex with " + partner.GetDisplayName()
	elseif i == 1
		found_string = act.GetDisplayName() + " is fucking " + partner.GetDisplayName()
	elseif i == 2
		found_string = act.GetDisplayName() + " and " + partner.GetDisplayName() + " are getting it on"
	else
		found_string = act.GetDisplayName() + " and " + partner.GetDisplayName() + " are doing the dirty"
	endif
	storyNotification(found_string)
endfunction

function storyNotFound(actor act)
	int i = ostim.RandomInt(4)
	string notfound_string = ""
	if i == 0
		notfound_string = "Bummer! " + act.GetDisplayName() + " didn't find anybody worthwhile"
	elseif i == 1
		notfound_string = "Sadness! " + act.GetDisplayName() + " couldn't find anyone to fuck"
	elseif i == 2
		notfound_string = "Lamentations! Nobody here is worthy enough to have sex with " + act.GetDisplayName()
	Else
		notfound_string = "Such agony! No one here is deserving of "  + act.GetDisplayName()
	endif
	storyNotification(notfound_string)
EndFunction
;;;;;

; variables
actor playerRef

OsexIntegrationMain ostim

ReferenceAlias Nav1
ReferenceAlias Nav2
ReferenceAlias TargetRef

AssociationType spouse
AssociationType courting

actor[] actors

faction followerFaction

int groupCount = 0

bool scanning = false

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

	spouse = Game.GetFormFromFile(0x0142CA, "Skyrim.esm") as AssociationType
	courting = Game.GetFormFromFile(0x01EE23, "Skyrim.esm") as AssociationType

	RegisterForModEvent("ostim_start", "OstimStart")
	RegisterForModEvent("ostim_end", "OstimEnd")

	oefNotification(0, "Initialized")

	OnLoad()
EndEvent

Function OnLoad()
	RegisterForSingleUpdate(ScanFreq)
EndFunction

Event OStimStart(string eventName, string strArg, float numArg, Form sender)
	groupCount += 1
EndEvent

Event OStimEnd(string eventName, string strArg, float numArg, Form sender)
	groupCount -= 1
EndEvent 

Event OnUpdate()
	oefConsole(5, "Reading new config from UI")
	ReadConfig()
	oefConsole(5, "Running update")
	if scanning
		oefConsole(5, "A scan is already in progress")
	elseif playerRef.IsInCombat()
		oefConsole(5, "Player in combat")
	elseif groupCount >= MaxGroups
		oefConsole(5, "Maximum number of sex groups reached")
	else
		ScanForSex()
	EndIf
	oefConsole(5, "Update finished")
	RegisterForSingleUpdate(ScanFreq)
EndEvent

Function OnLocChange(Location NewLoc)
 	oefConsole(3, "Changed location to " + NewLoc.GetName())
 	RegisterForSingleUpdate(ScanFreq)
EndFunction

Function ScanForSex()
 	oefConsole(1, "Starting a scan")
 	scanning = True
 	actor act = GetRandomFollower()
 	If act
 		oefConsole(1, "Found actor " + act.GetDisplayName())
		storyFinding(act)
		actor partner  = FindCompatiblePartner(act) ;, AllowPlayer, PlayerChance, UseRelationship)
		if partner 
			oefConsole(1, "Found partner " + partner.GetDisplayName())
			storyFound(act, partner) ;.GetDisplayName() + " is eyeing " + partner.GetDisplayName())
			doSex(act, partner)
		Else
			oefConsole(1, "Could not find any partner")
		endif
	Else
		oefConsole(1, "Could not find any actor")
	endif
 	scanning = false
EndFunction

; int Function WeightedSelect(int[] arr)
; 	int l = arr.length
; 	int i = 0
; 	if l == 0
; 		return -1
; 	endif
; 	int arrSum = 0
; 	while i < l 
; 		arrSum += arr[i]
; 		i += 1
; 	endwhile
; 	i = 0
; 	int s = OStim.RandomInt(0, arrSum)
; 	while i < l && s < arr[i]
; 		s -= arr[i]
; 		i += 1
; 	endwhile
; 	return i
; EndFunction

Actor[] Function ShuffleActorArray(Actor[] arr)
    
     int i = arr.length
     int j ; an index

    actor temp
    While (i > 0)
        i -= 1
        j = OStim.RandomInt(0, i)

        temp = arr[i]
        arr[i] = arr[j]
        arr[j] = temp 

    EndWhile
    return arr
EndFunction

Actor Function GetRandomFollower()
	if AllowNPC
		actors = MiscUtil.ScanCellNPCs(CenterOn = playerRef, radius = SearchRadius)
	else
		actors = MiscUtil.ScanCellNPCsByFaction(FindFaction = followerFaction, CenterOn = playerRef, radius = SearchRadius)
	endif
	actors = ShuffleActorArray(actors)
	int i = 0
	int l = actors.length 
	While i < l 
		If !IsActorInvalid(actors[i]) && !(actors[i] == playerRef)
			actor cact = actors[i]
			actors[i] = none
			return cact
		else
			actors[i] = none
		endif
		i += 1
	EndWhile
	return none
EndFunction

Actor Function FindCompatiblePartner(actor act)
	oefConsole(1, "Getting partner for " + act.GetDisplayName())

	actors = ShuffleActorArray(actors)

	int i = 0
	int l = actors.length 

	actor partner
	While i < l 
		partner = actors[i]
		if !IsActorInValid(partner) && (AllowPlayer || partner != playerRef) && (!UseRelationship || CompatibleRelationship(act, partner))
			return partner
		endif
		i += 1
	EndWhile

	return none
EndFunction

bool Function CompatibleRelationship(actor act, actor prt)
	if act.GetRelationshipRank(prt) >= 4 || act.HasAssociation(spouse, prt) || act.HasAssociation(courting, prt)
		return True
	Endif
	return False
EndFunction

; float targetDistance = 256.0

Function DoSex(actor dom, actor sub)
 	storyNotification(dom.GetDisplayName() + " is having sex with " + sub.GetDisplayName())
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
 		StartScene(dom, sub)
; 	else 
; 		Seduce(dom, sub)
; 		if dom.GetDistance(sub) < 400
; 			TravelToBed(dom, sub, bed)
; 	    EndIf
; 		StartScene(dom, sub, bed)
; 	endif 

EndFunction

Function StartScene(actor dom, actor sub, ObjectReference bed = none)
	if dom.Is3DLoaded() && sub.Is3DLoaded()
		ostim.StartScene(dom, sub, bed = bed)
	endif
EndFunction 

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

Bool Function IsActorInvalid(actor act)
	If  (act == none) || (act.IsInCombat()) || (act.IsGhost()) || (act.IsDead())  || (act.IsDisabled())|| !(act.is3dloaded()) || ostim.IsChild(act) || !(act.GetRace().HasKeyword(Keyword.GetKeyword("ActorTypeNPC"))) || act.IsInDialogueWithPlayer() || ostim.IsActorActive(act)
		oefConsole(3, "Invalid: " + act.GetDisplayName())
		return true
	else
		oefConsole(3, "Valid: " + act.GetDisplayName())		
		return false
	endif
Endfunction

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

