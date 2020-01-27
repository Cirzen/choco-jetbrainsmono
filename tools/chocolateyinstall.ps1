function Get-CurrentDirectory
{
  $thisName = $MyInvocation.MyCommand.Name
  [IO.Path]::GetDirectoryName((Get-Content function:$thisName).File)
}

$fontHelpersPath = (Join-Path (Get-CurrentDirectory) 'FontHelpers.ps1')
. $fontHelpersPath
$packageName = "JetBrainsMono"

$fontUrl = 'https://download.jetbrains.com/fonts/JetBrainsMono-1.0.0.zip'
$checksumType = 'sha256';
$checksum = '82BF0DEC956E4CA9AFA4DA4978FA5DE80A75A576B3353D570CCBAABE4E858389';

$tempInstallPath = Join-Path $Env:Temp $packageName

Install-ChocolateyZipPackage -PackageName $packageName -url $fontUrl -unzipLocation $tempInstallPath -ChecksumType $checksumType -Checksum $checksum

$shell = New-Object -ComObject Shell.Application
$fontsFolder = $shell.Namespace(0x14)

$fontFiles = Get-ChildItem $tempInstallPath -Recurse -Filter *.ttf

# unfortunately the font install process totally ignores shell flags :(
# http://social.technet.microsoft.com/Forums/en-IE/winserverpowershell/thread/fcc98ba5-6ce4-466b-a927-bb2cc3851b59
# so resort to a nasty hack of compiling some C#, and running as admin instead of just using CopyHere(file, options)
$commands = $fontFiles |
% { Join-Path $fontsFolder.Self.Path $_.Name } |
? { Test-Path $_ } |
% { "Remove-SingleFont '$_' -Force;" }

# http://blogs.technet.com/b/deploymentguys/archive/2010/12/04/adding-and-removing-fonts-with-windows-powershell.aspx
$fontFiles |
% { $commands += "Add-SingleFont '$($_.FullName)';" }

$toExecute = ". $fontHelpersPath;" + ($commands -join ';')
Start-ChocolateyProcessAsAdmin $toExecute

Remove-Item $tempInstallPath -Recurse
