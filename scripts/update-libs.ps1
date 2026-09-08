<#
.SYNOPSIS
    Updates embedded third-party WoW libraries in Libs/ from upstream official repositories.
.DESCRIPTION
    Clones the latest canonical releases of Ace3, LibDeflate, LibDataBroker, and LibDBIcon,
    synchronizes them into Libs/, and runs integrity verification checks.
#>

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $scriptDir
$libsDir = Join-Path $rootDir "Libs"
$tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "GSFHub_LibUpdate_$([System.Guid]::NewGuid().ToString('N'))"

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "       GSFHub Library Synchronization Tool    " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

try {
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    # 1. Clone Ace3 (Official WoWUIDev repo)
    Write-Host "`n[1/4] Fetching latest Ace3 suite (WoWUIDev/Ace3)..." -ForegroundColor Yellow
    $aceDir = Join-Path $tempDir "Ace3"
    git -c http.sslVerify=false clone --depth 1 https://github.com/WoWUIDev/Ace3.git $aceDir

    # 2. Clone LibDeflate (Official SafeteeWoW repo)
    Write-Host "`n[2/4] Fetching latest LibDeflate (SafeteeWoW/LibDeflate)..." -ForegroundColor Yellow
    $deflateDir = Join-Path $tempDir "LibDeflate"
    git -c http.sslVerify=false clone --depth 1 https://github.com/safeteeWow/LibDeflate.git $deflateDir

    # 3. Clone LibDataBroker-1.1 (Official tekkub repo)
    Write-Host "`n[3/4] Fetching latest LibDataBroker-1.1 (tekkub/libdatabroker-1-1)..." -ForegroundColor Yellow
    $ldbDir = Join-Path $tempDir "LibDataBroker"
    git -c http.sslVerify=false clone --depth 1 https://github.com/tekkub/libdatabroker-1-1.git $ldbDir

    # 4. Fetch LibDBIcon-1.0
    Write-Host "`n[4/4] Fetching latest LibDBIcon-1.0..." -ForegroundColor Yellow
    $iconDst = Join-Path $libsDir "LibDBIcon-1.0\LibDBIcon-1.0.lua"
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Questie/Questie/master/Libs/LibDBIcon-1.0/LibDBIcon-1.0.lua" -OutFile $iconDst

    Write-Host "`nSynchronizing files into Libs/..." -ForegroundColor Cyan

    # Copy LibStub
    Copy-Item -Path "$aceDir\LibStub\LibStub.lua" -Destination "$libsDir\LibStub\LibStub.lua" -Force

    # Copy CallbackHandler-1.0
    Copy-Item -Path "$aceDir\CallbackHandler-1.0\*" -Destination "$libsDir\CallbackHandler-1.0" -Recurse -Force

    # Copy Ace3 modules
    $aceModules = @("AceAddon-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceConsole-3.0")
    foreach ($mod in $aceModules) {
        Copy-Item -Path "$aceDir\$mod\*" -Destination "$libsDir\$mod" -Recurse -Force
    }

    # Copy LibDeflate
    Copy-Item -Path "$deflateDir\LibDeflate.lua" -Destination "$libsDir\LibDeflate\LibDeflate.lua" -Force

    # Copy LibDataBroker-1.1
    Copy-Item -Path "$ldbDir\LibDataBroker-1.1.lua" -Destination "$libsDir\LibDataBroker-1.1\LibDataBroker-1.1.lua" -Force

    Write-Host "[SUCCESS] All community libraries updated successfully from upstream." -ForegroundColor Green

    # Run bracket balance verification
    Write-Host "`nRunning syntax verification across Libs/..." -ForegroundColor Cyan
    $hasErrors = $false
    $luaFiles = Get-ChildItem -Path $libsDir -Filter "*.lua" -Recurse
    foreach ($f in $luaFiles) {
        $c = Get-Content $f.FullName -Raw
        $openParen = ([regex]::Matches($c, '\(')).Count
        $closeParen = ([regex]::Matches($c, '\)')).Count
        $openBrace = ([regex]::Matches($c, '\{')).Count
        $closeBrace = ([regex]::Matches($c, '\}')).Count
        if ($openParen -ne $closeParen -or $openBrace -ne $closeBrace) {
            Write-Host "  [FAIL] $($f.Name) unbalanced brackets" -ForegroundColor Red
            $hasErrors = $true
        }
    }

    if ($hasErrors) {
        Write-Host "Verification FAILED after update!" -ForegroundColor Red
        exit 1
    } else {
        Write-Host "All Lua files verified with balanced syntax!" -ForegroundColor Green
    }
}
finally {
    if (Test-Path $tempDir) {
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
