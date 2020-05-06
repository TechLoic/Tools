# Created by Loic LEFORESTIER

# Check Dell brand
$brand = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer
if ($brand -eq 'Dell Inc.') 
{
	$Model = Get-ItemProperty -Path HKLM:\SOFTWARE\DELL\WARRANTY | Select-Object -ExpandProperty Model
	$ServiceTag = Get-ItemProperty -Path HKLM:\SOFTWARE\DELL\WARRANTY | Select-Object -ExpandProperty ServiceTag
	$WarrantyStartDate = Get-ItemProperty -Path HKLM:\SOFTWARE\DELL\WARRANTY | Select-Object -ExpandProperty WarrantyStartDate
	$WarrantyEndDate = Get-ItemProperty -Path HKLM:\SOFTWARE\DELL\WARRANTY | Select-Object -ExpandProperty WarrantyEndDate
    $WarrantySupportLevel = Get-ItemProperty -Path HKLM:\SOFTWARE\DELL\WARRANTY | Select-Object -ExpandProperty WarrantySupportLevel
    $WarrantyExpired = Get-ItemProperty -Path HKLM:\SOFTWARE\DELL\WARRANTY | Select-Object -ExpandProperty WarrantyExpired
	
	Add-Type -AssemblyName PresentationCore,PresentationFramework
    $ButtonType = [System.Windows.MessageBoxButton]::Ok
    $MessageIcon = [System.Windows.MessageBoxImage]::Information
    $MessageBody = "$env:computername est sous garantie jusqu'au $WarrantyEndDate`n`n[ Details ]`nModel : $Model`nServiceTag : $ServiceTag`nWarranty Expired : $WarrantyExpired`nWarranty Start Date : $WarrantyStartDate`nSupport Level : $WarrantySupportLevel"
    $MessageTitle = "Information"
    $Result = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)
}

else 
{
    # Error if not a Dell computer
	Add-Type -AssemblyName PresentationCore,PresentationFramework
    $ButtonType = [System.Windows.MessageBoxButton]::Ok
    $MessageIcon = [System.Windows.MessageBoxImage]::Error
    $MessageBody = "$env:computername n'est pas un ordinateur Dell"
    $MessageTitle = "Erreur"
    $Result = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)
}