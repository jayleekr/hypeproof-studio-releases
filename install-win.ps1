# One-line installer for HypeProof Studio on Windows.
#
# Usage (PowerShell):
#   iwr -useb https://raw.githubusercontent.com/jayleekr/hypeproof-studio-releases/main/install-win.ps1 | iex

$ErrorActionPreference = "Stop"
$Repo = "jayleekr/hypeproof-studio-releases"
$AppName = "HypeProof Studio"
$Tag = if ($env:HPS_VERSION) { $env:HPS_VERSION } else { "latest" }
$Tmp = New-Item -ItemType Directory -Path (Join-Path $env:TEMP ("hps-" + [Guid]::NewGuid().ToString("N"))) -Force

function Say($msg) { Write-Host "`n> $msg" -ForegroundColor Magenta }
function Fail($msg) { Write-Host "ERROR: $msg" -ForegroundColor Red; exit 1 }
function Normalize-Sha256Digest($digest) {
    if (-not $digest) {
        Fail "Release asset is missing a SHA256 digest. Refusing to run an unsigned installer without integrity metadata."
    }

    $text = [string]$digest
    if ($text -notmatch "^sha256:([a-fA-F0-9]{64})$") {
        Fail "Release asset digest has unsupported format: $text"
    }

    return $Matches[1].ToLowerInvariant()
}

try {
    $api = if ($Tag -eq "latest") {
        "https://api.github.com/repos/$Repo/releases/latest"
    } else {
        "https://api.github.com/repos/$Repo/releases/tags/$Tag"
    }

    Say "Looking up release ($Tag)..."
    $release = Invoke-RestMethod -Uri $api -Headers @{ "User-Agent" = "hps-install" }

    $asset = $release.assets | Where-Object { $_.name -match "UserSetup.*x64.*\.exe$" } | Select-Object -First 1
    if (-not $asset) {
        $asset = $release.assets | Where-Object { $_.name -match "Setup.*x64.*\.exe$" } | Select-Object -First 1
    }
    if (-not $asset) {
        Fail "No Windows x64 installer .exe found in $Tag release. Visit https://github.com/$Repo/releases"
    }

    $expectedSha256 = Normalize-Sha256Digest $asset.digest
    $installer = Join-Path $Tmp.FullName $asset.name
    Say "Selected $($release.tag_name) / $($asset.name)"
    Write-Host "Expected SHA256: $expectedSha256"

    Say "Downloading $($asset.browser_download_url)"
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $installer -UseBasicParsing

    Say "Verifying SHA256..."
    $actualSha256 = (Get-FileHash -Algorithm SHA256 -Path $installer).Hash.ToLowerInvariant()
    if ($actualSha256 -ne $expectedSha256) {
        Fail "SHA256 mismatch for $($asset.name). Expected $expectedSha256 but got $actualSha256."
    }
    Write-Host "Verified SHA256: $actualSha256" -ForegroundColor Green

    Write-Host ""
    Write-Host "Windows SmartScreen may warn ('Windows protected your PC')." -ForegroundColor Yellow
    Write-Host "This is expected while the build is unsigned." -ForegroundColor Yellow
    Write-Host "Click 'More info' -> 'Run anyway' to proceed." -ForegroundColor Yellow
    Write-Host ""

    Say "Launching installer..."
    Start-Process -FilePath $installer -Wait

    Say "Done."
    Write-Host "`n$AppName installed." -ForegroundColor Green
    Write-Host "If something breaks, tell the workshop operator."
}
catch {
    Fail $_.Exception.Message
}
finally {
    if (Test-Path $Tmp) { Remove-Item -Recurse -Force $Tmp -ErrorAction SilentlyContinue }
}
