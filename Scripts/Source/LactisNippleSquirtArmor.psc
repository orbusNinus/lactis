Scriptname LactisNippleSquirtArmor extends ObjectReference  
 
Actor Property ActorRef Auto
Float[] Property NippleOffset Auto
Float Property GlobalEmitterScale Auto
Float Property EmitterScale Auto
Bool Property DebugAxisEnabled Auto
Bool Property UseRandomYRotation Auto
Bool Property UseRandomEmitterScale Auto
Bool Property UseRandomEmitterDeactivation Auto
String[] Property LevelNifs Auto

String Property LactisGroupName Auto
String Property LactisAxisName Auto
String Property LactisEmitter1Name Auto
String Property LactisEmitter2Name Auto
String Property LactisEmitter3Name Auto

Float[] rot 
Form baseObject
ArmorAddon armorAA

Event OnInit()    
    baseObject = self.GetBaseObject()
    armorAA = (baseObject as Armor).GetNthArmorAddon(0)
    ; OnInit the actorRef will always be the default value set in the CK (set to PlayerRef there)    
    ; Console("OnInit: self=" + self + ", baseObject=" + baseObject + ", ActorRef=" + ActorRef)   
    ; Thus the update here will be wasted when the actor is not the player after container change
    ; Update()
    rot = new Float[3]
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
                
        ; RegisterForSingleUpdate(0.01)
        ActorRef.QueueNiNodeUpdate()        
        Utility.Wait(0.05)
    Else
        ; Console("OnContainerChanged: new container is " + akNewContainer)       
        ; armor was unequipped (isnt acually called?!)
    EndIf
EndEvent

Function Update()
    ; Console("Update")
        
    if (UseRandomYRotation == true)
        ; Console("OnUpdate: UseRandomYRotation=" + UseRandomYRotation)
        NetImmerse.GetNodeLocalRotationEuler(ActorRef, LactisGroupName, rot, false)
        rot[2] = Utility.RandomFloat(-10, 10)
        NetImmerse.SetNodeLocalRotationEuler(ActorRef, LactisGroupName, rot, false)   
    Else
        ; NetImmerse.SetNodeLocalRotationEuler(ActorRef, LactisGroupName, rot, false)
    EndIf

    if (UseRandomEmitterScale)
        ; Console("OnUpdate: UseRandomEmitterScale=" + UseRandomEmitterScale)
        ; emitter wide scale        
        bool emitterOn = true
        float randomEmitterScale = Utility.RandomFloat(0.5, 1.0)
        if (UseRandomEmitterDeactivation)
            emitterOn = Utility.RandomInt(0,1)
            if (emitterOn==0.0)
                randomEmitterScale = 0.01
            endif
        endif
        NetImmerse.SetNodeScale(ActorRef, LactisEmitter1Name, randomEmitterScale, false)

        randomEmitterScale = Utility.RandomFloat(0.5, 1.0)
        if (UseRandomEmitterDeactivation)
            emitterOn = Utility.RandomInt(0,1)
            if (emitterOn==0.0)
                randomEmitterScale = 0.01
            endif
        endif
        NetImmerse.SetNodeScale(ActorRef, LactisEmitter2Name, randomEmitterScale, false)
        
        randomEmitterScale = Utility.RandomFloat(0.5, 1.0)
        if (UseRandomEmitterDeactivation)
            emitterOn = Utility.RandomInt(0,1)
            if (emitterOn==0.0)
                randomEmitterScale = 0.01
            endif
        endif
        NetImmerse.SetNodeScale(ActorRef, LactisEmitter3Name, randomEmitterScale, false)
    EndIf
   
EndFunction

Function SetLevel(int index, bool doEquip=true)
    ; Console("index=" + index)
    ; ArmorAddon aal = (baseObject as Armor).GetNthArmorAddon(0)
    armorAA.SetModelPath(levelNifs[index], false, true)
    ; ActorRef.QueueNiNodeUpdate()

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


; Updates the left debug axis. Changes it's scale depending on whether it is enabled
; in MCM or not. If disabled, scale will be set to 0 to make the axis invisible.
Function UpdateNodeProperties() 
	if (DebugAxisEnabled==true)
		NetImmerse.SetNodeScale(ActorRef, LactisAxisName, 0.25, false)
	else
		NetImmerse.SetNodeScale(ActorRef, LactisAxisName, 0, false)
	endif
    NetImmerse.SetNodeLocalPosition(ActorRef, LactisGroupName, NippleOffset, false)
    NetImmerse.SetNodeScale(ActorRef, LactisGroupName, GlobalEmitterScale*EmitterScale, false)
    ActorRef.QueueNiNodeUpdate()
EndFunction


Function Console(String msg) 
	MiscUtil.PrintConsole("LactisNippleSquirtArmor: " + msg)
    Debug.Trace("LactisNippleSquirtArmor: " + msg)
EndFunction
