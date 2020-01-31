function Get-CurrentDirectory
{
  $thisName = $MyInvocation.MyCommand.Name
  [IO.Path]::GetDirectoryName((Get-Content function:$thisName).File)
}

$ExitCode = 0
$PackageName = "JetBrainsMono"

$FontUrl = 'https://download.jetbrains.com/fonts/JetBrainsMono-1.0.2.zip'
$ChecksumType = 'sha256';
$Checksum = '59F9B9762D5625EB438EEDF034DBBCDCF09ED18DED994540B466872840229762';

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