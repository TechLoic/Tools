# Created by Loic LEFORESTIER

# Check Dell brand
$brand = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer
if ($brand -eq 'Dell Inc.') 
{
    # Set ExecutionPolicy to Unrestricted
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine -Force

    # Create folders Get-DellWarranty
    $modulepathdell = "C:\Program Files\WindowsPowerShell\Modules\Get-DellWarranty\2.0.0.0"
    New-Item -Path "C:\Program Files\WindowsPowerShell\Modules\" -Name "Get-DellWarranty" -ItemType "Directory"
    New-Item -Path "C:\Program Files\WindowsPowerShell\Modules\Get-DellWarranty" -Name "2.0.0.0" -ItemType "Directory"

    # Create API files and folders
    New-Item -Path "$env:public\" -Name "Dell" -ItemType "Directory"
    New-Item "$env:public\Dell\DellKey.txt"
    Set-Content "$env:public\Dell\DellKey.txt" 'l72f322f276c3f4e3b85c64535a9446270'
    New-Item "$env:public\Dell\DellSec.txt"
    Set-Content "$env:public\Dell\DellSec.txt" 'f14b246ea80a4a7d949d63bdf9782f44'
    
    # Download Get-DellWarranty
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri https://github.com/TechLoic/Tools/raw/master/Get-DellWarranty/Get-DellWarranty.psd1 -OutFile $modulepathdell\Get-DellWarranty.psd1
    Invoke-WebRequest -Uri https://github.com/TechLoic/Tools/raw/master/Get-DellWarranty/Get-DellWarranty.psm1 -OutFile $modulepathdell\Get-DellWarranty.psm1
    Invoke-WebRequest -Uri https://github.com/TechLoic/Tools/raw/master/Get-DellWarranty/PSGetModuleInfo.xml -OutFile $modulepathdell\PSGetModuleInfo.xml

    # Disable IE First Run Customize
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize" -Value 2

    # Create registry keys
    if (Test-path HKLM:\SOFTWARE\DELL) {}
    else {New-Item -Path HKLM:\SOFTWARE\DELL}
    if (Test-path HKLM:\SOFTWARE\DELL\WARRANTY) {Remove-Item -Path HKLM:\SOFTWARE\DELL\WARRANTY}
    else {}
    New-Item -Path HKLM:\SOFTWARE\DELL\WARRANTY

    # Import module and run command
    Import-Module -Name Get-DellWarranty -Force
    Get-DellWarranty -Show -Full -Brand

    # Remove module files
    Remove-Item "$env:public\Dell" -Recurse
    Remove-Module -Name Get-DellWarranty
    Remove-Item 'C:\Program Files\WindowsPowerShell\Modules\Get-DellWarranty' -Recurse

    # Re-enable IE First Run Customize
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize"

    # Remove timestamp on value (00:00:00) and set french date format
    $FullOriginalShipDate = (Get-ItemProperty -Path HKLM:\SOFTWARE\DELL\WARRANTY\ -Name OriginalShipDate).OriginalShipDate
    $ShortOriginalShipDate = $FullOriginalShipDate -replace " 00:00:00"
    $OriginalShipDateMonth = $ShortOriginalShipDate.SubString(0,2)
    $OriginalShipDateDay = $ShortOriginalShipDate.SubString(3,2)
    $OriginalShipDateYear = $ShortOriginalShipDate.SubString(6,4)
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Dell\WARRANTY" -Name "OriginalShipDate" -Value "$OriginalShipDateDay/$OriginalShipDateMonth/$OriginalShipDateYear"

    $FullWarrantyStartDate = (Get-ItemProperty -Path HKLM:\SOFTWARE\DELL\WARRANTY\ -Name WarrantyStartDate).WarrantyStartDate
    $ShortWarrantyStartDate = $FullWarrantyStartDate -replace " 00:00:00"
    $StartDateMonth = $ShortWarrantyStartDate.SubString(0,2)
    $StartDateDay = $ShortWarrantyStartDate.SubString(3,2)
    $StartDateYear = $ShortWarrantyStartDate.SubString(6,4)
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Dell\WARRANTY" -Name "WarrantyStartDate" -Value "$StartDateDay/$StartDateMonth/$StartDateYear"

    $FullWarrantyEndDate = (Get-ItemProperty -Path HKLM:\SOFTWARE\DELL\WARRANTY\ -Name WarrantyEndDate).WarrantyEndDate
    $ShortWarrantyEndDate = $FullWarrantyEndDate -replace " 00:00:00"
    $EndDateMonth = $ShortWarrantyEndDate.SubString(0,2)
    $EndDateDay = $ShortWarrantyEndDate.SubString(3,2)
    $EndDateYear = $ShortWarrantyEndDate.SubString(6,4)
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Dell\WARRANTY" -Name "WarrantyEndDate" -Value "$EndDateDay/$EndDateMonth/$EndDateYear"

	$Model = Get-ItemProperty -Path HKLM:\SOFTWARE\DELL\WARRANTY | Select-Object -ExpandProperty Model
	$ServiceTag = Get-ItemProperty -Path HKLM:\SOFTWARE\DELL\WARRANTY | Select-Object -ExpandProperty ServiceTag
	$WarrantyStartDate = Get-ItemProperty -Path HKLM:\SOFTWARE\DELL\WARRANTY | Select-Object -ExpandProperty WarrantyStartDate
	$WarrantyEndDate = Get-ItemProperty -Path HKLM:\SOFTWARE\DELL\WARRANTY | Select-Object -ExpandProperty WarrantyEndDate
    $WarrantySupportLevel = Get-ItemProperty -Path HKLM:\SOFTWARE\DELL\WARRANTY | Select-Object -ExpandProperty WarrantySupportLevel
    $WarrantyExpired = Get-ItemProperty -Path HKLM:\SOFTWARE\DELL\WARRANTY | Select-Object -ExpandProperty WarrantyExpired
    $CompareWarrantyEndDate = [datetime]::ParseExact($WarrantyEndDate, "dd/MM/yyyy", $null)
    $Today = Get-Date
    Add-Type -AssemblyName PresentationCore,PresentationFramework

    if ($Today -le $CompareWarrantyEndDate) {
        $ButtonType = [System.Windows.MessageBoxButton]::Ok
        $MessageIcon = [System.Windows.MessageBoxImage]::Information
        $MessageBody = "$env:computername est sous garantie jusqu'au $WarrantyEndDate`n`n[ Details ]`nModel : $Model`nServiceTag : $ServiceTag`nWarranty Expired : $WarrantyExpired`nWarranty Start Date : $WarrantyStartDate`nSupport Level : $WarrantySupportLevel"
        $MessageTitle = "Information"
        $Result = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)
    }

    if ($Today -ge $CompareWarrantyEndDate) {
        $ButtonType = [System.Windows.MessageBoxButton]::Ok
        $MessageIcon = [System.Windows.MessageBoxImage]::Warning
        $MessageBody = "$env:computername n'est plus sous garantie !`nFin de garantie le $WarrantyEndDate`n`n[ Details ]`nModel : $Model`nServiceTag : $ServiceTag`nWarranty Expired : $WarrantyExpired`nWarranty Start Date : $WarrantyStartDate`nSupport Level : $WarrantySupportLevel"
        $MessageTitle = "Attention"
        $Result = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)  
    }
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