Function New-Bag
{
    [cmdletbinding()]
    param(
        [parameter(Position=0, ValueFromPipeline=$true, Mandatory=$true)][string]$Name,
        [parameter(Position=1)][int]$CharacterCoins = 0, #should the character's coins be included?
        [parameter(Position=2)][int]$PartyCoins = 0, #Should the party coins be included?
        [parameter(position=3)][int]$MaxWeight = 0,
        [parameter(position=4)][string]$FileLocation = "$($Files.base)\$name.txt"
    )

    #region Create the empty bag file and update the file location list
    $header = "$Name,$CharacterCoins,$PartyCoins,$MaxWeight"
    Out-File -FilePath $FileLocation -InputObject $Header -NoClobber
    Out-File -FilePath $Files.InventoryFileList -InputObject $header -Append
    #endregion
}

Function Get-BagContents
{
    
}