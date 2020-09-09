$mykey = "YOUR API KEY"
$mysymbol = "GGM"

$request = iwr "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=$($mysymbol)&apikey=$($mykey)&datatype=csv&outputsize=full" -OutFile data.csv
$file = Import-Csv .\data.csv

$price1 = 1..1000 | ForEach-Object {
    $file | Get-Random
} | select @{N=’time1’; E={$_.timestamp}}, @{N=’price1’; E={$_.open}}


$price2 = 1..1000 | ForEach-Object {
    $file | Get-Random
} | select @{N=’time2’; E={$_.timestamp}}, @{N=’price2’; E={$_.high}}
a
$combine = $price1 | ForEach-Object -Begin {$i = 0} {  
    $_ | Add-Member NoteProperty -Name 'time2' -Value $price2[$i].time2 -PassThru | 
         Add-Member NoteProperty -Name 'price2' -Value $price2[$i].price2 -PassThru
    $i++
}

$combine | select time1, time2, price1, price2, 
@{N=’Mon_diff’; E={ [math]::Abs([math]::Round(((NEW-TIMESPAN –Start $_.time1 –End $_.time2).Days)/30 ))}},
@{N=’Dividend’; E={ [math]::Abs([math]::Round(((NEW-TIMESPAN –Start $_.time1 –End $_.time2).Days)/30 ))*0.1813}},
@{N=’P/L’; E={ 
if ($_.time1 -gt $_.time2) {[math]::Round(($_.price1 - $_.price2),2)}
else {[math]::Round(($_.price2 - $_.price1),2)}
}} | ft
