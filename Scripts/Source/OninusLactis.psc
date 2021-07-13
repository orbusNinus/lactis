;
; 			██╗      █████╗  ██████╗████████╗██╗███████╗
; 			██║     ██╔══██╗██╔════╝╚══██╔══╝██║██╔════╝
; 			██║     ███████║██║        ██║   ██║███████╗
; 			██║     ██╔══██║██║        ██║   ██║╚════██║
; 			███████╗██║  ██║╚██████╗   ██║   ██║███████║
; 			╚══════╝╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═╝╚══════╝
;								

ScriptName OninusLactis extends Quest

; --- Properties

Actor Property PlayerRef Auto
Armor Property LactisNippleSquirtArmorL Auto
Armor Property LactisNippleSquirtArmorR Auto

EffectShader property LactisNippleLeakCBBE auto
; MagicEffect Property HentaiMilkSquirtSpellEffect Auto

Int Property StartLactatingKey Auto
Float[] Property NippleOffsetL Auto
Float[] Property NippleOffsetR Auto
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
LactisNippleSquirtArmor[] armorRefsLeft
LactisNippleSquirtArmor[] armorRefsRight

; --- Internal state variables

Int switch = 0

; --- OStim integration

OsexIntegrationMain ostim
int ostimSpankMax = 10
int origOstimSpankMax = 0
float ostimSquirtScaleMin = 0.75
float ostimSquirtScaleMax = 2.0

Event OnInit()
	Debug.Notification("OninusLactis installed.")	
	; RegisterForSingleUpdate(10.0) ; Give us a single update in one second
	Maintenance()
EndEvent


Function Maintenance()
	If fVersion < 0.25; <--- Edit this value when updating
		fVersion = 0.25 ; and this
		Debug.Notification("Now running OninusLactis version: " + fVersion)
		; Update Code		
	EndIf

	; Other maintenance code that only needs to run once per save load		
	Console("loaded version is " + fVersion)
	RegisterForKey(StartLactatingKey)
	
	ostim = game.GetFormFromFile(0x000801, "Ostim.esp") as OsexIntegrationMain
	if (ostim)
		Console("OStim " + ostim.GetAPIVersion() + " installed.")
	endif
	If (ostim && OStimIntegrationEnabled)
		Console("OStim integration enabled.")
		RegisterForModEvent("ostim_orgasm", "OnOstimOrgasm")
		RegisterForModEvent("ostim_spank", "OnOstimSpank")			
		RegisterForModEvent("ostim_prestart", "OnOStimPrestart")
		RegisterForModEvent("ostim_end", "OnOStimEnd")		
		; RegisterForModEvent("ostim_animationchanged", "OnOstimAnimationChanged")			
	elseif ostim==None
		Console("OStim not installed.")	
	endif	

	armorActors = new Actor[50]
	armorRefsLeft = new LactisNippleSquirtArmor[50]
	armorRefsRight = new LactisNippleSquirtArmor[50]

	Utility.Wait(0.1)
EndFunction


Event OnKeyDown(Int keyCode)
	; https://www.creationkit.com/index.php?title=Input_Script#DXScanCodes	
	If (Utility.IsInMenuMode() || UI.IsMenuOpen("console"))
		Return
	EndIf

	Console("**** A registered key has been pressed: "+ keyCode)

	ObjectReference crosshairObjRef = Game.GetCurrentCrosshairRef()
	Actor crosshairActor = crosshairObjRef as Actor

	Actor affectedActor = PlayerRef
	if crosshairActor != None
		affectedActor = crosshairActor
	endif

	if (!ostim || (ostim && !ostim.AnimationRunning()))
		If keyCode == StartLactatingKey  && !Input.IsKeyPressed(42)
			ToggleNippleSquirt(affectedActor)
		elseif keyCode == StartLactatingKey && Input.IsKeyPressed(42)					
			LactisNippleSquirtArmor[] armorRefs = GetArmorRefs(affectedActor)
			LactisNippleSquirtArmor armorLeft = armorRefs[0]
			LactisNippleSquirtArmor armorRight = armorRefs[1]
			if armorRefs != None
				if switch==0
					armorLeft.SetLevel(0)
					armorRight.SetLevel(0)
					switch=1
				elseif switch==1
					armorLeft.SetLevel(1)
					armorRight.SetLevel(1)		
					switch=2
				elseif switch==2
					armorLeft.SetLevel(2)
					armorRight.SetLevel(2)		
					switch=0
				endif			
			endif
		EndIf
	endif

EndEvent

; Used by the MCM script. When querying OStim during gameplay the ostim varibale
; should be checked directly for performance reasons.
Bool Function HasOStim() 	
	return ostim!=None
EndFunction


; ----------------------------- Nipple leak

; Plays the nipple leaking effect on both breasts of the given 'ActorRef'.
; The 'duration' is in seconds, use -1 to play the effect forever.
Function StartNippleLeak(Actor actorRef, int duration)	
	Console("StartNippleLeak on actor " + actorRef + " for " + duration + " seconds.")
	LactisNippleLeakCBBE.play(actorRef, duration)		
EndFunction

; Stops the milk leaking effect on both breasts
Function StopNippleLeak(Actor actorRef)	
	Console("StopNippleLeak on actor " + actorRef)
	LactisNippleLeakCBBE.Stop(actorRef)		
EndFunction

; ---------------------------- Nipple squirt

Function ToggleNippleSquirt(Actor actorRef)
	
	LactisNippleSquirtArmor[] actorArmors = GetArmorRefs(actorRef)
	
	bool isStartingSquirt = false

	if actorArmors
		isStartingSquirt = false
	else
		isStartingSquirt = true
	endif

	Console("ToggleNippleSquirt, actor=" + actorRef + ", actorArmors=" + actorArmors + ", isStartingSquirt=" + isStartingSquirt)
	
	; How long does our operation take?
	; float ftimeStart = Utility.GetCurrentRealTime()
	if isStartingSquirt
		LactisNippleSquirtArmor armorLeft = StartNippleSquirtLeft(actorRef)				
		LactisNippleSquirtArmor armorRight = StartNippleSquirtRight(actorRef)	
		; Console("Storing armors. actor=" + actorRef + ", armorLeft=" + armorLeft + ", armorRight=" + armorRight)
		StoreArmorRefs(actorRef, armorLeft, armorRight)		
		if NippleLeakEnabled		
			StartNippleLeak(actorRef, 10)
		endif
	else
		StopNippleSquirt(actorRef, actorArmors[0], actorArmors[1])
		RemoveArmorRefs(actorRef)
	EndIf
	
	; float ftimeEnd = Utility.GetCurrentRealTime()
	; Console("Starting/stopping took " + (ftimeEnd - ftimeStart) + " seconds to run")

	actorRef.QueueNiNodeUpdate()
	Utility.Wait(0.1)
	actorRef.QueueNiNodeUpdate()
EndFunction


LactisNippleSquirtArmor Function StartNippleSquirtLeft(Actor actorRef, int level=0)
	; Console("StartNippleSquirtLeft")	
	LactisNippleSquirtArmor armorLeftRef = actorRef.PlaceAtMe(LactisNippleSquirtArmorL, 1) as LactisNippleSquirtArmor	
	armorLeftRef.ActorRef = actorRef
	armorLeftRef.SetLevel(level, false)
	actorRef.AddItem(armorLeftRef, 1, true)
	UpdateArmorProperties(armorLeftRef, NippleOffsetL)
	actorRef.QueueNiNodeUpdate()
	return armorLeftRef
EndFunction

LactisNippleSquirtArmor Function StartNippleSquirtRight(Actor actorRef, int level=0)
	; Console("StartNippleSquirtRight")	
	LactisNippleSquirtArmor armorRightRef = actorRef.PlaceAtMe(LactisNippleSquirtArmorR, 1) as LactisNippleSquirtArmor
	armorRightRef.ActorRef = actorRef
	armorRightRef.SetLevel(level, false)
	actorRef.AddItem(armorRightRef, 1, true)
	UpdateArmorProperties(armorRightRef, NippleOffsetR)
	; actorRef.EquipItem(armorRightRef.GetBaseObject(), true, true)
	actorRef.QueueNiNodeUpdate()
	return armorRightRef
EndFunction

; Function StopNippleSquirt(Actor actorRef, LactisNippleSquirtArmor armorLeftRef, LactisNippleSquirtArmor armorRightRef)
Function StopNippleSquirt(Actor actorRef, Form armorLeftRef, Form armorRightRef)
	Console("StopNippleSquirt on actor " + actorRef)

	if NippleLeakEnabled	
		StopNippleLeak(actorRef)
	endif

	actorRef.RemoveItem(armorLeftRef, 1, true)
	actorRef.RemoveItem(armorRightRef, 1, true)
	actorRef.QueueNiNodeUpdate()
	armorLeftRef = None
	armorRightRef = None

	Utility.Wait(0.1)
EndFunction


; Updates the properties of the given armor object reference.
; Note that all parameters but the nippleOffset applies to the left and right armor and 
; cannot be controlled individually.
Function UpdateArmorProperties(LactisNippleSquirtArmor armorRef, Float[] nippleOffset)
	armorRef.NippleOffset = nippleOffset
	armorRef.DebugAxisEnabled = DebugAxisEnabled
	armorRef.GlobalEmitterScale = GlobalEmitterScale
	if (ostim)
		armorRef.EmitterScale = MapInterval(ostim.GetSpankCount(), 0.0, ostimSpankMax, ostimSquirtScaleMin, ostimSquirtScaleMax, true)
	else
		armorRef.EmitterScale = 1.0
	endif
	armorRef.UseRandomEmitterScale = UseRandomEmitterScale
	armorRef.UseRandomYRotation = UseRandomYRotation
	armorRef.UseRandomEmitterDeactivation = UseRandomEmitterDeactivation
	armorRef.UpdateNodeProperties()
EndFunction

; ----------------------------- Armor reference storage utilities

; Stores the left and right armor references for the given actorRef
int Function StoreArmorRefs(Actor actorRef, LactisNippleSquirtArmor armorRefLeft, LactisNippleSquirtArmor armorRefRight)
	int firstFreeIndex = armorActors.Find(None)
	if firstFreeIndex>=0
		; Console("Storing armor refs for actor=" + actorRef + ", armorLeft=" + armorRefLeft + ", armorRight=" + armorRefRight)
		armorActors[firstFreeIndex] = actorRef
		armorRefsLeft[firstFreeIndex] = armorRefLeft
		armorRefsRight[firstFreeIndex] = armorRefRight
	else
		Console("ArmorRef storage full!")
	endif
	return firstFreeIndex
EndFunction

; Gets the left and right armor references for the given actorRef or None if the actor has no 
; nipple squirt armor equipped.
LactisNippleSquirtArmor[] Function GetArmorRefs(Actor actorRef)
	int actorIndex = armorActors.Find(actorRef)
	if actorIndex >= 0
		LactisNippleSquirtArmor[] armorRefs = new LactisNippleSquirtArmor[2]
		armorRefs[0] = armorRefsLeft[actorIndex]
		armorRefs[1] = armorRefsRight[actorIndex]
		return armorRefs
	endif
	; we cannot return None explicitly here as this will result in a runtime cast error
	; luckily returning nothing seems to actually return None :)
EndFunction

; Removes the armore references for the given actorRef from the internal storage.
Function RemoveArmorRefs(Actor actorRef)
	int actorIndex = armorActors.Find(actorRef)
	If actorIndex >= 0
		; Console("Removing armor refs for actor=" + actorRef)
		armorActors[actorIndex] = None
		armorRefsLeft[actorIndex] = None
		armorRefsRight[actorIndex] = None
	EndIf
EndFunction


; ---------------------------- Utility functions

Function RemapStartLactatingKey(Int zKey)
	Console("Remapping StartLactatingKey to "+ zKey)	
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
; <returns>The value val mapped to the destination interval.</returns>
; <param name='srcMin'>The minimum value of the source interval.</param>
; <param name='srcMax'>The maximum value of the source interval.</param>
; <param name='dstMin'>The minimum value of the destination interval.</param>
; <param name='dstMax'>The maximum value of the destination interval.</param>
; <param name='clamp'>Clamp values outside [dstMin..dstMax] or not.</param>
float Function MapInterval(float val, float srcMin, float srcMax, float dstMin, float dstMax, bool clamp) global
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

Event OnOStimOrgasm(string eventName, string strArg, float numArg, Form sender)	
	; Console("OnOStimOrgasm: eventName=" + eventName + ", strArg=" + strArg + ", numArg="+ numArg)
	Actor orgasmActor = ostim.GetMostRecentOrgasmedActor()
	PlayOrgasmSquirt(orgasmActor)
EndEvent

Function PlayOrgasmSquirt(Actor actorRef)
	; Actor orgasmActor = ostim.GetMostRecentOrgasmedActor()
	Console("PlayOrgasmSquirt: Most recent orgasmed actor is " + actorRef)

	; check the lock to prevent playing another orgasm squirt while one is running
	; actually this is the same lock used in PlaySpankSquirt() so there should be 
	; exactly one squirt at any time, no matter if caused by spank or orgasm
	if actorRef.IsEquipped(LactisNippleSquirtArmorL)
		return
	endif
		
	
	if !ostim.AppearsFemale(actorRef) || (!ostim.IsNaked(actorRef) && !OStimNonNakedSquirtEnabled)
		Console("PlayOrgasmSquirt: Orgasm squirt cancelled. "+ "actorRef.IsEquipped(LactisNippleSquirtArmorL)=" + actorRef.IsEquipped(LactisNippleSquirtArmorL) + ", ostim.IsNaked=" + ostim.IsNaked(actorRef) + ", ostim.IsFemale=" + ostim.IsFemale(actorRef) + ", AppearsFemale=" + ostim.AppearsFemale(actorRef))
		return
	endif

	LactisNippleSquirtArmor armorLeftRef = StartNippleSquirtLeft(actorRef, 2)	
	LactisNippleSquirtArmor armorRightRef = StartNippleSquirtRight(actorRef, 2)
	if NippleLeakEnabled
		StartNippleLeak(actorRef, 10)
	endif
	actorRef.QueueNiNodeUpdate()
	Utility.Wait(OStimOrgasmSquirtDuration)

	Console("Stopping left and right nipple squirt")
	StopNippleSquirt(actorRef, armorLeftRef, armorRightRef)

	armorLeftRef = None
	armorRightRef = None
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
	; Actor subActor = ostim.GetSubActor()

	; check the lock to prevent playing another spank squirt while one is running
	; actually this is the same lock used in PlayOrgasmSquirt() so there should be 
	; exactly one squirt at any time, no matter if caused by spank or orgasm
	if actorRef.IsEquipped(LactisNippleSquirtArmorL)
		return
	endif

	; on a female player with the SOS Futanari schlong attached IsFemale==false and the spank squirt will not be played
	; thus we use AppearsFemale().. 
	; TODO: i guess this could be cached at OnOstimPrestart
	; if (!ostim.IsNaked(subActor) || !ostim.AppearsFemale(subActor)) 
	if !ostim.AppearsFemale(actorRef) || (!ostim.IsNaked(actorRef) && !OStimNonNakedSquirtEnabled)
		Console("PlaySpankSquirt: Spank squirt cancelled. actor=" + actorRef + "actorRef.IsEquipped(LactisNippleSquirtArmorL)=" + actorRef.IsEquipped(LactisNippleSquirtArmorL) + ", ostim.IsNaked(subActor)=" + ostim.IsNaked(actorRef) + ", ostim.IsFemale(subActor)=" + ostim.IsFemale(actorRef) + ", AppearsFemale=" + ostim.AppearsFemale(actorRef))
		return
	endif

	Console("PlaySpankSquirt: ostim.GetMaxSpanksAllowed=" + ostim.GetMaxSpanksAllowed() + ", ostim.GetSpankCount" + ostim.GetSpankCount())

	LactisNippleSquirtArmor armorLeftRef = StartNippleSquirtLeft(actorRef, 0)
	LactisNippleSquirtArmor armorRightRef = StartNippleSquirtRight(actorRef, 0)
	if NippleLeakEnabled
		StartNippleLeak(actorRef, 10)
	endif

	if ostim.IsInFreeCam()
		actorRef.QueueNiNodeUpdate()
	endif

	Utility.Wait(OStimSpankSquirtDuration)
	
	StopNippleSquirt(actorRef, armorLeftRef, armorRightRef)
	armorLeftRef = None
	armorRightRef = None

	; if ostim.IsInFreeCam() && subActor == playerref
	; 	subActor.QueueNiNodeUpdate()
	; endif
	Utility.Wait(0.2)
EndFunction


Event OnOstimAnimationChanged(string eventName, string strArg, float numArg, Form sender)
	Console("OnOstimAnimationChanged: eventName=" + eventName + ", strArg=" + strArg + ", numArg="+ numArg)

	Actor subActor = ostim.GetSubActor()

	if subActor.IsEquipped(LactisNippleSquirtArmorL)
		return
	endif

	String currentAnimClass = ostim.GetCurrentAnimationClass()
	Console("OnOstimSpank: currentAnimClass=" + currentAnimClass)
	if (currentAnimClass=="Pf2" || currentAnimClass=="VJ" || currentAnimClass=="Cr" || currentAnimClass=="Po") 		
		LactisNippleSquirtArmor armorLeftRef = StartNippleSquirtLeft(subActor, 1)
		LactisNippleSquirtArmor armorRightRef = StartNippleSquirtRight(subActor, 1)
		if NippleLeakEnabled
			StartNippleLeak(subActor, 4)
		endif
		Utility.Wait(OStimSpankSquirtDuration)
		StopNippleSquirt(subActor, armorLeftRef, armorRightRef)		
		armorLeftRef = None
		armorRightRef = None	
	endif

EndEvent

Event OnOStimPrestart(string eventName, string strArg, float numArg, Form sender)
	Console("OnOStimPrestart")
	origOstimSpankMax = ostim.GetMaxSpanksAllowed()
	ostim.SetSpankMax(ostimSpankMax)
endevent

Event OnOStimEnd(string eventName, string strArg, float numArg, Form sender)
	Console("OnOStimEnd")
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
