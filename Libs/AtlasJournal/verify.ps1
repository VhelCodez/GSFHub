Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "       AtlasJournal Library Verification      " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$hasErrors = $false

# 1. Catalog Item IDs Integrity
$dataContent = Get-Content (Join-Path $scriptDir "AtlasJournalData.lua") -Raw
$ids = [regex]::Matches($dataContent, 'id\s*=\s*(\d+)') | ForEach-Object { [int]$_.Groups[1].Value }
$uniqueIds = $ids | Sort-Object -Unique
$duplicates = $ids | Group-Object | Where-Object { $_.Count -gt 1 }

Write-Host "  -> Catalog Total Entries: $($ids.Count)"
Write-Host "  -> Catalog Unique Items:  $($uniqueIds.Count)"
if ($duplicates) {
    Write-Host "  [FAIL] Duplicate Item IDs found: $($duplicates.Name -join ', ')" -ForegroundColor Red
    $hasErrors = $true
} else {
    Write-Host "  [PASS] All $($uniqueIds.Count) Item IDs are unique." -ForegroundColor Green
}

# 2. Locales Parity Check
$engineContent = Get-Content (Join-Path $scriptDir "AtlasJournal.lua") -Raw
$enUSMatch = [regex]::Match($engineContent, '(?s)\["enUS"\]\s*=\s*\{(.*?)\},')
$deDEMatch = [regex]::Match($engineContent, '(?s)\["deDE"\]\s*=\s*\{(.*?)\},')

if ($enUSMatch.Success -and $deDEMatch.Success) {
    $enKeys = [regex]::Matches($enUSMatch.Groups[1].Value, '\["([^"]+)"\]') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
    $deKeys = [regex]::Matches($deDEMatch.Groups[1].Value, '\["([^"]+)"\]') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
    
    $missingInDe = $enKeys | Where-Object { $_ -notin $deKeys }
    $missingInEn = $deKeys | Where-Object { $_ -notin $enKeys }

    Write-Host "  -> Locales Count: enUS ($($enKeys.Count)), deDE ($($deKeys.Count))"
    if ($missingInDe -or $missingInEn) {
        Write-Host "  [FAIL] Missing in deDE: $($missingInDe -join ', ')" -ForegroundColor Red
        Write-Host "  [FAIL] Missing in enUS: $($missingInEn -join ', ')" -ForegroundColor Red
        $hasErrors = $true
    } else {
        Write-Host "  [PASS] 100% dictionary match between enUS and deDE across $($enKeys.Count) keys." -ForegroundColor Green
    }
} else {
    Write-Host "  [FAIL] Could not parse embedded locales." -ForegroundColor Red
    $hasErrors = $true
}

# 3. Syntax & Bracket Integrity
foreach ($f in @("AtlasJournal.lua", "AtlasJournalData.lua")) {
    $path = Join-Path $scriptDir $f
    $c = Get-Content $path -Raw
    $openParen = ([regex]::Matches($c, '\(')).Count
    $closeParen = ([regex]::Matches($c, '\)')).Count
    $openBrace = ([regex]::Matches($c, '\{')).Count
    $closeBrace = ([regex]::Matches($c, '\}')).Count
    if ($openParen -ne $closeParen -or $openBrace -ne $closeBrace) {
        Write-Host "  [FAIL] $f has unbalanced brackets: Parens ($openParen/$closeParen), Braces ($openBrace/$closeBrace)" -ForegroundColor Red
        $hasErrors = $true
    } else {
        Write-Host "  [PASS] $f bracket balance verified." -ForegroundColor Green
    }
}

if ($hasErrors) {
    Write-Host "`nAtlasJournal Verification FAILED!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "`nAtlasJournal Verification PASSED!" -ForegroundColor Green
    exit 0
}
