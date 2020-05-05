# Created by Loic LEFORESTIER

function Get-Warranty
    {
        Get-ItemProperty -Path HKLM:\SOFTWARE\DELL\WARRANTY | Select-Object Model,ServiceTag,WarrantyStartDate,WarrantyEndDate,WarrantySupportLevel
    }