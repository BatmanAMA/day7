$ErrorActionPreference="Stop"
class performer {
    performer([String]$String)
    {
        $this.Name = $String -Replace '^(\S*).*','$1'
        $this.Weight = ($string -Replace $this.Name,'' -replace '-.*$','' -replace '[\(\)]','').Trim()
        try {
            $this.Children = ($String -Split ' -> ')[1].Split(',').Trim()
        }
        catch {
            #sure, no children
        }
        Add-Member -InputObject $this -MemberType ScriptProperty -Name TotalWeight -Value { $this.CalculateWeight() }
    }
    [string]$Name
    [Int]$Weight
    [String[]]$Children
    [performer]$Parent
    [performer[]]$oChildren
    [int]CalculateWeight()
    {
        $total = $this.Weight
        foreach ($child in $this.oChildren)
        {
            $total += $child.CalculateWeight()
        }
        return $total
    }
}
$in = Get-Content .\Example.txt

$Stack = New-Object "System.Collections.Generic.Dictionary[string,performer]"($in.Count)

foreach ($line in $in)
{
    $p = New-Object performer($line)
    $Stack.Add($p.Name,$p)
}
$stack.Values | 
Where {$_.Children.Count -gt 0 } | 
foreach  {
    $p = $_
    $p.Children | ForEach-Object {
        $Stack[$_].Parent = $p
        $p.oChildren += $Stack[$_]
    }
}
$top = $Stack.Values.Where({$_.Parent -eq $Null})[0]
$top.Name

$badguy = $top
while (($badguy.oChildren | select TotalWeight -Unique).Count -gt 1)
{
    $badguy = $badguy.oChildren | 
        group TotalWeight | 
        Where Count -eq 1 | 
        select -ExpandProperty Group -First 1
}
$goalWeight = $badGuy.Parent.oChildren | where name -ne $badGuy.name | select -ExpandProperty TotalWeight -First 1
($goalWeight - $badGuy.TotalWeight) + $badguy.weight