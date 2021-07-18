Function Select-RPGCampaign
{
    [cmdletbinding()]
    param()

    

    Write-Output "Choose the Index of the campaign`n1: Partharia (Elric)`n2: Roman Ragnarok (Marcus Flaminius Cincinatus)`n3: Partheria (Gaelei Mahannen)"
    [int]$Index = Read-Host "Index?"

    switch ($index)
    {
        1
        {
            $Files = New-Object -TypeName psobject 
            $Files | add-member -Name "PC" -Value "$env:OneDriveConsumer\RPGs\Campaigns\Partheria\Money\PC.txt" -MemberType NoteProperty
            $Files | add-member -Name "PCBank" -value "$env:OneDriveConsumer\RPGs\Campaigns\Partheria\Money\PCBank.txt" -MemberType NoteProperty
            $Files | add-member -Name "PartyFund" -value "$env:OneDriveConsumer\RPGs\Campaigns\Partheria\Money\PartyFund.txt" -MemberType NoteProperty
            $Files | add-member -Name "Tax" -Value "$env:OneDriveConsumer\RPGs\Campaigns\Partheria\Money\Tax.txt" -MemberType NoteProperty
        }
        2
        {
            $Files = New-Object -TypeName psobject 
            $Files | add-member -Name "PC" -Value "E:\OneDrive\OneDrive\RPGs\Campaigns\Roman Ragnarok\Money\PC.txt" -MemberType NoteProperty
            $Files | add-member -Name "PCBank" -value "E:\OneDrive\OneDrive\RPGs\Campaigns\Roman Ragnarok\Money\PCBank.txt" -MemberType NoteProperty
            $Files | add-member -Name "PartyFund" -value "E:\OneDrive\OneDrive\RPGs\Campaigns\Roman Ragnarok\Money\PartyFund.txt" -MemberType NoteProperty
            $Files | add-member -Name "Tax" -Value "E:\OneDrive\OneDrive\RPGs\Campaigns\Roman Ragnarok\Money\Tax.txt" -MemberType NoteProperty
        }
        3
        {
            $Files = New-Object -TypeName psobject 
            $Files | add-member -Name "PC" -Value "E:\OneDrive\OneDrive\RPGs\Campaigns\Partheria2\Money\PC.txt" -MemberType NoteProperty
            $Files | add-member -Name "PCBank" -value "E:\OneDrive\OneDrive\RPGs\Campaigns\Partheria2\Money\PCBank.txt" -MemberType NoteProperty
            $Files | add-member -Name "PartyFund" -value "E:\OneDrive\OneDrive\RPGs\Campaigns\Partheria2\Money\PartyFund.txt" -MemberType NoteProperty
            $Files | add-member -Name "Tax" -Value "E:\OneDrive\OneDrive\RPGs\Campaigns\Partheria2\Money\Tax.txt" -MemberType NoteProperty
        }
    }

    $Files
}

function Invoke-RPGCalculateShare
{
    <#
    .SYNOPSIS
    Calculates the individual and group fund portion of coins found/received.
    .DESCRIPTION
    This takes either a pre-formatted Powershell Object with the reqiured data or each individual type of coin, the number to split it by, the party fund share factor, and the tax rate.
    It then calculates the share for each person and the party fund, with any indivisible money (copper pieces) going to the party fund.
    .EXAMPLE
    Caclulate-Share 15 14 13 18
    This uses the positional parameters for PP, GP, SP, CP, using the default party members, Party Fund share, and tax rate

    .EXAMPLE
    Calculate-Share -PPin 15 -GPin 14 -SPin 13 -PartyMembersIn 4 -PartyFundShareIn 2 -TaxRateIn 0.1
    This specifies more data.  It changes the Party Member count, and the portion the Party Fund gets.  
    
    .EXAMPLE
    $Purse | Calculate-Share
    This passes in a psObject to Calculate-Share
    #>
   
    [cmdletbinding()]
    param([parameter(ParameterSetName='Manual',Position=0)][int]$PPin = 0,
          [parameter(ParameterSetName='Manual',Position=1)][int]$GPin = 0,
          [parameter(ParameterSetName='Manual',Position=2)][int]$SPin = 0,
          [parameter(ParameterSetName='Manual',Position=3)][int]$CPin = 0,
          [parameter(ParameterSetName='Manual')][int]$PartyMembersIn = 4,
          [parameter(ParameterSetName='Manual')][int]$PartyFundShareIn = 1,
          [parameter(ParameterSetName='Manual')][decimal]$TaxRateIn = 0.0,
          [parameter(ParameterSetName='Function',valuefrompipeline=$true)]$PSObjectIn
          )
          
    #region determine if data is a psobject or individual
    if ($PSObjectIn)
    {
        $pp = $PSObjectIn.PP
        $gp = $PSObjectIn.GP
        $sp = $PSObjectIn.SP
        $CP = $PSObjectIn.CP
        $PartyMembers = $PSObjectIn.PartyMembers
        $PartyFundShare = $PSObjectIn.PartyFundShare
        $TaxRate = $PSObjectIn.TaxRate 
        $Shares = $PartyMembers + $PartyFundShare
    }
    else
    {
        $pp = $ppin
        $gp = $gpin
        $sp = $spin
        $cp = $cpin
        $PartyMembers = $PartyMembersin
        $PartyFundShare = $PartyFundShareIn
        $TaxRate = $TaxRateIn
        $shares = $partyMembers + $PartyFundShare
    }
    #endregion
    
    #region create object and put original purse values in
    $Purse = New-Object -TypeName psobject
    $Purse | Add-Member -MemberType NoteProperty -name TotalPP -Value $pp
    $Purse | Add-Member -MemberType NoteProperty -name TotalGP -Value $gp
    $Purse | Add-Member -MemberType NoteProperty -name TotalSP -Value $sp
    $Purse | Add-Member -MemberType NoteProperty -name TotalCP -Value $cp
    $purse | Add-Member -MemberType NoteProperty -name Shares -Value $shares
    #endregion

    #region Determine Tax due and add to the object
    #figure tax for each.
    $taxpp = $($purse.Totalpp) * $TAXRATE
    $taxgp = $($purse.Totalgp) * $TAXRATE
    $taxsp = $($purse.Totalsp) * $TAXRATE
    $taxcp = $($purse.Totalcp) * $TAXRATE
   
    #Find out how much is left after taxes.
    #PP Tax breakdown name is platinum pieces paid for taxpp, gold pieces paid for taxpp
    $pptaxpp = [int]([math]::truncate($taxpp))
    $gptaxpp = [int]([math]::truncate((($taxpp % 1) * 10)))
    $sptaxpp = [int]([math]::truncate((($taxpp % 1) * 100) - ($gptaxpp*10)))
    $cptaxpp = [int]([math]::truncate((($taxpp % 1) * 1000) - ($gptaxpp * 100) - ($sptaxpp *10)))

    #gp tax breakdown
    $gptaxgp = [int]([math]::truncate($taxgp))
    $sptaxgp = [int]([math]::truncate((($taxgp % 1)*10)))
    $cptaxgp = [int]([math]::truncate((($taxgp % 1)*100) - ($sptaxgp*10)))
        
    #sp tax breakdown
    $sptaxsp = [int]([math]::Truncate($taxsp)) 
    $cptaxsp = [int]([math]::truncate((($taxsp % 1)*10)))

    #cp tax (round to nearest using bankers rounding)
    $cptaxcp = [int]$taxcp

    $totalPPTax = $pptaxpp
    $totalGPTax = $gptaxpp + $gptaxgp
    $totalSPTax = $sptaxpp + $sptaxgp + $sptaxsp
    $totalCPTax = $cptaxpp + $cptaxgp + $cpTaxsp + $cptaxcp
    

    #Add tax
    $purse | Add-Member -MemberType NoteProperty -Name PPTax -Value $totalPPTax
    $purse | Add-Member -MemberType NoteProperty -Name GPTax -Value $totalGPTax
    $purse | Add-Member -MemberType NoteProperty -Name SPTax -Value $totalSPTax
    $purse | Add-Member -MemberType NoteProperty -name CPTax -Value $totalCPTax
    #endregion

    #region determine net money and add to object
    if ($gp-$totalGPTax -lt 0)
    {
        $pp--
        $gp += 10
    }

    if ($sp-$totalSPTax -lt 0)
    {
        $gp--
        $sp += 10
    }

    if ($cp-$totalCPTax -lt 0)
    {
        $sp--
        $cp += 10
    }

    #apply net money
    $purse | Add-Member -MemberType NoteProperty -Name NetPP -Value ($pp - $totalPPTax)
    $purse | Add-Member -MemberType NoteProperty -Name NetGP -value ($gp - $totalGPTax)
    $purse | Add-Member -MemberType NoteProperty -name NetSP -Value ($sp - $totalSPTax)
    $purse | Add-Member -MemberType NoteProperty -Name NetCP -Value ($cp - $totalCPTax)
    #endregion 

    #Region find each share - uneven portions go to party fund
    #platinum
    $ppsharepp = [int][math]::Truncate($($purse.netpp) / $($Purse.shares))
    $extraPP = ($($Purse.netpp) - ($ppsharepp * $($purse.shares)))
    
    $GPToSplit = $($purse.netgp) + ($extraPP *10)
    $gpsharegp = [int][math]::Truncate($gptosplit / $($Purse.shares))
    $extraGP = ($GPToSplit - ($gpsharegp * $($purse.shares)))

    $SPToSplit = $($purse.netsp) + ($extraGP * 10)
    $spsharesp = [int][math]::Truncate($SPToSplit / $($Purse.Shares))
    $ExtraSP = ($SPToSplit - ($spsharesp * $($purse.shares)))
    
    $CPToSplit = $($purse.netcp) + ($extraSP*10)
    $cpsharecp = [int][math]::Truncate($CPToSplit / $($Purse.Shares))
    $ExtraCP = ($CPToSplit - ($cpsharecp * $($purse.shares)))
    
    $PartyCPShare = $cpsharecp + $extracp
        
    $purse | Add-Member -MemberType NoteProperty -Name NetSharePP -Value $ppsharepp
    $purse | Add-Member -MemberType NoteProperty -name NetShareGP -value $gpsharegp
    $purse | Add-Member -MemberType NoteProperty -Name NetShareSP -Value $spsharesp
    $purse | Add-Member -MemberType NoteProperty -Name NetShareCP -Value $cpsharecp
    $purse | Add-Member -MemberType NoteProperty -Name PartyShareCP -value $PartyCPShare
    $purse | Add-Member -MemberType NoteProperty -Name PartyShareNum -value $PartyFundShareIn
    #endregion

    #region output
    $purse
    #endregion
}

function Request-RPGMoney
{
    #region Collect Information
    write-host -Object "How many Platinum Pieces?" -ForegroundColor Black -BackgroundColor white
    [int]$pp = read-host 
    Write-Host -Object "How many Gold Pieces?" -ForegroundColor Black -BackgroundColor Yellow
    [int]$gp = read-host
    write-host -object "How many Silver Pieces?" -ForegroundColor black -BackgroundColor Gray
    [int]$sp = Read-Host
    Write-host -Object "How many Copper Pieces?" -ForegroundColor Black -BackgroundColor DarkYellow
    [int]$cp = Read-Host
    write-host -Object "How many players? Do not include the party fund."
    [int]$PartyMembers = Read-Host
    write-host -Object "How many shares does the party fund get?"
    [int]$PartyFundShare = Read-Host
    write-host -object "What is the tax rate, in decimal?"
    [decimal]$TaxRate = Read-Host
    #endregion

    #region Create object
    $Money = New-Object -TypeName psobject
    $Money | Add-Member -MemberType NoteProperty -Name PP -Value $pp
    $Money | Add-Member -MemberType NoteProperty -Name GP -Value $gp
    $Money | Add-Member -MemberType NoteProperty -Name SP -Value $sp
    $Money | Add-Member -MemberType NoteProperty -Name CP -Value $cp
    $Money | Add-Member -MemberType NoteProperty -Name PartyMembers -Value $PartyMembers
    $Money | Add-Member -MemberType NoteProperty -Name PartyFundShare -Value $PartyFundShare
    $Money | Add-Member -MemberType NoteProperty -Name TaxRate -Value $TaxRate
    #endregion

    #region Output
    $Money
    #endregion
}

function Show-RPGShare
{
    [cmdletbinding()]
    param([parameter(Mandatory=$true,ValueFromPipeline=$true)]$purse)

    Write-Host -Object "`r`nTax Paid"
    Write-Host -Object "Platinum:`t$($purse.pptax)" -ForegroundColor Black -BackgroundColor White
    Write-host -Object "Gold:`t`t$($Purse.gptax)" -ForegroundColor black -BackgroundColor Yellow
    write-host -Object "Silver:`t`t$($Purse.SPTax)" -ForegroundColor Black -BackgroundColor Gray
    write-host -object "Copper:`t`t$($Purse.cptax)" -ForegroundColor Black -BackgroundColor DarkYellow
    write-host -Object "`r`nPlayer Shares"
    Write-Host -Object "Platinum:`t$($purse.Netsharepp)" -ForegroundColor Black -BackgroundColor White
    Write-host -Object "Gold:`t`t$($Purse.netsharegp)" -ForegroundColor black -BackgroundColor Yellow
    write-host -Object "Silver:`t`t$($Purse.netsharesp)" -ForegroundColor Black -BackgroundColor Gray
    write-host -object "Copper:`t`t$($Purse.netsharecp)" -ForegroundColor Black -BackgroundColor DarkYellow
    if ($purse.PartyShareNum -ne 0)
    {
        write-host -Object "`r`nParty Fund"
        Write-Host -Object "Platinum:`t$($purse.Netsharepp)" -ForegroundColor Black -BackgroundColor White
        Write-host -Object "Gold:`t`t$($Purse.netsharegp)" -ForegroundColor black -BackgroundColor Yellow
        write-host -Object "Silver:`t`t$($Purse.netsharesp)" -ForegroundColor Black -BackgroundColor Gray
        write-host -object "Copper:`t`t$($Purse.Partysharecp)" -ForegroundColor Black -BackgroundColor DarkYellow
    }
    if (($purse.PartyShareNum -eq 0) -and ($Purse.PartySharecp -ne $Purse.netsharecp))
    {
        $PartyShare = $purse.PartyShareCP - $Purse.NetshareCP
        write-host -Object "The money didn't split evenly.  Add this back to the party fund"
        Write-host -Object "Copper: `t$PartyShare" -ForegroundColor Black -BackgroundColor DarkYellow
    }
}

Function Split-RPGMoney
{
   #this lets me call all three steps from one command.
   Request-RPGMoney | Invoke-RPGCalculateShare | Show-RPGshare
}

Function Format-RPGBalance
{
    [cmdletbinding()]
    param([parameter(mandatory=$true)]$InputString)
   
   
    $parts = $InputString -split ","
    $OutputObject = New-Object -TypeName psobject
    $outputObject | Add-Member -MemberType NoteProperty -name PP -Value $parts[0]
    $outputObject | Add-Member -MemberType NoteProperty -name GP -Value $parts[1]
    $outputObject | Add-Member -MemberType NoteProperty -name SP -Value $parts[2]
    $outputObject | Add-Member -MemberType NoteProperty -name CP -Value $parts[3]
    $outputObject | Add-Member -MemberType NoteProperty -name Notes -Value $parts[4]

    $outputObject
}

Function Show-RPGPurse
{
    [cmdletbinding()]
    param([parameter(Mandatory=$true,ValueFromPipeline=$true)]$purse)
    
    Write-Host -Object "Platinum:`t$($purse.pp)" -ForegroundColor Black -BackgroundColor White
    Write-host -Object "Gold:`t`t$($Purse.gp)" -ForegroundColor black -BackgroundColor Yellow
    write-host -Object "Silver:`t`t$($Purse.SP)" -ForegroundColor Black -BackgroundColor Gray
    write-host -object "Copper:`t`t$($Purse.cp)" -ForegroundColor Black -BackgroundColor DarkYellow
    $Weight = [int]$($Purse.pp) + [int]$($Purse.gp) + [int]$($Purse.sp) + [int]$($Purse.cp)
    $weight = $weight/50
    Write-host -Object "Coin Weight:$Weight lbs" -ForegroundColor Black -BackgroundColor Green
}

Function Read-RPGBalanceProcess
{
    [cmdletbinding()]
    param([parameter(Mandatory=$true)][string]$fileLocation)

    $Purse = Get-Content -Path $fileLocation -Tail 1
    $Balance = Format-RPGBalance -InputString $purse
    $Money = New-Object -TypeName PSObject
    $Money | Add-Member -MemberType NoteProperty -Name PP -Value $Balance.pp
    $Money | Add-Member -MemberType NoteProperty -Name GP -Value $Balance.gp
    $Money | Add-Member -MemberType NoteProperty -Name SP -Value $Balance.sp
    $Money | Add-Member -MemberType NoteProperty -Name CP -Value $Balance.cp
    
    $Money
}

Function Get-RPGBalance
{
    [cmdletbinding()]
    param([parameter(Mandatory=$true)][ValidateSet('PC','PCBank','PartyFund','Tax')][string]$BalanceName)

    #pick balance balances
    switch($BalanceName)
    {
        "PC" {$purse = Read-RPGBalanceProcess -fileLocation $files.pc}
        "PCBank" {$purse = Read-RPGBalanceProcess -fileLocation $Files.pcbank}
        "PartyFund" {$purse = Read-RPGBalanceProcess -fileLocation $files.partyfund}
        "Tax" {$purse = Read-RPGBalanceProcess -fileLocation $files.tax}
    }
    #show balance 
    Display-Purse -purse $purse
}

Function Write-RPGTransaction
{
    [cmdletbinding()]
    param([parameter(Mandatory=$true,ValueFromPipeline=$true)]$Transaction)
    
    #Get account file
     switch($transaction.account)
    {
        "PC" {$FilePath = $files.pc}
        "PCBank" {$FilePath = $Files.pcbank}
        "PartyFund" {$FilePath = $files.partyfund}
        "Tax" {$FilePath = $files.tax}
    }
    
    #get balance
    $Balance = Read-RPGBalanceProcess -fileLocation $filepath
        
    #add together
    [int]$NewBalancepp = [int]$Balance.pp + $Transaction.pp
    [int]$NewBalancegp = [int]$Balance.gp + $transaction.gp
    [int]$NewBalancesp = [int]$Balance.sp + $Transaction.sp
    [int]$NewBalancecp = [int]$Balance.cp + $Transaction.cp

    #write out
    Out-File -FilePath $filepath -Encoding ascii -append -force -InputObject "$($Transaction.pp),$($Transaction.gp),$($Transaction.sp),$($Transaction.cp),$($Transaction.note)`n$NewBalancepp,$NewBalancegp,$NewBalancesp,$NewBalancecp,Balance"

    #show new balance
    Get-RPGBalance -BalanceName "$($transaction.account)"
}

Function New-RPGTransaction
{
    #region Collect Information
    Write-Host -Object "A new transaction is being created.  Use negatives for withdrawls, and positive for deposits"
    Write-Host -Object "Which Account: PC, PCBank, PartyFund, Tax" -ForegroundColor Black -BackgroundColor Green
    [string]$Account = Read-Host
    Write-Host -Object "Note:"
    [string]$note = Read-Host
    write-host -Object "How many Platinum Pieces?" -ForegroundColor Black -BackgroundColor white
    [int]$pp = read-host 
    Write-Host -Object "How many Gold Pieces?" -ForegroundColor Black -BackgroundColor Yellow
    [int]$gp = read-host
    write-host -object "How many Silver Pieces?" -ForegroundColor black -BackgroundColor Gray
    [int]$sp = Read-Host
    Write-host -Object "How many Copper Pieces?" -ForegroundColor Black -BackgroundColor DarkYellow
    [int]$cp = Read-Host
    
   
    #endregion

    #region Create object
    $Money = New-Object -TypeName psobject
    $Money | Add-Member -MemberType NoteProperty -Name PP -Value $pp
    $Money | Add-Member -MemberType NoteProperty -Name GP -Value $gp
    $Money | Add-Member -MemberType NoteProperty -Name SP -Value $sp
    $Money | Add-Member -MemberType NoteProperty -Name CP -Value $cp
    $Money | Add-Member -MemberType NoteProperty -Name Account -Value $Account
    $Money | Add-Member -MemberType NoteProperty -Name Note -Value $note

    Write-RPGTransaction -Transaction $money
    
}

Function New-RPGTransfer
{
    [cmdletbinding()]
    param()
    Write-Host -Object "A new transfer is being created.  Use Positive Numbers"
    Write-Host -Object "From Which Account: PC, PCBank, PartyFund, Tax" -ForegroundColor Black -BackgroundColor Green
    [string]$FromAccount = Read-Host
    Write-Host -Object "To Which Account: PC, PCBank, PartyFund, Tax" -ForegroundColor Black -BackgroundColor Green
    [string]$ToAccount = Read-Host
    Write-Host -Object "Note:"
    [string]$note = Read-Host
    write-host -Object "How many Platinum Pieces?" -ForegroundColor Black -BackgroundColor white
    [int]$pp = read-host 
    Write-Host -Object "How many Gold Pieces?" -ForegroundColor Black -BackgroundColor Yellow
    [int]$gp = read-host
    write-host -object "How many Silver Pieces?" -ForegroundColor black -BackgroundColor Gray
    [int]$sp = Read-Host
    Write-host -Object "How many Copper Pieces?" -ForegroundColor Black -BackgroundColor DarkYellow
    [int]$cp = Read-Host

    $FromMoney = New-Object -TypeName psobject
    $FromMoney | Add-Member -MemberType NoteProperty -Name PP -Value "-$pp"
    $FromMoney | Add-Member -MemberType NoteProperty -Name GP -Value "-$gp"
    $FromMoney | Add-Member -MemberType NoteProperty -Name SP -Value "-$sp"
    $FromMoney | Add-Member -MemberType NoteProperty -Name CP -Value "-$cp"
    $FromMoney | Add-Member -MemberType NoteProperty -Name Account -Value $FromAccount
    $FromMoney | Add-Member -MemberType NoteProperty -Name Note -Value $note
    
    $ToMoney = New-Object -TypeName psobject
    $ToMoney | Add-Member -MemberType NoteProperty -Name PP -Value $pp
    $ToMoney | Add-Member -MemberType NoteProperty -Name GP -Value $gp
    $ToMoney | Add-Member -MemberType NoteProperty -Name SP -Value $sp
    $ToMoney | Add-Member -MemberType NoteProperty -Name CP -Value $cp
    $ToMoney | Add-Member -MemberType NoteProperty -Name Account -Value $ToAccount
    $ToMoney | Add-Member -MemberType NoteProperty -Name Note -Value $note
    
    #display balances
    Write-host -Object "`nOld Balance of $FromAccount" -ForegroundColor Green -BackgroundColor Black
    Get-RPGBalance -BalanceName $FromAccount
    Write-host -Object "Old Balance of $ToAccount" -ForegroundColor Green -BackgroundColor Black
    Get-RPGBalance -BalanceName $ToAccount

    #subtract from From Account
    Write-host -Object "`nNew Balance of $FromAccount" -ForegroundColor Green -BackgroundColor Black
    Write-RPGTransaction -Transaction $Frommoney

    #add to To Account
    Write-host -Object "New Balance of $ToAccount" -ForegroundColor Green -BackgroundColor Black
    Write-RPGTransaction -Transaction $ToMoney



}

Function New-RPGReward
{
    [cmdletbinding()]
    param()
    #gather the inputs
    Write-Host -Object "Put the total reward in. This will add the amount to the PC account and the Party Fund account after separating it out"
    $notes = Read-Host -Prompt "Notes for ledger"
    $Shares = Request-RPGMoney | Invoke-RPGCalculateShare

    #write share for each
    $shares | Show-RPGShare
    
    
    #Get old balances
    Write-host -object "`nOldBalances"
    write-host -Object "Tax:" -ForegroundColor Green -BackgroundColor Black
    Get-RPGBalance -BalanceName "Tax"

    write-host -Object "Party Fund:" -ForegroundColor Green -BackgroundColor Black
    Get-RPGBalance -BalanceName "PartyFund"

    write-host -Object "PC:" -ForegroundColor Green -BackgroundColor Black
    Get-RPGBalance -BalanceName "PC"

   


    #write tax to tax file
    $Tax = New-Object -TypeName psobject
    $Tax | Add-Member -MemberType NoteProperty -Name pp -Value $shares.pptax
    $Tax | Add-Member -MemberType NoteProperty -Name gp -Value $shares.pptax
    $Tax | Add-Member -MemberType NoteProperty -Name sp -Value $shares.pptax
    $Tax | Add-Member -MemberType NoteProperty -Name cp -Value $shares.pptax
    $Tax | Add-Member -MemberType NoteProperty -Name Account -Value "Tax"
    $tax | Add-Member -MemberType NoteProperty -Name Note -value $notes
    
    write-host -Object "`nNew Balances"
    write-host -Object "Tax:" -ForegroundColor Green -BackgroundColor Black
    Write-RPGTransaction -Transaction $Tax

    #Write to Party Fund
    
    $PF = New-Object -TypeName psobject
    $PF | Add-Member -MemberType NoteProperty -Name pp -Value $shares.NetSharePP
    $PF | Add-Member -MemberType NoteProperty -Name gp -Value $shares.NetShareGP
    $PF | Add-Member -MemberType NoteProperty -Name sp -Value $shares.NetShareSP
    $PF | Add-Member -MemberType NoteProperty -Name cp -Value $shares.PartyShareCP
    $PF | Add-Member -MemberType NoteProperty -Name Account -Value "PartyFund"
    $PF | Add-Member -MemberType NoteProperty -Name Note -value $notes
    
    write-host -Object "Party Fund:" -ForegroundColor Green -BackgroundColor Black
    Write-RPGTransaction -Transaction $PF

    #write to PC
    $PC = New-Object -TypeName psobject
    $PC | Add-Member -MemberType NoteProperty -Name pp -Value $shares.NetSharePP
    $PC | Add-Member -MemberType NoteProperty -Name gp -Value $shares.NetShareGP
    $PC | Add-Member -MemberType NoteProperty -Name sp -Value $shares.NetShareSP
    $PC | Add-Member -MemberType NoteProperty -Name cp -Value $shares.NetShareCP
    $PC | Add-Member -MemberType NoteProperty -Name Account -Value "PC"
    $PC | Add-Member -MemberType NoteProperty -Name Note -value $notes
    write-host -Object "PC:" -ForegroundColor Green -BackgroundColor Black
    Write-RPGTransaction -Transaction $PC


}

Function Get-RPGAllBalances
{
    [cmdletbinding()]
    param()

    Write-host -Object "Balances"
    Write-host -Object "PC Balance" -ForegroundColor Green -BackgroundColor Black
    Read-RPGBalanceProcess -fileLocation $files.pc | show-RPGpurse

    Write-host -Object "PC Bank Balance" -ForegroundColor Green -BackgroundColor Black
    Read-RPGBalanceProcess -fileLocation $files.pcbank | show-RPGpurse

    Write-host -Object "Party Fund" -ForegroundColor Green -BackgroundColor Black
    Read-RPGBalanceProcess -fileLocation $files.PartyFund | show-RPGpurse

    Write-host -Object "Unpaid Tax" -ForegroundColor Green -BackgroundColor Black
    Read-RPGBalanceProcess -fileLocation $files.tax | show-RPGpurse
}

Function Get-RPGCoinWeight
{
    write-host -Object "How many Platinum Pieces?" -ForegroundColor Black -BackgroundColor white
    [int]$pp = read-host 
    Write-Host -Object "How many Gold Pieces?" -ForegroundColor Black -BackgroundColor Yellow
    [int]$gp = read-host
    write-host -object "How many Silver Pieces?" -ForegroundColor black -BackgroundColor Gray
    [int]$sp = Read-Host
    Write-host -Object "How many Copper Pieces?" -ForegroundColor Black -BackgroundColor DarkYellow
    [int]$cp = Read-Host
    
    $Weight = [int]$pp + [int]$gp + [int]$sp + [int]$cp
    $weight = $weight/50
    Write-host -Object "Coin Weight:$Weight lbs" -ForegroundColor Black -BackgroundColor Green
}