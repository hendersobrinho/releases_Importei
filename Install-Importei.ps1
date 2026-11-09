$ErrorActionPreference = 'Stop'
$repository = 'hendersobrinho/releases_Importei'
$headers = @{ 'User-Agent' = 'Importei-Installer'; 'Accept' = 'application/vnd.github+json' }
$release = Invoke-RestMethod "https://api.github.com/repos/$repository/releases/latest" -Headers $headers
$package = $release.assets | Where-Object name -EQ 'Importei-win-x64.zip' | Select-Object -First 1
$checksum = $release.assets | Where-Object name -EQ 'Importei-win-x64.zip.sha256' | Select-Object -First 1
if (-not $package) { throw 'A última release não contém Importei-win-x64.zip.' }

$temporary = Join-Path ([System.IO.Path]::GetTempPath()) ('Importei-' + [guid]::NewGuid())
$zip = Join-Path $temporary 'Importei-win-x64.zip'
$expanded = Join-Path $temporary 'app'
New-Item -ItemType Directory -Path $temporary | Out-Null
try {
    Invoke-WebRequest $package.browser_download_url -OutFile $zip -Headers $headers
    $expected = if ($package.digest -and $package.digest.StartsWith('sha256:')) {
        $package.digest.Substring(7)
    } elseif ($checksum) {
        ((Invoke-WebRequest $checksum.browser_download_url -Headers $headers).Content -split '\s+')[0]
    } else {
        throw 'A release não possui SHA-256 para validação.'
    }
    $actual = (Get-FileHash $zip -Algorithm SHA256).Hash
    if ($actual -ne $expected) { throw 'O pacote baixado não passou na conferência SHA-256.' }
    Expand-Archive $zip -DestinationPath $expanded -Force
    if (-not (Test-Path (Join-Path $expanded 'Importei.exe'))) { throw 'Pacote incompleto.' }

    $target = Join-Path $env:LOCALAPPDATA 'Programs\Importei'
    $running = Get-Process Importei -ErrorAction SilentlyContinue | Where-Object { $_.Path -and $_.Path.StartsWith($target, [System.StringComparison]::OrdinalIgnoreCase) }
    if ($running) { throw 'Feche o Importei antes de instalar.' }
    New-Item -ItemType Directory -Path $target -Force | Out-Null
    Copy-Item -Path (Join-Path $expanded '*') -Destination $target -Recurse -Force

    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut((Join-Path ([Environment]::GetFolderPath('Desktop')) 'Importei.lnk'))
    $shortcut.TargetPath = Join-Path $target 'Importei.exe'
    $shortcut.WorkingDirectory = $target
    $shortcut.IconLocation = Join-Path $target 'Importei.exe'
    $shortcut.Save()
    Start-Process (Join-Path $target 'Importei.exe')
} finally {
    if (Test-Path $temporary) { Remove-Item -LiteralPath $temporary -Recurse -Force }
}
