# SecurityMirrorSync

Author: Antonio de Pedro
        Eduardo Anglada (small modifications, Antonio did all the work!)

InterSystems Cache does not exchange security information between Mirror members, such as Users, Roles, Resources, etc.

SecurityMirrorSync solves this by exchanging security export files from the primary (active) failover member to the backup (inactive) failover member.

In summary, this add-on consists of a Task that checks the Audit database. In case the Task founds an entry of  creation/change of a user, role, resource, etc it exports only the type of information changed.

For example: In the case a user has been created, The routine launched by the Task, exports all the users.

# Notes and limitations
SecurityMirrorSync does not remove Users, Roles, Resources, etc.

It is recommended to disable users instead of removing them from the system (while using this add-on).

For SecurityMirrorSync to work properly, do not disable the following Audit events:

%System/%Security/ResourceChange
%System/%Security/RoleChange
%System/%Security/UserChange
%System/%Security/ApplicationChange
%System/%Security/SSLConfigChange

Also, do not remove the Scheduled Task SecurityMirrorSync.

# Disclaimer
This package is an add-on for InterSystems Cache and does not form part of the official release.

InterSystems standard technical assistance will not attend issues related with this package.

It is recommended to test this add-on first in a test environment and check it performs as you expect.

# Installation
These install actions need to be performed on each Mirror member machine:
Save SecurityMirrorSync.xml in a OS path <dir>
Choose a <SharedDir> that is accesible by both Mirror members
(this <SharedDir> could be different mounted name on each member, but in fact must be the same physical storage place for both members)
Note: This directory must have the same permissions as the Ensemble-install-directory has.
**Permissions Example:
cd /home/
ls -la
drwxrwxr-x. 6 ensemble cacheusr 232 sep 7 15:20 ensemble
Inside that directory should be the mounted directory linked to the SharedDir.
***************************
Open an OS System console
Execute:
ccontrol session <instance>
Log in:
User, Password
Execute:
zn "%SYS"
do $system.OBJ.Load("<dir>/SecurityMirrorSync.xml","ck")
do ##class(SecurityMirrorSync.Installer).Run(<SharedDir>)

**Installation Example:
[root@failover2 ~]# ccontrol session ENSEMBLE

Nodo: failover2.isc.com, Instancia: ENSEMBLE

Usuario: _SYSTEM
ContraseÃ±a: ***
USER>zn "%SYS"

%SYS>do $system.OBJ.Load("/home/ensemble/SecurityMirrorSync.xml","ck")

Carga iniciada en 09/06/2017 12:44:52
Cargando arch. /home/ensemble/SecurityMirrorSync.xml como xml
Clase importada: SecurityMirrorSync.Installer
Rutina importada: SecurityMirrorSync.MAC
Clase importada: SecurityMirrorSync.Task
Proyecto importado: SecurityMirrorSync.prj
, compilando clases de 2, utilizando los trabajos del empleado 2
Compilando clase SecurityMirrorSync.Installer
Compilando clase SecurityMirrorSync.Task
Compilando rutina SecurityMirrorSync.Installer.1
Compilando rutina SecurityMirrorSync.Task.1
Compilando rutina : SecurityMirrorSync.mac
Carga correcta terminada.

%SYS>do ##class(SecurityMirrorSync.Installer).Run("/home/ensemble/MirrorSync")
[2017-09-07 11:05:01] SecurityMirrorSync Installer started
[2017-09-07 11:05:01] Audit Enabled
[2017-09-07 11:05:01] ...enabling events
[2017-09-07 11:05:01] %System||%Security||ResourceChange: Enabled
[2017-09-07 11:05:01] %System||%Security||RoleChange: Enabled
[2017-09-07 11:05:01] %System||%Security||UserChange: Enabled
[2017-09-07 11:05:01] %System||%Security||ApplicationChange: Enabled
[2017-09-07 11:05:01] %System||%Security||SSLConfigChange: Enabled
[2017-09-07 11:05:01] ...disabling events
[2017-09-07 11:05:01] %System||%Security||AuditReport: Disabled
[2017-09-07 11:05:01] %System||%System||ConfigurationChange: Disabled
[2017-09-07 11:05:01] ...creating tasks
[2017-09-07 11:05:01] Task "SecurityMirrorSync" scheduled:
[2017-09-07 11:05:01] Start date:09/07/2017, now.
[2017-09-07 11:05:01] Run automatically every 1 minute
[2017-09-07 11:05:01] SecurityMirrorSync Installer ended
[2017-09-07 11:05:01] Status=OK


