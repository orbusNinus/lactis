;
; ███████╗ ██████╗ ██╗   ██╗██╗██████╗ ████████╗     █████╗ ██████╗ ███╗   ███╗ ██████╗ ██████╗ 
; ██╔════╝██╔═══██╗██║   ██║██║██╔══██╗╚══██╔══╝    ██╔══██╗██╔══██╗████╗ ████║██╔═══██╗██╔══██╗
; ███████╗██║   ██║██║   ██║██║██████╔╝   ██║       ███████║██████╔╝██╔████╔██║██║   ██║██████╔╝
; ╚════██║██║▄▄ ██║██║   ██║██║██╔══██╗   ██║       ██╔══██║██╔══██╗██║╚██╔╝██║██║   ██║██╔══██╗
; ███████║╚██████╔╝╚██████╔╝██║██║  ██║   ██║       ██║  ██║██║  ██║██║ ╚═╝ ██║╚██████╔╝██║  ██║
; ╚══════╝ ╚══▀▀═╝  ╚═════╝ ╚═╝╚═╝  ╚═╝   ╚═╝       ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝
                                                                                              
Scriptname LactisNippleSquirtArmor extends ObjectReference  
 
Actor Property ActorRef Auto
Float[] Property NippleOffset Auto
Float[] Property NippleOffsetR Auto
Float Property GlobalEmitterScale Auto
Float Property EmitterScale Auto
Bool Property DebugAxisEnabled Auto
Bool Property UseRandomYRotation Auto
Bool Property UseRandomEmitterScale Auto
Bool Property UseRandomEmitterDeactivation Auto

String[] LevelNifsL
String[] LevelNifsR

String LactisGroupNameL = "Lactis Group L"
String LactisGroupNameR = "Lactis Group R"

String LactisAxisNameL = "Lactis Axis L"
String LactisAxisNameR = "Lactis Axis R"

String LactisEmitter1NameL = "Lactis Emitter Left 1"
String LactisEmitter1NameR = "Lactis Emitter Right 1"

String LactisEmitter2NameL = "Lactis Emitter Left 2"
String LactisEmitter2NameR = "Lactis Emitter Right 2"

String LactisEmitter3NameL = "Lactis Emitter Left 3"
String LactisEmitter3NameR = "Lactis Emitter Right 3"

Float[] rot 
Form baseObject
ArmorAddon armorAA
ArmorAddon armorAAR
int currentLevel

Event OnInit()    
    If self == None
        return
    EndIf
    
    baseObject = self.GetBaseObject()
    armorAA = (baseObject as Armor).GetNthArmorAddon(0)
    armorAAR = (baseObject as Armor).GetNthArmorAddon(1)
    ; OnInit the actorRef will always be the default value set in the CK (set to PlayerRef there)    
    ; Console("OnInit: actorName=" + ", self=" + self + ", baseObject=" + baseObject + ", ActorRef=" + ActorRef + ", EmitterScale=" + EmitterScale)
    ; Thus the update here will be wasted when the actor is not the player after container change    
    
    rot = new Float[3]

    LevelNifsL = new String[3]    
    LevelNifsL[0] = "OninusLactis/nipplesquirt-left-lvl1.nif"
    LevelNifsL[1] = "OninusLactis/nipplesquirt-left-lvl2.nif"
    LevelNifsL[2] = "OninusLactis/nipplesquirt-left-lvl3.nif"
    LevelNifsR = new String[3]
    LevelNifsR[0] = "OninusLactis/nipplesquirt-right-lvl1.nif"
    LevelNifsR[1] = "OninusLactis/nipplesquirt-right-lvl2.nif"
    LevelNifsR[2] = "OninusLactis/nipplesquirt-right-lvl3.nif"

    currentLevel = 0
EndEvent

; Event OnGameLoad()    
;     Console("OnGameLoad")
;     rot = new Float[3]
; EndEvent

; Event OnUnload()
;     Console("OnUnload")
;     ; UnregisterForUpdate()
;     ; Debug.Trace("This object has been unloaded, animations can't be played on it anymore")
; EndEvent

; Event OnUnequipped(Actor akActor)
;     Console("OnUnequipped: self=" + self + ", baseObject=" + baseObject)   
;     ; DisableNoWait()
;     ; Delete()
; EndEvent

; Event OnEquipped(Actor akActor)     
;     Console("OnEquipped: ") 
;     ActorRef = None
; EndEvent

Event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)        
    
    If akNewContainer == ActorRef
        ; Console("OnContainerChanged: new container is ActorRef=" + ActorRef + ", self=" + self + ", baseObject=" + baseObject)
        ; float ftimeStart = Utility.GetCurrentRealTime() 

        ; Using "self" instead of "baseObject" does not work, as we will get an 
        ; Error:  (FF000D17): has no 3d and cannot be equipped.
        ActorRef.EquipItem(baseObject, true, true)
        ; float ftimeEnd  = Utility.GetCurrentRealTime() 
        
        ; waiting after equippingn will somehow fix the "freecam blocks alignment/netimmerse update" problem        
        Utility.Wait(0.05)
        UpdateNodeProperties()
        ; float ftimeEnd2  = Utility.GetCurrentRealTime() 
        ; Console("## Equipping took " + (ftimeEnd - ftimeStart) + "s. Updating node props took " + (ftimeEnd2-ftimeStart) + "s, " + ", total=" + (ftimeEnd-ftimeStart))
                        
        ActorRef.QueueNiNodeUpdate()        
        Utility.Wait(0.05)
    Else
        ; Console("OnContainerChanged: new container is " + akNewContainer)       
        ; armor was unequipped (isnt acually called?!)
    EndIf
EndEvent

; Function Update()        
;     if (UseRandomYRotation == true)
;         ; Console("OnUpdate: UseRandomYRotation=" + UseRandomYRotation)
;         NetImmerse.GetNodeLocalRotationEuler(ActorRef, LactisGroupName, rot, false)
;         rot[2] = Utility.RandomFloat(-10, 10)
;         NetImmerse.SetNodeLocalRotationEuler(ActorRef, LactisGroupName, rot, false)   
;     Else
;         ; NetImmerse.SetNodeLocalRotationEuler(ActorRef, LactisGroupName, rot, false)
;     EndIf

;     if (UseRandomEmitterScale)
;         ; Console("OnUpdate: UseRandomEmitterScale=" + UseRandomEmitterScale)
;         ; emitter wide scale        
;         bool emitterOn = true
;         float randomEmitterScale = Utility.RandomFloat(0.5, 1.0)
;         if (UseRandomEmitterDeactivation)
;             emitterOn = Utility.RandomInt(0,1)
;             if (emitterOn==0.0)
;                 randomEmitterScale = 0.01
;             endif
;         endif
;         NetImmerse.SetNodeScale(ActorRef, LactisEmitter1Name, randomEmitterScale, false)

;         randomEmitterScale = Utility.RandomFloat(0.5, 1.0)
;         if (UseRandomEmitterDeactivation)
;             emitterOn = Utility.RandomInt(0,1)
;             if (emitterOn==0.0)
;                 randomEmitterScale = 0.01
;             endif
;         endif
;         NetImmerse.SetNodeScale(ActorRef, LactisEmitter2Name, randomEmitterScale, false)
        
;         randomEmitterScale = Utility.RandomFloat(0.5, 1.0)
;         if (UseRandomEmitterDeactivation)
;             emitterOn = Utility.RandomInt(0,1)
;             if (emitterOn==0.0)
;                 randomEmitterScale = 0.01
;             endif
;         endif
;         NetImmerse.SetNodeScale(ActorRef, LactisEmitter3Name, randomEmitterScale, false)
;     EndIf
   
; EndFunction

Function SetLevel(int index, bool doEquip=true)
    if index>2
        index=2
    endif
    ; Console("index=" + index)
    
    armorAA.SetModelPath(LevelNifsL[index], false, true)
    armorAAR.SetModelPath(LevelNifsR[index], false, true)
    ; ActorRef.QueueNiNodeUpdate()

    currentLevel = index

    if doEquip
        ; it seems that QueueNiNodeUpdate() does NOT force the new nif to be shown/loaded.
        ; unfortunately we have to do an UnequipItem/EquipItem cycle
        ; NiSwitchNode support would be gold here
        ActorRef.UnequipItem(baseObject, true, true)
        Utility.Wait(0.05)
        ActorRef.EquipItem(baseObject, true, true)
        Utility.Wait(0.05)
        UpdateNodeProperties()    
        ActorRef.QueueNiNodeUpdate()
    endif
EndFunction

int Function GetLevel()
    return currentLevel
EndFunction


; Updates armor node position, scale and the debug axis. Changes it's scale 
; depending on whether it is enabled in MCM or not. If disabled, scale will be
; set to 0 to make the axis invisible.
Function UpdateNodeProperties() 
	if (DebugAxisEnabled==true)
		NetImmerse.SetNodeScale(ActorRef, LactisAxisNameL, 0.25, false)
        NetImmerse.SetNodeScale(ActorRef, LactisAxisNameR, 0.25, false)
	else
		NetImmerse.SetNodeScale(ActorRef, LactisAxisNameL, 0, false)
        NetImmerse.SetNodeScale(ActorRef, LactisAxisNameR, 0, false)
	endif
    NetImmerse.SetNodeLocalPosition(ActorRef, LactisGroupNameL, NippleOffset, false)
    NetImmerse.SetNodeLocalPosition(ActorRef, LactisGroupNameR, NippleOffsetR, false)
    float totalScale = GlobalEmitterScale*EmitterScale
    ; Console("UpdateNodeProperties: actorRef=" + ActorRef + ", GlobalEmitterScale=" + GlobalEmitterScale + ", EmitterScale=" + EmitterScale + ", totalScale=" + totalScale)
    NetImmerse.SetNodeScale(ActorRef, LactisGroupNameL, totalScale, false)    
    NetImmerse.SetNodeScale(ActorRef, LactisGroupNameR, totalScale, false)
    ; NiOverride.AddOverrideFloat(ActorRef, true, baseObject as Armor, armorAA, "EmitterParticleSystem", 23, -1, 2, false)
    
    ActorRef.QueueNiNodeUpdate()
EndFunction

; Experimental. Does not work.
; Function StartParticleSystem()
;     Console("StartParticleSystem")
;     NiOverride.AddOverrideFloat(ActorRef, true, baseObject as Armor, armorAA, "EmitterParticleSystem", 20, 0, 0, false)
;     NiOverride.AddOverrideFloat(ActorRef, true, baseObject as Armor, armorAA, "EmitterParticleSystem", 20, 1, 0, false)
;     NiOverride.AddOverrideFloat(ActorRef, true, baseObject as Armor, armorAA, "EmitterParticleSystem", 20, 2, 0, false)
;     ActorRef.QueueNiNodeUpdate()
; EndFunction

; Experimental. Does not work.
; Function StopParticleSystem()
;     Console("StopParticleSystem")
;     NiOverride.AddOverrideFloat(ActorRef, true, baseObject as Armor, armorAA, "EmitterParticleSystem", 20, 0, -1.0, false)
;     NiOverride.AddOverrideFloat(ActorRef, true, baseObject as Armor, armorAA, "EmitterParticleSystem", 20, 1, -1.0, false)
;     NiOverride.AddOverrideFloat(ActorRef, true, baseObject as Armor, armorAA, "EmitterParticleSystem", 20, 2, -1.0, false)
;     ActorRef.QueueNiNodeUpdate()
; EndFunction


Function Console(String msg) 
	MiscUtil.PrintConsole("LactisNippleSquirtArmor: " + msg)
    Debug.Trace("LactisNippleSquirtArmor: " + msg)
EndFunction
