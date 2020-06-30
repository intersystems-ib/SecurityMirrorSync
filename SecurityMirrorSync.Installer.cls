Class SecurityMirrorSync.Installer Extends %RegisteredObject
{

/// Shared Path where security export files are exchanged
Property SharedPath As %String(MAXLEN = "");

/// Run installer
/// pPath - Shared Path where security export files are exchanged.
ClassMethod Run(pPath As %String = "") As %Status
{
	set ret = $$$OK
	set retTxt = "OK"
	set obj = ..%New()
	try {
		do obj.Log("SecurityMirrorSync Installer started")
		set obj.SharedPath=pPath
		if $system.Mirror.IsMember() {
			$$$THROWONERROR(tSC, obj.DeleteGlobals())
			$$$THROWONERROR(tSC, obj.Install())
		}else{
			set retTxt = "NOT INSTALLED: The instance is not a Mirror member"
		}
	} catch ex {
		set ret = ex.AsStatus()
		set retTxt = $system.Status.GetOneErrorText(ret)
	}
	do obj.Log("SecurityMirrorSync Installer ended")
	do obj.Log("Status="_retTxt)
	quit ret
}

/// Install files
Method Install() As %Status
{
	set ret = $$$OK
	try {
		//Check SharedPath
		if ..SharedPath="" $$$ThrowStatus($$$ERROR($$$GeneralError,"SharedPath cannot be empty"))
		
		//Enable Audit
		set system=##class(Security.System).%OpenId("SYSTEM")
		set system.AuditEnabled=1
		do system.%Save()
		do ..Log("Audit Enabled")
		
		//Enable Audit events
		do ..Log("   ...enabling events")
		set event=##class(Security.Events).%OpenId("%system||%security||resourcechange")
		set event.Enabled=1
		do event.%Save()
		do ..Log("%System||%Security||ResourceChange: Enabled")
		
		set event=##class(Security.Events).%OpenId("%system||%security||rolechange")
		set event.Enabled=1
		do event.%Save()
		do ..Log("%System||%Security||RoleChange: Enabled")
		
		set event=##class(Security.Events).%OpenId("%system||%security||userchange")
		set event.Enabled=1
		do event.%Save()
		do ..Log("%System||%Security||UserChange: Enabled")
		
		set event=##class(Security.Events).%OpenId("%system||%security||applicationchange")
		set event.Enabled=1
		do event.%Save()
		do ..Log("%System||%Security||ApplicationChange: Enabled")
		
		set event=##class(Security.Events).%OpenId("%system||%security||sslconfigchange")
		set event.Enabled=1
		do event.%Save()
		do ..Log("%System||%Security||SSLConfigChange: Enabled")
		
		do ..Log("   ...disabling events")
		set event=##class(Security.Events).%OpenId("%system||%security||auditreport")
		set event.Enabled=0
		do event.%Save()
		do ..Log("%System||%Security||AuditReport: Disabled")
		
		set event=##class(Security.Events).%OpenId("%system||%system||configurationchange")
		set event.Enabled=0
		do event.%Save()
		do ..Log("%System||%System||ConfigurationChange: Disabled")

		
		//Create Task
		
		//First, check if exist already a Task with the same name. If so, delete it.
		do ..DeleteTaskByName("SecurityMirrorSync")
		
		do ..Log("   ...creating tasks")
		set task=##class(%SYS.Task).%New()
		set task.Name="SecurityMirrorSync"
		set task.Description="Export/Import security settings in a Mirror configuration"
		set task.NameSpace="%SYS"

		// Schedule 
		set task.DailyFrequencyTime=0 // 0 = minutes
		set task.DailyFrequency=1 // 1 minute
		set task.DailyIncrement=1 // 1 minutes between runs
		set task.DailyStartTime=0 // Time for tasks to start running in $H format($p($h,",",2))
		// Start from now
		set task.StartDate = $p($h,",",1)
		// Run on Any Mirror member regardless of status
		set task.MirrorStatus = 3
		// Task definition
		set task.TaskClass="SecurityMirrorSync.Task"
		set task.Settings=$LB("SharedPath", ..SharedPath)
		do task.%Save()
		
		do ..Log("Task ""SecurityMirrorSync"" scheduled:")
		do ..Log("Start date:"_$zdate(task.StartDate)_", now.")
		do ..Log("Run automatically every "_task.DailyFrequency_" minute")
	
	} catch ex {
		set ret = ex.AsStatus()
	}
	quit ret
}

Method DeleteGlobals() As %Status
{
	set ret = $$$OK
	try {
		if $d(^SecurityMirrorSync){
			k ^SecurityMirrorSync
		}
		
	} catch ex {
		set ret = ex.AsStatus()
	}
	quit ret
}

/// Uninstalls SecurityMirrorSync.
/// *WARNING* it actually deletes classes!!
ClassMethod Uninstall() As %Status
{
	set ret = $$$OK
	set obj = ..%New()
	try {
		do ..Log("Deleting SecurityMirrorSync routines...")
		$$$ThrowOnError(##class(%RoutineMgr).Delete("SecurityMirrorSync.mac"))

		do ..Log("Deleting SecurityMirrorSync classes...")
		$$$ThrowOnError($system.OBJ.DeletePackage("SecurityMirrorSync"))
		
		w !
		do ..Log("Deleting SecurityMirrorSync globals...")
		$$$ThrowOnError(obj.DeleteGlobals())
		
		do ..Log("Deleting SecurityMirrorSync tasks...")
		$$$ThrowOnError(obj.DeleteTaskByName("SecurityMirrorSync"))
		
		do ..Log("SecurityMirrorSync succesfully uninstalled")
	} catch ex {
		set ret = ex.AsStatus()
	}
	quit ret
}

/// Log a message
/// pText - Text message
/// pTimeStamp - Add a timestamp
/// pNewLine - Add a new line
ClassMethod Log(pText As %String, pTimeStamp As %Boolean = 1, pNewLine As %Boolean = 1)
{
	write $case(pTimeStamp,1:"["_$zdt($h,3)_"] ",:"")_pText_$case(pNewLine,1:$$$NL,:"")
}

Method DeleteTaskByName(name As %String) As %Status
{
	set ret = $$$OK
	try {
		//Check if exist already Tasks with the same name. If so, delete them.
		set rs=##class(%ResultSet).%New("%SYS.Task:QuickTaskList")
		do rs.Execute()
		while rs.Next() {
			if rs.Get("Task Name") = name {
				do ##class(%SYS.Task).%DeleteId(rs.Get("ID"))
				do ..Log("Task named "_rs.Get("Task Name")_": deleted")
			}
		}
	} catch ex {
		set ret = ex.AsStatus()
	}
	quit ret
}

}
