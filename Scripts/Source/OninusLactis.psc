;
; ██╗      █████╗  ██████╗████████╗██╗███████╗
; ██║     ██╔══██╗██╔════╝╚══██╔══╝██║██╔════╝
; ██║     ███████║██║        ██║   ██║███████╗
; ██║     ██╔══██║██║        ██║   ██║╚════██║
; ███████╗██║  ██║╚██████╗   ██║   ██║███████║
; ╚══════╝╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═╝╚══════╝
;								
; If you are a mod developer and want to integrate the nipple squirt effect 
; into your own mod, use the following public API. See the indiviudal functions
; for documentation.
;
; Public API
; ---
;
; + StartNippleSquirt(Actor actorRef, int level=0)
; + StopNippleSquirt(Actor actorRef) 
; + ToggleNippleSquirt(Actor actorRef, int level=0)
; + PlayNippleSquirt(Actor actorRef, float duration, int level=0)
; + HasNippleSquirt(Actor actorRef)
;
; All other functions and properties are considered private and should not be 
; used by other mods. 

ScriptName OninusLactis extends Quest

; --- Properties

Actor Property PlayerRef Auto
Armor NippleSquirtArmor 

EffectShader LactisNippleLeakCBBE
; MagicEffect Property HentaiMilkSquirtSpellEffect Auto

Int Property StartLactatingKey Auto
Float[] Property NippleOffsetL Auto
Float Property EmitterScale Auto
Float Property GlobalEmitterScale Auto
Bool Property OStimIntegrationEnabled Auto
Float Property OStimSpankSquirtDuration Auto
Float Property OStimOrgasmSquirtDuration Auto
Bool Property OStimNonNakedSquirtEnabled Auto
Bool Property NippleLeakEnabled Auto
Bool Property DebugAxisEnabled Auto
Bool Property UseRandomYRotation Auto
Bool Property UseRandomEmitterScale Auto
Bool Property UseRandomEmitterDeactivation Auto

; --- Fields (private)

Float fVersion

Actor[] armorActors
ObjectReference[] armorRefsLeft

; Actor data storage. Stores offset and scale for NPCs.
LactisActorStorage Property actorStorage Auto

; --- OStim integration

OsexIntegrationMain ostim
int ostimSpankMax = 10
int origOstimSpankMax = 0
float ostimSquirtScaleMin = 0.75
float ostimSquirtScaleMax = 2.0

Event OnInit()
	Debug.Notification("OninusLactis installed.")
	Maintenance()
EndEvent

float Function GetVersion()
	return fVersion
EndFunction

Function Maintenance()
	If fVersion < 2.0; <--- Edit this value when updating
		fVersion = 2.0; and this
		Debug.Notification("Now running OninusLactis version: " + fVersion)
		; Update Code		
	EndIf	

	NippleSquirtArmor = game.GetFormFromFile(0x003312, "OninusLactis.esp") as Armor

	LactisNippleLeakCBBE  = game.GetFormFromFile(0x001D85, "OninusLactis.esp") as EffectShader

	; Console("armorActors=" + armorActors)
	; Console("armorRefsLeft=" + armorRefsLeft)	

	If (armorActors.Length==0)
		armorActors = new Actor[10]
		armorRefsLeft = new ObjectReference[10]
		; Console("armorActors initialized." + armorActors)			
	EndIf	

	actorStorage = (self as Form) as LactisActorStorage
	; Console("actorStorage: " + actorStorage)

	; Other maintenance code that only needs to run once per save load		
	Console("loaded version is " + fVersion)
	RegisterForKey(StartLactatingKey)

	ostim = game.GetFormFromFile(0x000801, "Ostim.esp") as OsexIntegrationMain
	if (ostim)
		; Console("OStim " + ostim.GetAPIVersion() + " installed.")
	endif
	If (ostim && OStimIntegrationEnabled)
		Console("OStim " + ostim.GetAPIVersion() + " installed. Integration enabled.")
		RegisterForOStimEvents()
	elseif ostim==None
		Console("OStim not installed.")	
	endif	

	ApplyArmoredActorProperties()

	Utility.Wait(0.1)
EndFunction

; Used by the MCM script. When querying OStim during gameplay the ostim variable
; should be checked directly for performance reasons.
Bool Function HasOStim() 	
	return ostim!=None
EndFunction

;
; ██████╗ ██╗   ██╗██████╗ ██╗     ██╗ ██████╗     █████╗ ██████╗ ██╗
; ██╔══██╗██║   ██║██╔══██╗██║     ██║██╔════╝    ██╔══██╗██╔══██╗██║
; ██████╔╝██║   ██║██████╔╝██║     ██║██║         ███████║██████╔╝██║
; ██╔═══╝ ██║   ██║██╔══██╗██║     ██║██║         ██╔══██║██╔═══╝ ██║
; ██║     ╚██████╔╝██████╔╝███████╗██║╚██████╗    ██║  ██║██║     ██║
; ╚═╝      ╚═════╝ ╚═════╝ ╚══════╝╚═╝ ╚═════╝    ╚═╝  ╚═╝╚═╝     ╚═╝
                                                                                                                                                                                      
; Start the nipple squirt effect on the given 'actorRef' using the given squirt 
; 'level' in the range [0..2].
; If there are already 10 actors with an active effect the call will be ignored.
; If the given 'actorRef' already has the nipple squirt effect running the call 
; will be ignored.
; If the "Nipple Leak" feature is enabled in the MCM this function will also 
; start the nipple leak overlay.
Function StartNippleSquirt(Actor actorRef, int level=0)
	if GetArmoredActorsCount() >= 10
		return
	endif

	if HasArmorRefs(actorRef)
		return
	endif

	LactisNippleSquirtArmor armorRef = StartNippleSquirtLeft(actorRef, level)
	StoreArmorRefs(actorRef, armorRef)

	if NippleLeakEnabled
		StartNippleLeak(actorRef, 10)
	endif

	Utility.Wait(0.1)
EndFunction

; Stops the nipple squirt effect on the given 'actorRef'.
; If the actor does not have an nipple squirt effect running the call will be ignored.
; If the "Nipple Leak" feature is enabled in the MCM this function will also stop
; the nipple leak overlay.
Function StopNippleSquirt(Actor actorRef)
	if !HasArmorRefs(actorRef)
		return
	endif

	if NippleLeakEnabled	
		StopNippleLeak(actorRef)
	endif	

	LactisNippleSquirtArmor actorArmor = GetArmorRefs(actorRef)			
	StopNippleSquirtInternal(actorRef, actorArmor)
	RemoveArmorRefs(actorRef)
	
	Utility.Wait(0.1)
EndFunction

; Toggles the nipple squirt effect for the given 'actorRef' on or off using 
; the given squirt 'level' in the range [0..2].
Function ToggleNippleSquirt(Actor actorRef, int level=0)
	bool hasNippleSquirt = HasArmorRefs(actorRef)	
	
	; How long does our operation take?
	; float ftimeStart = Utility.GetCurrentRealTime()
	if !hasNippleSquirt
		StartNippleSquirt(actorRef, level)
	else
		StopNippleSquirt(actorRef)
	EndIf

	; float ftimeEnd = Utility.GetCurrentRealTime()
	; Console("Starting/stopping took " + (ftimeEnd - ftimeStart) + " seconds to run")

	actorRef.QueueNiNodeUpdate()
	Utility.Wait(0.1)
	actorRef.QueueNiNodeUpdate()
EndFunction

; Plays the nipple squirt effect on the given 'artorRef' for the given 'duration'
; specified in seconds using the given squirt 'level' in the range [0..2].
; The effect will automatically stop and removed from the actor after the given 
; duration.
Function PlayNippleSquirt(Actor actorRef, float duration, int level=0)
	StartNippleSquirt(actorRef, level)
	Utility.Wait(duration)
	StopNippleSquirt(actorRef)
EndFunction

; Checks whether the given 'actorRef' has the nipple squirt effect running.
bool Function HasNippleSquirt(Actor actorRef)
	return actorRef.IsEquipped(NippleSquirtArmor)
EndFunction

; 
; ██████╗ ██████╗ ██╗██╗   ██╗ █████╗ ████████╗███████╗     █████╗ ██████╗ ██╗
; ██╔══██╗██╔══██╗██║██║   ██║██╔══██╗╚══██╔══╝██╔════╝    ██╔══██╗██╔══██╗██║
; ██████╔╝██████╔╝██║██║   ██║███████║   ██║   █████╗      ███████║██████╔╝██║
; ██╔═══╝ ██╔══██╗██║╚██╗ ██╔╝██╔══██║   ██║   ██╔══╝      ██╔══██║██╔═══╝ ██║
; ██║     ██║  ██║██║ ╚████╔╝ ██║  ██║   ██║   ███████╗    ██║  ██║██║     ██║
; ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝  ╚═╝  ╚═╝   ╚═╝   ╚══════╝    ╚═╝  ╚═╝╚═╝     ╚═╝
; 

LactisNippleSquirtArmor Function StartNippleSquirtLeft(Actor actorRef, int level=0)
	; Console("StartNippleSquirtLeft")	
	LactisNippleSquirtArmor armorRef = actorRef.PlaceAtMe(NippleSquirtArmor, 1, true) as LactisNippleSquirtArmor	
	armorRef.ActorRef = actorRef
	armorRef.SetLevel(level, false)
	if actorStorage.HasNpcStorage(actorRef)
		; update npc armors
		UpdateArmorProperties(armorRef, actorStorage.GetNpcOffset(actorRef), actorStorage.GetNpcScale(actorRef))
	else
		; update the player's armor
		UpdateArmorProperties(armorRef, NippleOffsetL, EmitterScale)
	endif

	actorRef.AddItem(armorRef, 1, true)
	actorRef.QueueNiNodeUpdate()
	return armorRef
EndFunction


Function StopNippleSquirtInternal(Actor actorRef, LactisNippleSquirtArmor armorRef)
	; Console("StopNippleSquirtInternal on actor " + actorRef + ", armorRef=" + armorRef + ", armorRightRef=" + armorRightRef)
	if armorRef!=None
		actorRef.RemoveItem(armorRef, 1, true)
	endif
	actorRef.QueueNiNodeUpdate()

	Utility.Wait(0.1)
EndFunction

Function ForceStopNippleSquirt(Actor actorRef)
	actorRef.RemoveItem(NippleSquirtArmor)	
	if HasArmorRefs(actorRef)
		RemoveArmorRefs(actorRef)
	endIf
	actorRef.QueueNiNodeUpdate()
	Utility.Wait(0.1)
EndFunction

Function StopAllNippleSquirts() 
	if ostim && ostim.AnimationRunning()
		return
	endif

	int i = 0	
	int len = armorActors.Length
	Actor actorRef = None
	Console("Stopping all nipple squirts")
	while i < len
		actorRef = armorActors[i]
		if actorRef
			LactisNippleSquirtArmor actorArmor = GetArmorRefs(actorRef)
			StopNippleSquirtInternal(actorRef, actorArmor)
			RemoveArmorRefs(actorRef)
		endif
		i += 1
	endwhile
EndFunction


; Updates the properties of the given armor object reference.
; Note that all parameters apply to the left and right armor and 
; cannot be controlled individually.
Function UpdateArmorProperties(LactisNippleSquirtArmor armorRef, Float[] nippleOffset, float actorEmitterScale)
	armorRef.NippleOffset = nippleOffset
	; invert x-axis for the right side
	float[] nippleOffsetR = new float[3]
	nippleOffsetR[0] = -nippleOffset[0]
	nippleOffsetR[1] = nippleOffset[1]
	nippleOffsetR[2] = nippleOffset[2]
	armorRef.NippleOffsetR = nippleOffsetR
	armorRef.DebugAxisEnabled = DebugAxisEnabled
	armorRef.GlobalEmitterScale = GlobalEmitterScale
	if ostim && ostim.AnimationRunning()
		armorRef.EmitterScale = MapValue(ostim.GetSpankCount(), 0.0, ostimSpankMax, ostimSquirtScaleMin, ostimSquirtScaleMax, true)
	else
		armorRef.EmitterScale = actorEmitterScale
	endif
	armorRef.UseRandomEmitterScale = UseRandomEmitterScale
	armorRef.UseRandomYRotation = UseRandomYRotation
	armorRef.UseRandomEmitterDeactivation = UseRandomEmitterDeactivation
	armorRef.UpdateNodeProperties()
EndFunction

Function ApplyArmoredActorProperties()
	int i = 0
	Actor actorRef = None
	while i < armorActors.Length
		actorRef = armorActors[i]
		if actorRef != None
			LactisNippleSquirtArmor actorArmor = GetArmorRefs(actorRef)
			actorArmor.UpdateNodeProperties()
		endif
		i += 1
	endwhile
EndFunction

; ----------------------------- Nipple leak 

; Plays the nipple leaking effect on both breasts of the given 'ActorRef'.
; The 'duration' is in seconds, use -1 to play the effect forever.
Function StartNippleLeak(Actor actorRef, int duration)	
	; Console("StartNippleLeak on actor " + actorRef + " for " + duration + " seconds.")
	LactisNippleLeakCBBE.play(actorRef, duration)		
EndFunction

; Stops the milk leaking effect on both breasts
Function StopNippleLeak(Actor actorRef)	
	; Console("StopNippleLeak on actor " + actorRef)
	LactisNippleLeakCBBE.Stop(actorRef)		
EndFunction


; ------------------------- Armor reference storage utilities
;
; Actors with active nipple squirt effect (i.e. the nipple squirt armor equipped)
; are stored in the 'armorActors' array which can store up to 10 entries.
;

; Returns whether the given 'actorRef' has the nipple squirt armor equipped, by 
; checking the internal 'armorActors' for the 'actorRef'.
bool Function HasArmorRefs(Actor actorRef)
	int actorIndex = armorActors.Find(actorRef)
	if actorIndex >= 0
		return true
	Else
		return false
	endif
EndFunction

; Stores the left and right armor references for the given actorRef in the 
; internal 'armorActors' array.
int Function StoreArmorRefs(Actor actorRef, LactisNippleSquirtArmor armorRefLeft)
	int firstFreeIndex = armorActors.Find(None)
	if firstFreeIndex>=0
		; Console("Storing armor refs for actor=" + actorRef + ", armorRef=" + armorRefLeft)
		armorActors[firstFreeIndex] = actorRef
		armorRefsLeft[firstFreeIndex] = armorRefLeft
	else
		Console("Nipple squirt ArmorRef storage full!")
	endif
	return firstFreeIndex
EndFunction

; Gets the left and right armor references for the given actorRef or None if the actor has no 
; nipple squirt armor equipped.
LactisNippleSquirtArmor Function GetArmorRefs(Actor actorRef)
	int actorIndex = armorActors.Find(actorRef)
	if actorIndex >= 0
		return armorRefsLeft[actorIndex] as LactisNippleSquirtArmor
	endif
	; we cannot return None explicitly here as this will result in a runtime cast error
	; luckily returning nothing seems to actually return None :)
	return None
EndFunction

; Removes the armor references for the given actorRef from the internal storage.
Function RemoveArmorRefs(Actor actorRef)
	int actorIndex = armorActors.Find(actorRef)
	If actorIndex >= 0
		; Console("Removing armor refs for actor=" + actorRef)
		armorActors[actorIndex] = None
		armorRefsLeft[actorIndex] = None
	EndIf
EndFunction

; Gets the number of actors with active nipple squirt armor stored in the internal
; 'armorActors' arrary.
Int Function GetArmoredActorsCount()
	int i = 0	
	int len = armorActors.Length
	int count = 0
	Actor actorRef = None
	while i < len
		actorRef = armorActors[i]
		if actorRef
			count += 1
		endif
		i += 1
	endwhile	
	return count
EndFunction

; ---------------------------- Utility functions

Event OnKeyDown(Int keyCode)
	; https://www.creationkit.com/index.php?title=Input_Script#DXScanCodes	
	If (Utility.IsInMenuMode() || UI.IsMenuOpen("console"))
		Return
	EndIf

	; Console("**** A registered key has been pressed: "+ keyCode)

	ObjectReference crosshairObjRef = Game.GetCurrentCrosshairRef()
	Actor crosshairActor = crosshairObjRef as Actor

	Actor affectedActor = PlayerRef
	if crosshairActor != None
		affectedActor = crosshairActor
	endif

	; keycode 34 = G
	; keycode 35 = H
	; keycode 42 = left shift
	; keycode 54 = right shift
	if (!ostim || (ostim && !ostim.AnimationRunning()))
		if keyCode == StartLactatingKey && Input.IsKeyPressed(54)
			ForceStopNippleSquirt(affectedActor)
		elseif keyCode == StartLactatingKey  && !Input.IsKeyPressed(42)
			ToggleNippleSquirt(affectedActor)
		elseif keyCode == StartLactatingKey && Input.IsKeyPressed(42)					
			LactisNippleSquirtArmor armorRef = GetArmorRefs(affectedActor)
			int currentLevel = armorRef.GetLevel()
			currentLevel = currentLevel + 1
			if currentLevel > 2
				currentLevel = 0
			endif
			armorRef.SetLevel(currentLevel)
		; elseif keyCode == 34
		; 	Console("34")
		; 	LactisNippleSquirtArmor[] armorRefs = GetArmorRefs(affectedActor)
		; 	LactisNippleSquirtArmor armorRef = armorRefs[0]
		; 	armorRef.StartParticleSystem()
		; elseif keyCode == 35
		; 	Console("35")
		; 	LactisNippleSquirtArmor[] armorRefs = GetArmorRefs(affectedActor)
		; 	LactisNippleSquirtArmor armorRef = armorRefs[0]
		; 	armorRef.StopParticleSystem()
		EndIf
	endif

EndEvent

Function Uninstall()
	Console("Uninstalling Lactis")
	StopAllNippleSquirts()
	actorStorage.Clear()
	UnregisterForAllModEvents()
	UnregisterForAllKeys()	
	Reset()
	Stop()
EndFunction

Function RemapStartLactatingKey(Int zKey)
	Console("Remapping ToggleNippleSquirt to "+ zKey)	
	UnregisterForKey(StartLactatingKey)
	RegisterForKey(zKey)
	StartLactatingKey = zKey	
EndFunction

Function Console(String In) Global
	MiscUtil.PrintConsole("OninusLactis: " + In)
	Debug.Trace("OninusLactis: " + In)
EndFunction


; Maps the specified value val from the interval defined by srcMin and 
; srcMax to the interval defined by dstMin and dstMax.
; returns: The value mapped to the destination interval.
; param 'srcMin': The minimum value of the source interval.
; param 'srcMax': The maximum value of the source interval.
; param 'dstMin': The minimum value of the destination interval.
; param 'dstMax': The maximum value of the destination interval.
; param 'clamp': clamp values outside [dstMin..dstMax] or not.
float Function MapValue(float val, float srcMin, float srcMax, float dstMin, float dstMax, bool clamp) global
	if clamp
		if (val>=srcMax) 
			return dstMax
		endif
		if (val<=srcMin) 
			return dstMin
		endif
	endif
	return dstMin + (val-srcMin) / (srcMax-srcMin) * (dstMax-dstMin)
EndFunction	

; ----------------------------- OStim integration

Function RegisterForOStimEvents()
	RegisterForModEvent("ostim_orgasm", "OnOstimOrgasm")
	RegisterForModEvent("ostim_spank", "OnOstimSpank")			
	RegisterForModEvent("ostim_prestart", "OnOStimPrestart")
	RegisterForModEvent("ostim_end", "OnOStimEnd")		
	; RegisterForModEvent("ostim_animationchanged", "OnOstimAnimationChanged")		
EndFunction

Function UnregisterForOStimEvents()
	UnregisterForModEvent("ostim_orgasm")
	UnregisterForModEvent("ostim_spank")
	UnregisterForModEvent("ostim_prestart")
	UnregisterForModEvent("ostim_end")
EndFunction

Event OnOStimOrgasm(string eventName, string strArg, float numArg, Form sender)	
	; Console("OnOStimOrgasm: eventName=" + eventName + ", strArg=" + strArg + ", numArg="+ numArg)
	Actor orgasmActor = ostim.GetMostRecentOrgasmedActor()
	PlayOrgasmSquirt(orgasmActor)
EndEvent

Function PlayOrgasmSquirt(Actor actorRef)		
	; check the lock to prevent playing another orgasm squirt while one is running
	; actually this is the same lock used in PlaySpankSquirt() so there should be 
	; exactly one squirt at any time, no matter if caused by spank or orgasm
	if actorRef.IsEquipped(NippleSquirtArmor)
		return
	endif

	if !ostim.AppearsFemale(actorRef) || (!ostim.IsNaked(actorRef) && !OStimNonNakedSquirtEnabled)
		Console("PlayOrgasmSquirt: Orgasm squirt cancelled. "+ "actorRef.IsEquipped(NippleSquirtArmor)=" + actorRef.IsEquipped(NippleSquirtArmor) + ", ostim.IsNaked=" + ostim.IsNaked(actorRef) + ", ostim.IsFemale=" + ostim.IsFemale(actorRef) + ", AppearsFemale=" + ostim.AppearsFemale(actorRef))
		return
	endif

	LactisNippleSquirtArmor armorRef = StartNippleSquirtLeft(actorRef, 2)	

	if NippleLeakEnabled
		StartNippleLeak(actorRef, 10)
	endif

	actorRef.QueueNiNodeUpdate()
	Utility.Wait(OStimOrgasmSquirtDuration)

	; Console("Stopping left and right nipple squirt")
	StopNippleSquirtInternal(actorRef, armorRef)

	armorRef = None
	; if ostim.IsInFreeCam() && subActor == playerref
	; 	subActor.QueueNiNodeUpdate()
	; endif
	Utility.Wait(0.2)	
EndFunction


Event OnOstimSpank(string eventName, string strArg, float numArg, Form sender)
	; Console("OnOstimSpank: eventName=" + eventName + ", strArg=" + strArg + ", numArg="+ numArg)
	; Assuming the subactor is getting spank... dont know how to query who is spanked	
	; TODO: could be cached at OnStimPrestart
	Actor subActor = ostim.GetSubActor()
	PlaySpankSquirt(subActor)
EndEvent

Function PlaySpankSquirt(Actor actorRef)
	; check the lock to prevent playing another spank squirt while one is running
	; actually this is the same lock used in PlayOrgasmSquirt() so there should be 
	; exactly one squirt at any time, no matter if caused by spank or orgasm
	if actorRef.IsEquipped(NippleSquirtArmor)
		return
	endif

	; on a female player with the SOS Futanari schlong attached IsFemale==false and the spank squirt will not be played
	; thus we use AppearsFemale().. 
	; TODO: i guess this could be cached at OnOstimPrestart
	if !ostim.AppearsFemale(actorRef) || (!ostim.IsNaked(actorRef) && !OStimNonNakedSquirtEnabled)
		Console("PlaySpankSquirt: Spank squirt cancelled. actor=" + actorRef + "actorRef.IsEquipped(NippleSquirtArmor)=" + actorRef.IsEquipped(NippleSquirtArmor) + ", ostim.IsNaked(subActor)=" + ostim.IsNaked(actorRef) + ", ostim.IsFemale(subActor)=" + ostim.IsFemale(actorRef) + ", AppearsFemale=" + ostim.AppearsFemale(actorRef))
		return
	endif

	; Console("PlaySpankSquirt: ostim.GetMaxSpanksAllowed=" + ostim.GetMaxSpanksAllowed() + ", ostim.GetSpankCount" + ostim.GetSpankCount())

	LactisNippleSquirtArmor armorRef = StartNippleSquirtLeft(actorRef, 0)		

	; the QueueNiNodeUpdate() and Wait() call are required, otherwise the first
	; equipped armor will not be aligned correctly
	; actorRef.QueueNiNodeUpdate()
	; Utility.Wait(0.05)
	; LactisNippleSquirtArmor armorRightRef = StartNippleSquirtRight(actorRef, 0)
	
	if NippleLeakEnabled
		StartNippleLeak(actorRef, 10)
	endif

	; if ostim.IsInFreeCam()
		actorRef.QueueNiNodeUpdate()
	; endif

	Utility.Wait(OStimSpankSquirtDuration)
	
	StopNippleSquirtInternal(actorRef, armorRef)
	armorRef = None

	; if ostim.IsInFreeCam() && subActor == playerref
	; 	subActor.QueueNiNodeUpdate()
	; endif
	Utility.Wait(0.2)
EndFunction

; Experimental. Not used yet.
Event OnOstimAnimationChanged(string eventName, string strArg, float numArg, Form sender)
	; Console("OnOstimAnimationChanged: eventName=" + eventName + ", strArg=" + strArg + ", numArg="+ numArg)

	Actor actorRef = ostim.GetSubActor()

	if actorRef.IsEquipped(NippleSquirtArmor)
		return
	endif

	if !ostim.AppearsFemale(actorRef) || (!ostim.IsNaked(actorRef) && !OStimNonNakedSquirtEnabled)
		Console("OnOstimAnimationChanged: Animation nipple squirt cancelled. actor=" + actorRef + "actorRef.IsEquipped(NippleSquirtArmor)=" + actorRef.IsEquipped(NippleSquirtArmor) + ", ostim.IsNaked(actorRef)=" + ostim.IsNaked(actorRef) + ", ostim.IsFemale(actorRef)=" + ostim.IsFemale(actorRef) + ", AppearsFemale=" + ostim.AppearsFemale(actorRef))
		return
	endif

	String currentAnimClass = ostim.GetCurrentAnimationClass()
	; Console("OnOstimSpank: currentAnimClass=" + currentAnimClass)
	if (currentAnimClass=="Pf2" || currentAnimClass=="VJ" || currentAnimClass=="Cr" || currentAnimClass=="Po") 		
		LactisNippleSquirtArmor armorRef = StartNippleSquirtLeft(actorRef, 1)
		; LactisNippleSquirtArmor armorRightRef = StartNippleSquirtRight(actorRef, 1)
		if NippleLeakEnabled
			StartNippleLeak(actorRef, 4)
		endif
		actorRef.QueueNiNodeUpdate()
		
		Utility.Wait(OStimSpankSquirtDuration)

		StopNippleSquirtInternal(actorRef, armorRef)		
		armorRef = None
		; armorRightRef = None	
	endif

	if ostim.IsInFreeCam()
		actorRef.QueueNiNodeUpdate()
	endif

EndEvent

Event OnOStimPrestart(string eventName, string strArg, float numArg, Form sender)
	; Console("OnOStimPrestart")
	origOstimSpankMax = ostim.GetMaxSpanksAllowed()
	ostim.SetSpankMax(ostimSpankMax)
endevent

Event OnOStimEnd(string eventName, string strArg, float numArg, Form sender)
	; Console("OnOStimEnd")
	ostim.SetSpankMax(origOstimSpankMax)
endevent

; ; vanilla OSex class library
; ClassSex = "Sx"
; ClassCunn = "VJ" ;Cunnilingus
; ClassApartHandjob = "ApHJ"
; ClassHandjob = "HJ"
; ClassClitRub = "Cr"
; ClassOneFingerPen = "Pf1"
; ClassTwoFingerPen = "Pf2"
; ClassBlowjob = "BJ"
; ClassPenisjob = "ApPJ" ;Blowjob with jerking at the same time
; ClassMasturbate = "Po" ; masturbation
; ClassHolding = "Ho" ;
; ClassApart = "Ap" ;standing apart
; ClassApartUndressing = "ApU"
; ClassEmbracing = "Em"
; ClassRoughHolding = "Ro"
; ClassSelfSuck = "SJ"
; ClassHeadHeldPenisjob = "HhPJ"
; ClassHeadHeldBlowjob = "HhBJ"
; ClassHeadHeldMasturbate = "HhPo"
; ClassDualHandjob = "DHJ"
; Class69Blowjob = "VBJ"
; Class69Handjob = "VHJ"

; ; OStim extended library
; ClassAnal = "An"
; ClassBoobjob = "BoJ"
; ClassBreastFeeding = "BoF"
; ClassFootjob = "FJ"
