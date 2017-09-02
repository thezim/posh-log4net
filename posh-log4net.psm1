function Get-Logger {
	param (
        [string]$LogPath,
        [string]$Name,
		[switch]$Compress
	)
	$scriptpath = Split-Path -Path $script:MyInvocation.MyCommand.Path
	$logconfigpath = "$scriptpath\log4net.config"
	$assemblypath = "$scriptpath\log4net.dll"
	Add-Type -Path $assemblypath
	$LogManager = [log4net.LogManager]
	$log4net = $LogManager::GetLogger($Name)
	$configfile = New-Object System.IO.FileInfo($logconfigpath)
	[log4net.Config.XmlConfigurator]::Configure($configfile)
	$repo = $LogManager::GetRepository()
	$appenders = $repo.Root.Appenders
	$fileappender = $appenders[0]
	$fileappender.File = $LogPath
	$fileappender.ActivateOptions()
	if($Compress -eq $true) {
		$filename = $LogPath.Replace("\","\\")
		$wmiquery = "SELECT * FROM CIM_DataFile WHERE Name='$filename'"
		$file = Get-WmiObject -Query $wmiquery
		$file.Compress() | Out-Null
	}
    $log4net
}