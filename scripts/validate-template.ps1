[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$requiredPaths = @(
    '.github\workflows\validate.yml',
    'README.md',
    'docs\architecture\overview.md',
    'docs\operations\bootstrap-new-repo.md',
    'scripts\bootstrap-github-repo.ps1'
)

foreach ($relativePath in $requiredPaths) {
    $fullPath = Join-Path $repoRoot $relativePath
    if (-not (Test-Path -LiteralPath $fullPath)) {
        throw "Missing required starter path: $relativePath"
    }
}

$scriptFiles = Get-ChildItem -Path $PSScriptRoot -Filter *.ps1 -File
foreach ($file in $scriptFiles) {
    $tokens = $null
    $errors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors)
    if ($errors.Count -gt 0) {
        throw "PowerShell parse errors in $($file.Name): $($errors[0].Message)"
    }
}

Write-Host 'Template validation succeeded.'
