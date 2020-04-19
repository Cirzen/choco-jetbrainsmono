function Get-CurrentDirectory
{
  $thisName = $MyInvocation.MyCommand.Name
  [IO.Path]::GetDirectoryName((Get-Content function:$thisName).File)
}

$ExitCode = 0
$PackageName = "JetBrainsMono"

$FontUrl = 'https://github.com/JetBrains/JetBrainsMono/releases/download/v1.0.4/JetBrainsMono-1.0.4.zip'
$ChecksumType = 'sha256';
$Checksum = '737ACC16715DBF911E833DD80FA27C49B2264C11800B0202F91B8745AFA34A04';

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