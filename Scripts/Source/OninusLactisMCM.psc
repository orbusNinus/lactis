;
; ██╗      █████╗  ██████╗████████╗██╗███████╗    ███╗   ███╗ ██████╗███╗   ███╗
; ██║     ██╔══██╗██╔════╝╚══██╔══╝██║██╔════╝    ████╗ ████║██╔════╝████╗ ████║
; ██║     ███████║██║        ██║   ██║███████╗    ██╔████╔██║██║     ██╔████╔██║
; ██║     ██╔══██║██║        ██║   ██║╚════██║    ██║╚██╔╝██║██║     ██║╚██╔╝██║
; ███████╗██║  ██║╚██████╗   ██║   ██║███████║    ██║ ╚═╝ ██║╚██████╗██║ ╚═╝ ██║
; ╚══════╝╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═╝╚══════╝    ╚═╝     ╚═╝ ╚═════╝╚═╝     ╚═╝
;                                                                               

Scriptname OninusLactisMCM extends SKI_ConfigBase

OninusLactis Main

; option references
Int optionKeyStartLactating
Int optionOffsetLeftX ; Player offset
Int optionOffsetLeftY
Int optionOffsetLeftZ
Int optionEmitterScale ; Player emitter scale
Int optionGlobalEmitterScale
Int optionOStimIntegrationEnabled
Int optionOStimSpankSquirtDuration
Int optionOStimOrgasmSquirtDuration
Int optionOStimNonNakedSquirtEnabled
Int optionNippleLeakEnabled
Int optionDebugAxisEnabled
Int optionRandomYRotEnabled
Int optionRandomEmitterScaleEnabled
Int optionRandomEmitterDeactivationEnabled
Int optionResetAll
Int optionUninstall
Int optionExportMCMSettings
Int optionImportMCMSettings

; NPC offsets options
Int optionNpcConsole
Int optionNpcOffsetLeftX
Int optionNpcOffsetLeftY
Int optionNpcOffsetLeftZ
Int optionNpcScale
Int optionNpcDelete
Int[] optionNpcActors
Int[] optionNpcActorsNearby
Actor[] nearbyActors


int function GetVersion()
	return 2
endFunction

Event OnConfigInit()
	Init()
	Pages = new string[2]
	Pages[0] = "Settings"
	Pages[1] = "Actor Offsets"
EndEvent

Function Init()
    Parent.OnGameReload()
    Main = (Self as Quest) as OninusLactis	
EndFunction

event OnVersionUpdate(int a_version)
	; a_version is the new version, CurrentVersion is the old version
	if (a_version >= 2 && CurrentVersion < 2)
		; Debug.Trace(self + ": Updating script to version 2")
		Pages = new string[2]
		Pages[0] = "Settings"
		Pages[1] = "Actor Offsets"
	endIf
endEvent

event OnConfigOpen()
	{Called when this config menu is opened}
	nearbyActors = GetNearbyFemaleActors()
endEvent

event OnConfigClose()
	{Called when this config menu is closed}
	; nearbyActors = None
endEvent

Event OnPageReset(string page)
    If Page == "" || Page == "Settings"
        SetCursorFillMode(TOP_TO_BOTTOM)
        AddHeaderOption("Keyboard (Manual mode)")        
        optionKeyStartLactating = AddKeyMapOption("Toggle nipple squirt key", Main.StartLactatingKey)
		AddHeaderOption("Player Nipple Offset")
        optionOffsetLeftX = AddSliderOption("Left / Right", Main.NippleOffsetL[0], "{2}")        
        optionOffsetLeftY = AddSliderOption("Up / Down", Main.NippleOffsetL[2], "{2}")
        optionOffsetLeftZ = AddSliderOption("Back / Forth", Main.NippleOffsetL[1], "{2}")
		optionEmitterScale = AddSliderOption("Emitter scale", Main.EmitterScale, "{2}")
		if Main.HasOStim()
			AddHeaderOption("OStim integration")
			optionOStimIntegrationEnabled = AddToggleOption("Enable OStim integration", Main.OStimIntegrationEnabled)
			int flags = 0
			If !Main.OStimIntegrationEnabled
				flags = OPTION_FLAG_DISABLED
			EndIf
			optionOStimSpankSquirtDuration = AddSliderOption("Spank squirt duration", Main.OStimSpankSquirtDuration, "{2}", flags)        
			optionOStimOrgasmSquirtDuration = AddSliderOption("Orgasm squirt duration", Main.OStimOrgasmSquirtDuration, "{2}", flags)        
			optionOStimNonNakedSquirtEnabled = AddToggleOption("Nipple squirt when not naked", Main.OStimNonNakedSquirtEnabled, flags)
		endif		

		SetCursorPosition(1)
		AddHeaderOption("Global settings")
		optionDebugAxisEnabled = AddToggleOption("Enable debug axis", Main.DebugAxisEnabled)
		optionGlobalEmitterScale = AddSliderOption("Global emitter scale", Main.GlobalEmitterScale, "{2}") 		
		optionNippleLeakEnabled = AddToggleOption("Enable nipple leak (CBBE EffectShader)", Main.NippleLeakEnabled)
		
		AddHeaderOption("Maintenance")
		; optionRandomYRotEnabled = AddToggleOption("Enable random Y rotation", Main.UseRandomYRotation)
		; optionRandomEmitterScaleEnabled = AddToggleOption("Enable random emitter scale", Main.UseRandomEmitterScale)
		; optionRandomEmitterDeactivationEnabled = AddToggleOption("Enable random emitter deactivation", Main.UseRandomEmitterDeactivation)		
		
		AddTextOption("Active nipple squirts", Main.GetArmoredActorsCount() )
		optionResetAll = AddTextOption("Reset all", "Click")

		AddHeaderOption("Export / Import MCM Settings")
		optionExportMCMSettings = AddTextOption("Export MCM settings", "Click")		
		optionImportMCMSettings = AddTextOption("Import MCM settings", "Click")		

		AddEmptyOption()
		optionUninstall = AddTextOption("Uninstall Lactis", "Uninstall")
		AddTextOption("Version", Main.GetVersion(), OPTION_FLAG_DISABLED)
	ElseIf Page == "Actor Offsets"		
		SetCursorFillMode(TOP_TO_BOTTOM)
        AddHeaderOption("Actor Nipple Offsets")
		Actor actorRef = GetTargetActor("Console")
		int flags = 0
		If actorRef==None
			flags = OPTION_FLAG_DISABLED
		EndIf
		optionNpcConsole = AddTextOption("Console: " + ActorName(actorRef), "Select", flags)
		AddEmptyOption()
		AddHeaderOption("Stored actor offsets")
		int npcCount = Main.actorStorage.GetNpcStorageCount()
		int i=0
		optionNpcActors = Utility.CreateIntArray(npcCount)
		while i<npcCount
			optionNpcActors[i] = AddTextOption(ActorName(Main.actorStorage.GetNpcActor(i)), "Select")
			i = i+1
		endwhile

		AddEmptyOption()
		AddHeaderOption("Nearby actors")		
		optionNpcActorsNearby = Utility.CreateIntArray(nearbyActors.Length)
		i=0
		while i<nearbyActors.Length
		optionNpcActorsNearby[i] = AddTextOption(ActorName(nearbyActors[i]), "Select")
			i = i+1
		endwhile

		SetCursorPosition(1)
		if selectedActor
			AddHeaderOption(ActorName(selectedActor))			
			if !Main.actorStorage.HasNpcStorage(selectedActor)
				Main.actorStorage.InitNpcStorage(selectedActor)
			endif
			float[] offset = Main.actorStorage.GetNpcOffset(selectedActor)
			optionNpcOffsetLeftX = AddSliderOption("NPC Left / Right", offset[0], "{2}")        
        	optionNpcOffsetLeftY = AddSliderOption("NPC Up / Down", offset[2], "{2}")
        	optionNpcOffsetLeftZ = AddSliderOption("NPC Back / Forth", offset[1], "{2}")
			optionNpcScale = AddSliderOption("NPC Emitter Scale", Main.actorStorage.GetNpcScale(selectedActor), "{2}")
			AddEmptyOption()
			optionNpcDelete = AddTextOption("Delete actor offsets", "Delete")
		endif

    EndIF
EndEvent

event OnOptionSelect(int option)
	if (option == optionOStimIntegrationEnabled)
		Main.OStimIntegrationEnabled = !Main.OStimIntegrationEnabled
		if Main.OStimIntegrationEnabled
			Main.RegisterForOStimEvents()
		Else
			Main.UnregisterForOStimEvents()
		endif
		SetToggleOptionValue(optionOStimIntegrationEnabled, Main.OStimIntegrationEnabled)
		ForcePageReset()
	elseif (option == optionOStimNonNakedSquirtEnabled)
		Main.OStimNonNakedSquirtEnabled = !Main.OStimNonNakedSquirtEnabled
		SetToggleOptionValue(optionOStimNonNakedSquirtEnabled, Main.OStimNonNakedSquirtEnabled)
	elseif (option == optionNippleLeakEnabled)
		Main.NippleLeakEnabled = !Main.NippleLeakEnabled
		SetToggleOptionValue(optionNippleLeakEnabled, Main.NippleLeakEnabled)		
	elseif (option == optionDebugAxisEnabled)
		Main.DebugAxisEnabled = !Main.DebugAxisEnabled
		SetToggleOptionValue(optionDebugAxisEnabled, Main.DebugAxisEnabled)
	elseif (option == optionRandomYRotEnabled)		
		Main.UseRandomYRotation = !Main.UseRandomYRotation
		SetToggleOptionValue(optionRandomYRotEnabled, Main.UseRandomYRotation)		
	elseif (option == optionRandomEmitterScaleEnabled)		
		Main.UseRandomEmitterScale = !Main.UseRandomEmitterScale
		SetToggleOptionValue(optionRandomEmitterScaleEnabled, Main.UseRandomEmitterScale)
	elseif (option == optionRandomEmitterDeactivationEnabled)		
		Main.UseRandomEmitterDeactivation = !Main.UseRandomEmitterDeactivation
		SetToggleOptionValue(optionRandomEmitterDeactivationEnabled, Main.UseRandomEmitterDeactivation)
	ElseIf (option == optionResetAll)
		Main.StopAllNippleSquirts()		
	ElseIf option == optionUninstall
		Main.Uninstall()
		ShowMessage("You should save and exit the game now. Then disable the Lactis mod, start game, reload the save. Walk around, wait some time, save and exit game. Then use Resaver to clean the save.", false)
	ElseIf option == optionExportMCMSettings		
		If ShowMessage("Lactis MCM setttings will be exported to file 'SKSE/Plugins/Lactis/MCM_Settings.json'", a_withCancel=true) == true
			SetOptionFlags(optionExportMCMSettings, OPTION_FLAG_DISABLED)
			bool result = ExportSettings()
			If result == true
				ShowMessage("Lactis MCM settings exported succesfully. You can find the file at 'SKSE/Plugins/Lactis/MCM_Settings.json'", false)
			else
				ShowMessage("Lactis MCM settings export failed.", false)
			endIf
			SetOptionFlags(optionExportMCMSettings, OPTION_FLAG_NONE)
		endIf				
	ElseIf option == optionImportMCMSettings
		If ShowMessage("Import Lactis MCM settings from 'SKSE/Plugins/Lactis/MCM_Settings.json'?", true) == true
			SetOptionFlags(optionImportMCMSettings, OPTION_FLAG_DISABLED)			
			int result = ImportSettings()
			If result==1
				ShowMessage("Lactis MCM settings imported succesfully from 'SKSE/Plugins/Lactis/MCM_Settings.json'.", false)
			elseIf result == 0
				ShowMessage("Lactis MCM settings file not found. Check if the file exists at 'SKSE/Plugins/Lactis/MCM_Settings.json'", false)
			else
				ShowMessage("Lactis MCM settings import failed.", false)
			endIf
			SetOptionFlags(optionImportMCMSettings, OPTION_FLAG_NONE)
		endIf		
	ElseIf (option == optionNpcConsole)
		SetSelectedActor(GetTargetActor("Console"))
	ElseIf optionNpcActors.Find(option)>=0
		SetSelectedActor(Main.actorStorage.GetNpcActor(optionNpcActors.Find(option)))
	ElseIf optionNpcActorsNearby.Find(option)>=0
		SetSelectedActor(nearbyActors[optionNpcActorsNearby.Find(option)])
	elseif option == optionNpcDelete
		Main.actorStorage.DeleteNpcStorage(selectedActor)
		selectedActor = None
		ForcePageReset()
	endIf

endEvent

event OnOptionSliderOpen(int option)
	Actor actorRef = GetSelectedActor()

	if (option == optionOffsetLeftX)
		SetSliderDialogStartValue(Main.NippleOffsetL[0])
		SetSliderDialogDefaultValue(0.0)
		SetSliderDialogRange(-8.0, 8.0)
		SetSliderDialogInterval(0.1)
	elseIf (option == optionOffsetLeftY)
		SetSliderDialogStartValue(Main.NippleOffsetL[2])
		SetSliderDialogDefaultValue(0.0)
		SetSliderDialogRange(-16.0, 1.0)
		SetSliderDialogInterval(0.1)
	elseIf (option == optionOffsetLeftZ)
		SetSliderDialogStartValue(Main.NippleOffsetL[1])
		SetSliderDialogDefaultValue(0.0)
		SetSliderDialogRange(-4.0, 8.0)
		SetSliderDialogInterval(0.1)
	elseIf option == optionEmitterScale
		SetSliderDialogStartValue(Main.EmitterScale)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(0.1, 4.0)
		SetSliderDialogInterval(0.1)
	elseIf (option == optionGlobalEmitterScale)
		SetSliderDialogStartValue(Main.GlobalEmitterScale)
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(0.1, 4.0)
		SetSliderDialogInterval(0.1)
	elseIf (option == optionOStimSpankSquirtDuration)
		SetSliderDialogStartValue(Main.OStimSpankSquirtDuration)
		SetSliderDialogDefaultValue(1.5)
		SetSliderDialogRange(0.2, 5.0)
		SetSliderDialogInterval(0.05)
	elseIf (option == optionOStimOrgasmSquirtDuration)
		SetSliderDialogStartValue(Main.OStimOrgasmSquirtDuration)
		SetSliderDialogDefaultValue(3.0)
		SetSliderDialogRange(1.0, 15.0)
		SetSliderDialogInterval(1.0)
	; NPC offsets
	elseif (option == optionNpcOffsetLeftX)		
		if actorRef 
			if !Main.actorStorage.HasNpcStorage(actorRef)
				Main.actorStorage.InitNpcStorage(actorRef)
			endif
			float[] offset = Main.actorStorage.GetNpcOffset(actorRef)
			SetSliderDialogStartValue(offset[0])
			SetSliderDialogDefaultValue(0.0)
			SetSliderDialogRange(-14.0, 7.0)
			SetSliderDialogInterval(0.1)
			
		endIf
	elseIf (option == optionNpcOffsetLeftY)		
		if actorRef 
			if !Main.actorStorage.HasNpcStorage(actorRef)
				Main.actorStorage.InitNpcStorage(actorRef)
			endif
			float[] offset = Main.actorStorage.GetNpcOffset(actorRef)
			SetSliderDialogStartValue(offset[2])
			SetSliderDialogDefaultValue(0.0)
			SetSliderDialogRange(-16.0, 1.0)
			SetSliderDialogInterval(0.1)
		endif
	elseIf (option == optionNpcOffsetLeftZ)
		if actorRef 
			if !Main.actorStorage.HasNpcStorage(actorRef)
				Main.actorStorage.InitNpcStorage(actorRef)
			endif
			float[] offset = Main.actorStorage.GetNpcOffset(actorRef)
			SetSliderDialogStartValue(offset[1])
			SetSliderDialogDefaultValue(0.0)
			SetSliderDialogRange(-7.0, 7.0)
			SetSliderDialogInterval(0.1)
		endif
	ElseIf (option == optionNpcScale)
		if actorRef
			if !Main.actorStorage.HasNpcStorage(actorRef)
				Main.actorStorage.InitNpcStorage(actorRef)
			endif
			float scale = Main.actorStorage.GetNpcScale(actorRef)
			SetSliderDialogStartValue(scale)
			SetSliderDialogDefaultValue(1.0)
			SetSliderDialogRange(0.1, 3.0)
			SetSliderDialogInterval(0.1)
		endif
	endIf

endEvent

event OnOptionSliderAccept(int option, float value)
	Actor actorRef = GetSelectedActor()

	if (option == optionOffsetLeftX)
		Main.NippleOffsetL[0] = value
		SetSliderOptionValue(optionOffsetLeftX, Main.NippleOffsetL[0], "{2}")
	elseIf (option == optionOffsetLeftY)
		Main.NippleOffsetL[2] = value
		SetSliderOptionValue(optionOffsetLeftY, Main.NippleOffsetL[2], "{2}")
	elseIf (option == optionOffsetLeftZ)
		Main.NippleOffsetL[1] = value
		SetSliderOptionValue(optionOffsetLeftZ, Main.NippleOffsetL[1], "{2}")
	elseIf option == optionEmitterScale
		Main.EmitterScale = value		
		SetSliderOptionValue(optionEmitterScale, Main.EmitterScale, "{2}")
	elseIf (option == optionGlobalEmitterScale)
		Main.GlobalEmitterScale = value
		SetSliderOptionValue(optionGlobalEmitterScale, Main.GlobalEmitterScale, "{2}")        		
	elseIf (option == optionOStimSpankSquirtDuration)
		Main.OStimSpankSquirtDuration = value
		SetSliderOptionValue(optionOStimSpankSquirtDuration, Main.OStimSpankSquirtDuration, "{2}")        		
	elseIf (option == optionOStimOrgasmSquirtDuration)
		Main.OStimOrgasmSquirtDuration = value
		SetSliderOptionValue(optionOStimOrgasmSquirtDuration, Main.OStimOrgasmSquirtDuration, "{2}")        				
	elseif (option == optionNpcOffsetLeftX)				
		if actorRef
			Main.actorStorage.SetNpcOffsetIndex(actorRef, 0, value)
			SetSliderOptionValue(optionNpcOffsetLeftX, value, "{2}")
		endif
	elseIf (option == optionNpcOffsetLeftY)		
		if actorRef
			Main.actorStorage.SetNpcOffsetIndex(actorRef, 2, value)
			SetSliderOptionValue(optionNpcOffsetLeftY, value, "{2}")
		endif
	elseIf (option == optionNpcOffsetLeftZ)
		if actorRef
			Main.actorStorage.SetNpcOffsetIndex(actorRef, 1, value)
			SetSliderOptionValue(optionNpcOffsetLeftZ, value, "{2}")
		endif		
	elseIf (option == optionNpcScale)
		if actorRef
			Main.actorStorage.SetNpcScale(actorRef, value)
			SetSliderOptionValue(optionNpcScale, value, "{2}")
		endif				
	endIf	
endEvent

Event OnOptionKeyMapChange(Int Option, Int KeyCode, String ConflictControl, String ConflictName)
	; Main.PlayTickBig()
    MiscUtil.PrintConsole("KeyMap Option: "+ Option + ", KeyCode: " + KeyCode + ", optionKeyStartLactating: " + optionKeyStartLactating)
	If (Option == optionKeyStartLactating)		
        Main.RemapStartLactatingKey(KeyCode)
		SetKeyMapOptionValue(Option, KeyCode)
    Else
        MiscUtil.PrintConsole("KeyMap Option: Unknown/unsupported/niy option " + Option + " changed.")
    EndIf
EndEvent

event OnOptionHighlight(int option)
	{Called when the user highlights an option}
	
	if option == optionKeyStartLactating
		SetInfoText("Key for toggling nipple squirting on/off on the player. Does not work during OStim scenes.")
	elseIf option == optionOffsetLeftX || option == optionOffsetLeftY || option == optionOffsetLeftZ
		SetInfoText("Offset for the player's nipple squirt emitter origin. Adjust to match the player's body. Note that the offset will be used for both breasts, x offset will be adjusted for each side.")
	; elseIf option == optionOffsetRightX || option == optionOffsetRightY || option == optionOffsetRightZ
	; 	SetInfoText("Offset for the right nipple squirt emitter origin. Adjust to match the player's body.")
	elseIf option == optionEmitterScale
		SetInfoText("Scaling for the player's nipple squirt emitter.")
	elseif option == optionGlobalEmitterScale
		SetInfoText("Global emitter scale for all left and right emitters. Applies to all actors including the player.")
	elseif option == optionOStimIntegrationEnabled
		SetInfoText("Enables OStim integration. Female actors will nipple squirt on spank and orgasm during an OStim scene.")
	elseif option == optionOStimSpankSquirtDuration
		SetInfoText("Nipple squirt duration on spank (in seconds).")
	elseif option == optionOStimOrgasmSquirtDuration
		SetInfoText("Nipple squirt duration on orgasm (in seconds).")
	elseif option == optionOStimNonNakedSquirtEnabled
		SetInfoText("Nipple squirt even when actor is not naked. This might help with revealing armors/clothing.")
	elseif option == optionNippleLeakEnabled
		SetInfoText("Enables an CBBE overlay texture which simulates nipple leak.")
	elseif option == optionDebugAxisEnabled
		SetInfoText("Enables a debug axis for nipple offset adjustments.")
	elseif option == optionRandomYRotEnabled || option == optionRandomEmitterScaleEnabled || option == optionRandomEmitterDeactivationEnabled
		SetInfoText("Experimental feature which may result in unpredictable behaviour. Dont't use it.")
	elseif option == optionResetAll
		SetInfoText("Removes nipple squirt effect from all actors.")
	elseif option == optionNpcConsole
		SetInfoText("Click this entry to set the current console selection as the selected actor. Only works for female actors.")
	ElseIf optionNpcActors.Find(option)>=0
		SetInfoText("Click this entry to set as the selected actor.")
	ElseIf optionNpcActorsNearby.Find(option)>=0
		SetInfoText("Click this entry to set as the selected actor.")
	elseif option == optionNpcOffsetLeftX || option == optionNpcOffsetLeftY || option == optionNpcOffsetLeftZ
		SetInfoText("Offset for the selected actor's nipple squirt emitter origin. Adjust to match the selected actor's body. Note that the offset will be used for both breasts, x offset will be adjusted for each side.")		
	elseif option == optionNpcScale
		SetInfoText("Scaling for the selected actor's nipple squirt emitter.")
	elseif option == optionNpcDelete
		SetInfoText("Delete the selected actor's values and remove the actor from the list of stored actors.")
	else 
		SetInfoText("")
	endIf
endEvent

; Selected actor on the MCM actor offsets page
Actor selectedActor = None

Function SetSelectedActor(Actor actorRef)
	selectedActor = actorRef
	ForcePageReset()
EndFunction

Actor Function GetSelectedActor()
	return selectedActor
EndFunction

Actor Function GetTargetActor(string targetKind)
	If targetKind == "Player"
		return Main.PlayerRef
	ElseIf targetKind == "Crosshair"
		return Game.GetCurrentCrosshairRef() as Actor
	ElseIf targetKind == "Console"
		return Game.GetCurrentConsoleRef() as Actor
	Else
		return None
	EndIf
EndFunction

String Function ActorName(Actor actorRef, String default="N/A")
	If actorRef
		return actorRef.GetLeveledActorBase().GetName()
	Else
		return default
	EndIf
EndFunction

Actor[] Function GetNearbyFemaleActors()
	Actor[] actors = MiscUtil.ScanCellNPCs(Main.PlayerRef)
	; remove player actor from the list
	actors = PapyrusUtil.RemoveActor(actors, Main.PlayerRef)

	int i = actors.length - 1
	Actor actorAtIndex = None

	Keyword actorKeyword = Keyword.GetKeyword("ActorTypeNPC")

	; iterating reversed as we modify the array
	while i>=0
		actorAtIndex = actors[i]
		; remove all non-female actors
		if actorAtIndex.GetActorBase().GetSex()!=1
			actors = PapyrusUtil.RemoveActor(actors, actorAtIndex)
		endif
		; remove all actors which already have their offset stored
		if Main.actorStorage.HasNpcStorage(actorAtIndex)
			actors = PapyrusUtil.RemoveActor(actors, actorAtIndex)
		endif
		; remove all actors which do not have the "ActorTypeNPC" keyword
		if !actorAtIndex.HasKeyword(actorKeyword)
			actors = PapyrusUtil.RemoveActor(actors, actorAtIndex)
		endif
		i -= 1
	endwhile

	return actors
EndFunction


Bool Function ExportSettings()
	String filename = "../Lactis/MCM_Settings"
	Bool result

	JsonUtil.SetIntValue(filename, "optionKeyStartLactating", Main.StartLactatingKey as int)
	JsonUtil.SetFloatValue(filename, "optionOffsetLeftX", Main.NippleOffsetL[0])
	JsonUtil.SetFloatValue(filename, "optionOffsetLeftY", Main.NippleOffsetL[2])
	JsonUtil.SetFloatValue(filename, "optionOffsetLeftZ", Main.NippleOffsetL[1])
	JsonUtil.SetIntValue(filename, "optionOStimIntegrationEnabled", Main.OStimIntegrationEnabled as int)
	JsonUtil.SetFloatValue(filename, "optionOStimSpankSquirtDuration", Main.OStimSpankSquirtDuration)	
	JsonUtil.SetFloatValue(filename, "optionOStimOrgasmSquirtDuration", Main.OStimOrgasmSquirtDuration)
	JsonUtil.SetIntValue(filename, "optionOStimNonNakedSquirtEnabled", Main.OStimNonNakedSquirtEnabled as int)
	JsonUtil.SetIntValue(filename, "optionDebugAxisEnabled", Main.DebugAxisEnabled as int)
	JsonUtil.SetFloatValue(filename, "optionGlobalEmitterScale", Main.GlobalEmitterScale)
	JsonUtil.SetIntValue(filename, "optionNippleLeakEnabled", Main.NippleLeakEnabled as int)

	result = JsonUtil.Save(filename)
	Return result
EndFunction

Int Function ImportSettings()
	String filename = "../Lactis/MCM_Settings"

	If JsonUtil.JsonExists(filename) == false
		return 0
	elseIf JsonUtil.IsGood(filename) == false
		return -1
	endIf

	Main.StartLactatingKey = JsonUtil.GetIntValue(filename, "optionKeyStartLactating")
	Main.RemapStartLactatingKey(Main.StartLactatingKey)
	SetKeyMapOptionValue(optionKeyStartLactating, Main.StartLactatingKey)

	Main.NippleOffsetL[0] = JsonUtil.GetFloatValue(filename, "optionOffsetLeftX")
	SetSliderOptionValue(optionOffsetLeftX, Main.NippleOffsetL[0], "{2}")

	Main.NippleOffsetL[2] = JsonUtil.GetFloatValue(filename, "optionOffsetLeftY")
	SetSliderOptionValue(optionOffsetLeftY, Main.NippleOffsetL[2], "{2}")

	Main.NippleOffsetL[1] = JsonUtil.GetFloatValue(filename, "optionOffsetLeftZ")
	SetSliderOptionValue(optionNpcOffsetLeftY, Main.NippleOffsetL[1], "{2}")

	Main.OStimIntegrationEnabled = JsonUtil.GetIntValue(filename, "optionOStimIntegrationEnabled") as bool
	SetToggleOptionValue(optionOStimIntegrationEnabled, Main.OStimIntegrationEnabled) 

	Main.OStimSpankSquirtDuration = JsonUtil.GetFloatValue(filename, "optionOStimSpankSquirtDuration") 
	SetSliderOptionValue(optionOStimSpankSquirtDuration, Main.OStimSpankSquirtDuration, "{2}")    

	Main.OStimOrgasmSquirtDuration = JsonUtil.GetFloatValue(filename, "optionOStimOrgasmSquirtDuration") 
	SetSliderOptionValue(optionOStimOrgasmSquirtDuration, Main.OStimOrgasmSquirtDuration, "{2}")    

	Main.OStimNonNakedSquirtEnabled = JsonUtil.GetIntValue(filename, "optionOStimNonNakedSquirtEnabled") as bool
	SetToggleOptionValue(optionOStimNonNakedSquirtEnabled, Main.OStimNonNakedSquirtEnabled) 

	Main.DebugAxisEnabled = JsonUtil.GetIntValue(filename, "optionDebugAxisEnabled") as bool
	SetToggleOptionValue(optionDebugAxisEnabled, Main.DebugAxisEnabled) 

	Main.GlobalEmitterScale = JsonUtil.GetFloatValue(filename, "optionGlobalEmitterScale") 
	SetSliderOptionValue(optionGlobalEmitterScale, Main.GlobalEmitterScale, "{2}")    

	Main.NippleLeakEnabled = JsonUtil.GetIntValue(filename, "optionNippleLeakEnabled") as bool
	SetToggleOptionValue(optionNippleLeakEnabled, Main.NippleLeakEnabled) 

	ForcePageReset()
	return 1
EndFunction