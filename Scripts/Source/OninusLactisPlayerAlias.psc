ScriptName OninusLactisPlayerAlias extends ReferenceAlias
 
OninusLactis Property QuestScript Auto
 
Event OnPlayerLoadGame()
	Debug.Trace("OninusLactisPlayerAlias::OnPlayerLoadGame")
	QuestScript.Maintenance()
EndEvent