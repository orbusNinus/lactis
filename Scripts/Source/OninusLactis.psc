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
Bool Property NippleLeakEnabled Auto
Bool Property DebugAxisEnabled Auto
Bool Property UseRandomYRotation Auto
Bool Property UseRandomEmitterScale Auto
Bool Property UseRandomEmitterDeactivation Auto

; --- Fields (private)

Float fVersion
Int KeyToggleSwitch = 24 ; Key "O" the letter, not zero, FOR DEBUGGING switch

; object reference to the left nipple squirt armor
LactisNippleSquirtArmor playerArmorLeftRef = None 
; object reference to the right nipple squirt armor
LactisNippleSquirtArmor playerArmorRightRef = None 

; --- Internal state variables

Int switch = 0
bool isLeftSquirtOn = false
bool isRightSquirtOn = false

; --- OStim integration

OsexIntegrationMain ostim
bool isAnyOStimSquirtPlaying = false

Bool Function HasOStim() 	
	return ostim!=None
EndFunction

Event OnInit()
	Debug.Notification("OninusLactis installed.")	
	; RegisterForSingleUpdate(10.0) ; Give us a single update in one second
	Maintenance()
EndEvent

Function Maintenance()
	If fVersion < 0.2 ; <--- Edit this value when updating
		fVersion = 0.2 ; and this
		Debug.Notification("Now running OninusLactis version: " + fVersion)
		; Update Code		
	EndIf

	; Other maintenance code that only needs to run once per save load		
	Console("loaded version is " + fVersion)
	RegisterForKey(StartLactatingKey) 
	RegisterForKey(KeyToggleSwitch) ; Key "O" the letter, not zero, FOR DEBUGGING switch
	
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

	Utility.Wait(0.1)
; 	Console("playerArmorLeftRef=" + playerArmorLeftRef)
; 	if (playerArmorLeftRef && PlayerRef.IsEquipped(playerArmorLeftRef))
; 	 	UpdateArmorLeftProperties()
; 	endif
; 	Console("playerArmorRightRef=" + playerArmorRightRef)
; 	if (playerArmorRightRef && PlayerRef.IsEquipped(playerArmorRightRef))
; 		UpdateArmorRightProperties()
;    endif
EndFunction


Event OnKeyDown(Int keyCode)
	; https://www.creationkit.com/index.php?title=Input_Script#DXScanCodes	
	If (Utility.IsInMenuMode() || UI.IsMenuOpen("console"))
		Return
	EndIf

	Console("**** A registered key has been pressed: "+ keyCode)
	if (!ostim || (ostim && !ostim.AnimationRunning()))
		If (keyCode == StartLactatingKey)				
			ToggleNippleSquirt(PlayerRef)
		elseif (keyCode == KeyToggleSwitch)		
			if (playerArmorLeftRef!=None)
				if (switch==0)
					playerArmorLeftRef.SetLevel(0)
					playerArmorRightRef.SetLevel(0)
					switch=1
				elseif (switch==1)
					playerArmorLeftRef.SetLevel(1)
					playerArmorRightRef.SetLevel(1)		
					switch=2
				elseif (switch==2)
					playerArmorLeftRef.SetLevel(2)
					playerArmorRightRef.SetLevel(2)		
					switch=0
				endif			
			endif
		EndIf
	endif

EndEvent


; ----------------------------- Nipple leak

; Plays the nipple leaking effect on both breasts of the given 'ActorRef'.
; The 'duration' is in seconds, use -1 to play the effect forever.
; Note that the effect plays on both breats. Playing the leaking effect on 
; one side only is not possible.
Function StartNippleLeak(Actor actorRef, int duration)	
	Console("StartNippleLeak")
	LactisNippleLeakCBBE.play(actorRef, duration)		
EndFunction

; Stops the milk leaking effect on both breasts
Function StopNippleLeak(Actor actorRef)	
	Console("StopNippleLeak")
	LactisNippleLeakCBBE.Stop(actorRef)		
EndFunction

; ---------------------------- Nipple squirt

Function ToggleNippleSquirt(Actor actorRef)
	; changing state *before* play/stop effects as these are synchronous by using Wait() which
	; will mess up *SquirtOn state when we set it after play/stop effects.
	isLeftSquirtOn = !isLeftSquirtOn
	isRightSquirtOn = !isRightSquirtOn
	
	; How long does our operation take?
	float ftimeStart = Utility.GetCurrentRealTime()
	if (isLeftSquirtOn!=true) 
		; Debug.Notification("Nipple squirt right toggled off") 
		StopNippleSquirt(actorRef, playerArmorLeftRef, playerArmorRightRef)
		playerArmorLeftRef = None
		playerArmorRightRef = None
	Else
		; Debug.Notification("Nipple squirt left toggled on") 
		playerArmorLeftRef = StartNippleSquirtLeft(actorRef)		
		if NippleLeakEnabled		
			StartNippleLeak(actorRef, 10)
		endif
	EndIf

	if (isRightSquirtOn!=true) 
		; Debug.Notification("Nipple squirt right toggled off") 
		;StopNippleSquirtRight(actorRef, playerArmorRightRef)
		playerArmorRightRef = None
	Else
		; Debug.Notification("Nipple squirt right toggled on") 
		playerArmorRightRef = StartNippleSquirtRight(actorRef)					
	EndIf
	; Long operation here
	float ftimeEnd = Utility.GetCurrentRealTime()
	Console("Starting/stopping took " + (ftimeEnd - ftimeStart) + " seconds to run")

	Utility.Wait(0.1)
	actorRef.QueueNiNodeUpdate()
EndFunction


LactisNippleSquirtArmor Function StartNippleSquirtLeft(Actor actorRef, int level=0)
	Console("StartNippleSquirtLeft")	
	LactisNippleSquirtArmor armorLeftRef = actorRef.PlaceAtMe(LactisNippleSquirtArmorL, 1) as LactisNippleSquirtArmor	
	armorLeftRef.ActorRef = actorRef
	UpdateArmorProperties(armorLeftRef, NippleOffsetL)
	actorRef.AddItem(armorLeftRef, 1, true)
	; actorRef.EquipItem(armorLeftRef.GetBaseObject(), true, true)
	actorRef.QueueNiNodeUpdate()
	return armorLeftRef
EndFunction

LactisNippleSquirtArmor Function StartNippleSquirtRight(Actor actorRef, int level=0)
	Console("StartNippleSquirtRight")	
	LactisNippleSquirtArmor armorRightRef = actorRef.PlaceAtMe(LactisNippleSquirtArmorR, 1) as LactisNippleSquirtArmor
	armorRightRef.ActorRef = actorRef
	UpdateArmorProperties(armorRightRef, NippleOffsetR)
	actorRef.AddItem(armorRightRef, 1, true)
	; actorRef.EquipItem(armorRightRef.GetBaseObject(), true, true)
	actorRef.QueueNiNodeUpdate()
	return armorRightRef
EndFunction

Function StopNippleSquirt(Actor actorRef, LactisNippleSquirtArmor armorLeftRef, LactisNippleSquirtArmor armorRightRef)
	Console("StopNippleSquirt")

	if NippleLeakEnabled	
		StopNippleLeak(actorRef)
	endif

	actorRef.RemoveItem(armorLeftRef, 1, true)
	actorRef.RemoveItem(armorRightRef, 1, true)
	
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
	armorRef.UseRandomEmitterScale = UseRandomEmitterScale
	armorRef.UseRandomYRotation = UseRandomYRotation
	armorRef.UseRandomEmitterDeactivation = UseRandomEmitterDeactivation
EndFunction


Form Function GetBodyItem(Actor a)
	int mask = armor.GetMaskForSlot(32)
	armor item = a.GetWornForm(mask) as armor
	return item
EndFunction

Function UnequipItem(actor a, form item, bool force, bool remove)
	if item != none
		if a.IsEquipped(item)
			a.UnequipItem(item, force, true)
		endif
		if remove
			a.RemoveItem(item, 1, true)
		endif		
	endIf 
EndFunction

Function EquipItem(actor a, form item, bool force, bool add)
	if item != none
		if add
			a.addItem(item, 1, true)
		endif
		if !a.IsEquipped(item)
			a.EquipItem(item, force, true)	
		endif
	endIf 
EndFunction

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


; ----------------------------- OStim integration

Event OnOStimOrgasm(string eventName, string strArg, float numArg, Form sender)	
	Console("OnOStimOrgasm: eventName=" + eventName + ", strArg=" + strArg + ", numArg="+ numArg)
	PlayOrgasmSquirt()
EndEvent

Function PlayOrgasmSquirt()
	; check the lock to prevent playing another orgasm squirt while one is running
	; actually this is the same lock used in PlaySpankSquirt() so there should be 
	; exactly one squirt at any time, no matter if caused by spank or orgasm
	if (isAnyOStimSquirtPlaying)
		return
	endif
	
	; Assuming the subactor is getting spanked... dont know how to query who is spanked
	Actor orgasmActor = ostim.GetMostRecentOrgasmedActor()
	Console("PlayOrgasmSquirt: Last orgasmed actor is " + orgasmActor)

	if (!ostim.IsNaked(orgasmActor) || !ostim.AppearsFemale(orgasmActor)) 
		Console("PlayOrgasmSquirt: Orgasm squirt cancelled. isAnyOStimSquirtPlaying=" + isAnyOStimSquirtPlaying + ", ostim.IsNaked(orgasmActor)=" + ostim.IsNaked(orgasmActor) + ", ostim.IsFemale(orgasmActor)=" + ostim.IsFemale(orgasmActor) + ", AppearsFemale=" + ostim.AppearsFemale(orgasmActor))
		return
	endif
	isAnyOStimSquirtPlaying = true

	LactisNippleSquirtArmor armorLeftRef = StartNippleSquirtLeft(orgasmActor)	
	LactisNippleSquirtArmor armorRightRef = StartNippleSquirtRight(orgasmActor)
	if NippleLeakEnabled
		StartNippleLeak(orgasmActor, 10)
	endif
	armorLeftRef.SetLevel(2)
	armorRightRef.SetLevel(2)
	orgasmActor.QueueNiNodeUpdate()
	Utility.Wait(OStimOrgasmSquirtDuration)

	Console("Stopping left and right nipple squirt")
	StopNippleSquirt(orgasmActor, armorLeftRef, armorRightRef)
	; StopNippleSquirtRight(orgasmActor, armorRightRef)

	armorLeftRef = None
	armorRightRef = None
	; if ostim.IsInFreeCam() && subActor == playerref
	; 	subActor.QueueNiNodeUpdate()
	; endif
	Utility.Wait(0.2)
	isAnyOStimSquirtPlaying = false
EndFunction


Event OnOstimSpank(string eventName, string strArg, float numArg, Form sender)
	Console("OnOstimSpank: eventName=" + eventName + ", strArg=" + strArg + ", numArg="+ numArg)
	PlaySpankSquirt()
EndEvent

Function PlaySpankSquirt()
	; check the lock to prevent playing another spank squirt while one is running
	; actually this is the same lock used in PlayOrgasmSquirt() so there should be 
	; exactly one squirt at any time, no matter if caused by spank or orgasm
	if (isAnyOStimSquirtPlaying)
		return
	endif

	; Assuming the subactor is getting spank... dont know how to query who is spanked	
	; TODO: could be cached at OnStimPrestart
	Actor subActor = ostim.GetSubActor()

	; on a female player with the SOS Futanari schlong attached IsFemale==false and the spank squirt will not be played
	; thus we use AppearsFemale().. 
	; TODO: i guess this could be cached at OnOstimPrestart
	if (!ostim.IsNaked(subActor) || !ostim.AppearsFemale(subActor)) 
		Console("PlaySpankSquirt: Spank squirt cancelled. isAnyOStimSquirtPlaying=" + isAnyOStimSquirtPlaying + ", ostim.IsNaked(subActor)=" + ostim.IsNaked(subActor) + ", ostim.IsFemale(subActor)=" + ostim.IsFemale(subActor) + ", AppearsFemale=" + ostim.AppearsFemale(subActor))
		return
	endif

	isAnyOStimSquirtPlaying = true

	LactisNippleSquirtArmor armorLeftRef = StartNippleSquirtLeft(subActor)
	LactisNippleSquirtArmor armorRightRef = StartNippleSquirtRight(subActor)
	if NippleLeakEnabled
		StartNippleLeak(subActor, 10)
	endif

	Utility.Wait(OStimSpankSquirtDuration)

	Console("Stopping left and right nipple squirt")
	StopNippleSquirt(subActor, armorLeftRef, armorRightRef)
	armorLeftRef = None
	armorRightRef = None

	; if ostim.IsInFreeCam() && subActor == playerref
	; 	subActor.QueueNiNodeUpdate()
	; endif
	Utility.Wait(0.2)
	isAnyOStimSquirtPlaying = false
EndFunction


Event OnOstimAnimationChanged(string eventName, string strArg, float numArg, Form sender)
	Console("OnOstimAnimationChanged: eventName=" + eventName + ", strArg=" + strArg + ", numArg="+ numArg)

	Actor subActor = ostim.GetSubActor()
	String currentAnimClass = ostim.GetCurrentAnimationClass()
	Console("OnOstimSpank: currentAnimClass=" + currentAnimClass)
	if (isAnyOStimSquirtPlaying || currentAnimClass=="Pf2" || currentAnimClass=="VJ" || currentAnimClass=="Cr" || currentAnimClass=="Po") 
		isAnyOStimSquirtPlaying = true
		LactisNippleSquirtArmor armorLeftRef =StartNippleSquirtLeft(subActor)
		LactisNippleSquirtArmor armorRightRef =StartNippleSquirtRight(subActor)
		if NippleLeakEnabled
			StartNippleLeak(subActor, 4)
		endif
		Utility.Wait(OStimSpankSquirtDuration)
		StopNippleSquirt(subActor, armorLeftRef, armorRightRef)		
		armorLeftRef = None
		armorRightRef = None	
		isAnyOStimSquirtPlaying = false
	endif

EndEvent

Event OnOStimPrestart(string eventName, string strArg, float numArg, Form sender)
	Console("OnOStimPrestart")
endevent

Event OnOStimEnd(string eventName, string strArg, float numArg, Form sender)
	Console("OnOStimEnd")
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
