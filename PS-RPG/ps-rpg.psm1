#region Script Files import
$Scriptfiles = Get-ChildItem -Recurse "$PSScriptRoot\ScriptFiles" -Include *.ps1 

# dot source the individual scripts that make-up this module
foreach ($Scriptfile in $Scriptfiles) { . $Scriptfile.FullName }
#endregion

#region
#Setup which campaign you're in.  You'll have to change these for your personal setup. Also update money.ps1 if things don't work correctly.
$global:Files = new-object -TypeName PSCustomObject
$global:CampaignRoot = "$env:OneDriveConsumer\RPGs\Campaigns"

write-host "Choose the Index of the campaign`n1: Partharia (Elric)`n2: Roman Ragnarok (Marcus Flaminius Cincinatus)`n3: Partheria (Gaelei Mahannen)"
[int]$Index = Read-Host "Index?"
switch ($index)
    {
        1
        { 
            $files | add-member -Name "Base" -value "$CampaignRoot\Partheria\PS-RPG" -MemberType NoteProperty
            $Files | add-member -Name "PC" -Value "$($files.Base)\PC.txt" -MemberType NoteProperty
            $Files | add-member -Name "PCBank" -value "$($files.Base)\PCBank.txt" -MemberType NoteProperty
            $Files | add-member -Name "PartyFund" -value "$($files.Base)\PartyFund.txt" -MemberType NoteProperty
            $Files | add-member -Name "Tax" -Value "$($files.Base)\Tax.txt" -MemberType NoteProperty
            $Files | Add-Member -name "InventoryFileList" -value "$($files.base)\InventoryFileList.txt" -MemberType NoteProperty 
        }
        2
        {
            $files | add-member -Name "Base" -value "$CampaignRoot\Roman Ragnarok\PS-RPG" -Membertype NoteProperty
            $Files | add-member -Name "PC" -Value "$($files.Base)\PC.txt" -MemberType NoteProperty
            $Files | add-member -Name "PCBank" -value "$($files.Base)\PCBank.txt" -MemberType NoteProperty
            $Files | add-member -Name "PartyFund" -value "$($files.Base)\PartyFund.txt" -MemberType NoteProperty
            $Files | add-member -Name "Tax" -Value "$($files.Base)\Tax.txt" -MemberType NoteProperty
            $Files | Add-Member -name "InventoryFileList" -value "$($files.base)\InventoryFileList.txt" -MemberType NoteProperty
        }
        3
        { 
            $Files | add-member -Name "Base" -Value "$CampaignRoot\Partheria2\PS-RPG" -Membertype NoteProperty
            $Files | add-member -Name "PC" -Value "$($files.Base)\PC.txt" -MemberType NoteProperty
            $Files | add-member -Name "PCBank" -value "$($files.Base)\PCBank.txt" -MemberType NoteProperty
            $Files | add-member -Name "PartyFund" -value "$($files.Base)\PartyFund.txt" -MemberType NoteProperty
            $Files | add-member -Name "Tax" -Value "$($files.Base)\Tax.txt" -MemberType NoteProperty
            $Files | Add-Member -name "InventoryFileList" -value "$($files.base)\InventoryFileList.txt" -MemberType NoteProperty
        }
    }

if ($null -ne $files.PC)
    {
        write-host -ForegroundColor Green -Object "PS-RPG Module Initialized Successully."
    }
    else 
    {
        write-host -ForegroundColor Red -Object "PS-RPG Module failed to Initialize Successfully."        
    }
#endregion