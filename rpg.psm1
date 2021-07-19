#region Script Files import
$Scriptfiles = Get-ChildItem -Recurse "$PSScriptRoot\ScriptFiles" -Include *.ps1 

# dot source the individual scripts that make-up this module
foreach ($Scriptfile in $Scriptfiles) { . $Scriptfile.FullName }
#endregion

#region
#Setup which campaign you're in.  You'll have to change these for your personal setup. Also update money.ps1 if things don't work correctly.
$global:Files = new-object -TypeName PSCustomObject
write-host "Choose the Index of the campaign`n1: Partharia (Elric)`n2: Roman Ragnarok (Marcus Flaminius Cincinatus)`n3: Partheria (Gaelei Mahannen)"
[int]$Index = Read-Host "Index?"
$CampaignRoot = "$env:OneDriveConsumer\RPGs\Campaigns"
switch ($index)
    {
        1
        { 
            $Files | add-member -Name "PC" -Value "$CampaignRoot\Partheria\Money\PC.txt" -MemberType NoteProperty
            $Files | add-member -Name "PCBank" -value "$CampaignRoot\Partheria\Money\PCBank.txt" -MemberType NoteProperty
            $Files | add-member -Name "PartyFund" -value "$CampaignRoot\Partheria\Money\PartyFund.txt" -MemberType NoteProperty
            $Files | add-member -Name "Tax" -Value "$CampaignRoot\Partheria\Money\Tax.txt" -MemberType NoteProperty
        }
        2
        {
            $Files | add-member -Name "PC" -Value "$CampaignRoot\Roman Ragnarok\Money\PC.txt" -MemberType NoteProperty
            $Files | add-member -Name "PCBank" -value "$CampaignRoot\Roman Ragnarok\Money\PCBank.txt" -MemberType NoteProperty
            $Files | add-member -Name "PartyFund" -value "$CampaignRoot\Roman Ragnarok\Money\PartyFund.txt" -MemberType NoteProperty
            $Files | add-member -Name "Tax" -Value "$CampaignRoot\Roman Ragnarok\Money\Tax.txt" -MemberType NoteProperty
        }
        3
        { 
            $Files | add-member -Name "PC" -Value "$CampaignRoot\Partheria2\Money\PC.txt" -MemberType NoteProperty
            $Files | add-member -Name "PCBank" -value "$CampaignRoot\Partheria2\Money\PCBank.txt" -MemberType NoteProperty
            $Files | add-member -Name "PartyFund" -value "$CampaignRoot\Partheria2\Money\PartyFund.txt" -MemberType NoteProperty
            $Files | add-member -Name "Tax" -Value "$CampaignRoot\Partheria2\Money\Tax.txt" -MemberType NoteProperty
        }
    }
if ($null -ne $files.PC)
    {
        write-host -ForegroundColor Green -Object "RPG Module Initialized Successully"
    }
    else 
    {
        write-host -ForegroundColor Red -Object 'RPG Module initialization failed.  Run "$Files = Select-RPGCampaign"'
    }
#endregion