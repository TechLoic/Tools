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
	
	$wshell = New-Object -ComObject Wscript.Shell
	$wshell.Popup("$env:computername est sous garantie jusqu'au $WarrantyEndDate`n`n[ Information ]`nModel : $Model`nServiceTag : $ServiceTag`nWarranty Start Date : $WarrantyStartDate`nSupport Level : $WarrantySupportLevel",0,"Information",0x40)
	
    Exit
}

else 
{
    # Error if not a Dell computer
    $wshell = New-Object -ComObject Wscript.Shell
	$wshell.Popup("Le PC $env:computername n'est pas un ordinateur Dell",0,"Erreur",0x30)

    Exit
}