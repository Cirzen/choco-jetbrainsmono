function Get-CurrentDirectory
{
  $thisName = $MyInvocation.MyCommand.Name
  [IO.Path]::GetDirectoryName((Get-Content function:$thisName).File)
}

$ExitCode = 0
$PackageName = "JetBrainsMono"

$FontUrl = 'https://github.com/JetBrains/JetBrainsMono/releases/download/v2.001/JetBrains.Mono.2.001.zip'
$ChecksumType = 'sha256';
$Checksum = 'D9176856E982CA16F4EE24A1021A62B51CEA43575F3C6AA1910D4CDF6B695ADE';

$TempInstallPath = Join-Path $Env:Temp $PackageName

Install-ChocolateyZipPackage -PackageName $PackageName -url $FontUrl -unzipLocation $TempInstallPath -ChecksumType $ChecksumType -Checksum $Checksum

$FontFiles = Get-ChildItem $TempInstallPath -Recurse -Filter *.ttf -File
$FontCount = @($FontFiles).Count

$SuccessCount = Install-ChocolateyFont -Paths @($FontFiles.FullName) -Multiple
if ($SuccessCount -ne $FontCount)
{
  Write-Error ("Failed installing all fonts: {0} Success / {1} Total" -f $SuccessCount, $FontCount)
  $ExitCode = 1
}

Remove-Item $tempInstallPath -Recurse

exit $ExitCode