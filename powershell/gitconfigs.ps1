# Can be added to $PROFILE or run directly as a script

function Show-GitConfigs {
    [CmdletBinding()]
    param(
        [switch]$Override
    )

    function Test-GitRepository {
        git rev-parse --is-inside-work-tree 2>$null | Out-Null
        return $LASTEXITCODE -eq 0
    }

    function Get-GitConfig {
        param([string]$Level)
        $config = @{}
        $output = git config "--$Level" -l 2>$null
        if ($LASTEXITCODE -ne 0 -or -not $output) { return $config }
        foreach ($line in $output) {
            $key, $value = $line -split '=', 2
            $config[$key] = $value
        }
        return $config
    }

    function Write-Config {
        param([string]$Title, [string]$Color, [hashtable]$Config)
        Write-Host "$Title Configuration:" -ForegroundColor $Color
        if ($Config.Count -eq 0) {
            Write-Host "    (empty)"
        } else {
            $Config.GetEnumerator() | Sort-Object Key | ForEach-Object {
                Write-Host "    $($_.Key) = $($_.Value)"
            }
        }
        Write-Host ""
    }

    if (-not $Override -and -not (Test-GitRepository)) {
        Write-Error "Not inside a Git repository. Use -Override to run anyway."
        return
    }

    $systemConfig = Get-GitConfig 'system'
    $globalConfig = Get-GitConfig 'global'
    $localConfig  = Get-GitConfig 'local'

    Write-Config 'System' 'Yellow' $systemConfig
    Write-Config 'Global' 'Blue'   $globalConfig
    Write-Config 'Local'  'Green'  $localConfig

    # Effective config: local beats global beats system
    $effective = @{}
    foreach ($e in $systemConfig.GetEnumerator()) { $effective[$e.Key] = @{ Value=$e.Value; Source='system' } }
    foreach ($e in $globalConfig.GetEnumerator())  { $effective[$e.Key] = @{ Value=$e.Value; Source='global' } }
    foreach ($e in $localConfig.GetEnumerator())   { $effective[$e.Key] = @{ Value=$e.Value; Source='local'  } }

    $colorMap = @{ system='Yellow'; global='Blue'; local='Green' }

    Write-Host "Effective Configuration:" -ForegroundColor Magenta -NoNewline
    Write-Host "  " -NoNewline
    Write-Host "■ system" -ForegroundColor Yellow -NoNewline
    Write-Host "  " -NoNewline
    Write-Host "■ global" -ForegroundColor Blue -NoNewline
    Write-Host "  " -NoNewline
    Write-Host "■ local" -ForegroundColor Green
    Write-Host ""

    $effective.GetEnumerator() | Sort-Object Key | ForEach-Object {
        Write-Host "    $($_.Key): $($_.Value.Value)" -ForegroundColor $colorMap[$_.Value.Source]
    }
}

Set-Alias -Name gitconfigs -Value Show-GitConfigs

# Uncomment to run directly as a script:
# Show-GitConfigs @args
