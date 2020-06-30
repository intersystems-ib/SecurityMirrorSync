Class SecurityMirrorSync.Task Extends %SYS.Task.Definition
{

/// SharedPath references a path accesible to both Mirror failover members.
Property SharedPath As %String;

Parameter TaskName = "SecurityMirrorSync";

Method OnTask() As %Status
{
	do ^SecurityMirrorSync(..SharedPath)
	Quit $$$OK
}

}