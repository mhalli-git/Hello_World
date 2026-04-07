[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Owner,
    [Parameter(Mandatory = $true)]
    [string]$Repo,
    [string]$DefaultBranch = 'main',
    [string]$RequiredCheck = 'Validate'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$gh = 'C:\Program Files\GitHub CLI\gh.exe'
if (-not (Test-Path -LiteralPath $gh)) {
    throw "GitHub CLI not found at $gh"
}

& $gh auth status | Out-Null
& $gh repo view "$Owner/$Repo" | Out-Null

$null = & $gh repo edit "$Owner/$Repo" --default-branch $DefaultBranch --enable-auto-merge --enable-issues --enable-wiki=false --template
$null = & $gh api --method PUT "repos/$Owner/$Repo/actions/permissions" -F enabled=true -f allowed_actions=all
$null = & $gh api --method PUT "repos/$Owner/$Repo/actions/permissions/workflow" -f default_workflow_permissions=write -F can_approve_pull_request_reviews=true

$protectionBody = @{
    required_status_checks = @{
        strict   = $true
        contexts = @($RequiredCheck)
    }
    enforce_admins = $false
    required_pull_request_reviews = @{
        dismiss_stale_reviews           = $false
        require_code_owner_reviews      = $false
        required_approving_review_count = 0
    }
    restrictions = $null
    allow_force_pushes = $false
    allow_deletions = $false
    block_creations = $false
    required_conversation_resolution = $false
    lock_branch = $false
    allow_fork_syncing = $false
}

$json = $protectionBody | ConvertTo-Json -Depth 20 -Compress
$jsonPath = Join-Path ([System.IO.Path]::GetTempPath()) "$Repo-branch-protection.json"
$json | Set-Content -LiteralPath $jsonPath -Encoding utf8
$null = & $gh api --method PUT "repos/$Owner/$Repo/branches/$DefaultBranch/protection" --input $jsonPath
Remove-Item -LiteralPath $jsonPath -Force

& $gh api "repos/$Owner/$Repo" --jq "{name: .full_name, default_branch: .default_branch, private: .private, is_template: .is_template, allow_auto_merge: .allow_auto_merge, delete_branch_on_merge: .delete_branch_on_merge}"
