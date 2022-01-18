ScriptName OEFPlayerAliasScript Extends ReferenceAlias

OEFScript Property Main Auto

Event OnInit()
	Main = (GetOwningQuest()) as OEFScript
EndEvent

Event OnPlayerLoadGame()
	Main.OnLoad()
EndEvent

Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	main.OnLocChange(aknewloc)
endEvent
