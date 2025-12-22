#Requires -Version 5.1
<#!
.SYNOPSIS
    Enhanced Jekyll development server for pages.stevengoulet.com

.DESCRIPTION
    Provides a richer local development workflow for this Jekyll site. Supports
    optional image regeneration, cleaning the output directory, and serving in
    production or development modes with convenient defaults.

.PARAMETER RegenerateImages
    Regenerate thumbnails and image captions before serving

.PARAMETER NoDrafts
    Exclude drafts from the build

.PARAMETER NoFuture
    Exclude future-dated posts from the build

.PARAMETER NoLiveReload
    Disable live reload functionality

.PARAMETER Port
    Specify the port to serve on (default: 4001)

.PARAMETER LiveReloadPort
    Specify the LiveReload port to use (default: 35730)

.PARAMETER HostAddress
    Specify the host to bind to (default: localhost)

.PARAMETER Clean
    Clean the _site directory before building

.PARAMETER Production
    Serve in production mode (disables drafts, future posts, and live reload)

.PARAMETER CheckOnly
    Only check if dependencies are available, don't serve

.PARAMETER Help
    Display this help message

.EXAMPLE
    .\serve.ps1
    Serves the site with default options (drafts, future posts, live reload)

.EXAMPLE
    .\serve.ps1 -RegenerateImages
    Regenerates image assets then serves the site

.EXAMPLE
    .\serve.ps1 -Production
    Serves the site in production mode

.EXAMPLE
    .\serve.ps1 -Port 3000 -HostAddress 0.0.0.0
    Serves on port 3000, accessible from other machines
#>

[CmdletBinding()]
param(
    [switch]$RegenerateImages,
    [switch]$NoDrafts,
    [switch]$NoFuture,
    [switch]$NoLiveReload,
    [int]$Port = 4001,
    [int]$LiveReloadPort = 35730,
    [string]$HostAddress = "localhost",
    [switch]$Clean,
    [switch]$Production,
    [switch]$CheckOnly,
    [Alias("h")]
    [switch]$Help
)

$ErrorActionPreference = "Stop"

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO]  $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK]    $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARN]  $Message" -ForegroundColor Yellow
}

function Write-Failure {
    param([string]$Message)
    Write-Host "[FAIL]  $Message" -ForegroundColor Red
}

function Write-Step {
    param([string]$Message)
    Write-Host "[STEP]  $Message" -ForegroundColor Magenta
}

function Test-Dependencies {
    Write-Step "Checking dependencies"

    $dependencies = @{
        "bundle" = "Ruby Bundler"
        "jekyll" = "Jekyll"
    }

    $missing = @()

    foreach ($dep in $dependencies.GetEnumerator()) {
        try {
            $null = Get-Command $dep.Key -ErrorAction Stop
            Write-Success "$($dep.Value) is available"
        }
        catch {
            Write-Failure "$($dep.Value) is not available"
            $missing += $dep.Value
        }
    }

    if ($RegenerateImages) {
        $imageTools = @{
            "ffmpeg" = "FFMPEG"
            "magick" = "ImageMagick"
            "avifenc" = "AVIF Encoder"
        }

        foreach ($tool in $imageTools.GetEnumerator()) {
            try {
                $null = Get-Command $tool.Key -ErrorAction Stop
                Write-Success "$($tool.Value) is available"
            }
            catch {
                Write-Warning "$($tool.Value) is not available; image regeneration may fail"
            }
        }
    }

    if ($missing.Count -gt 0) {
        Write-Failure "Missing required dependencies: $($missing -join ', ')"
        Write-Info "Install the missing tools and try again."
        exit 1
    }

    if (-not (Test-Path "Gemfile")) {
        Write-Failure "Gemfile not found. Are you in the repository root?"
        exit 1
    }

    Write-Success "All required dependencies are ready"
}

function Clear-SiteDirectory {
    if (Test-Path "_site") {
        Write-Step "Cleaning _site directory"
        try {
            Remove-Item "_site" -Recurse -Force
            Write-Success "_site directory cleaned"
        }
        catch {
            Write-Warning "Unable to fully clean _site: $_"
        }
    }
}

function Update-ImageAssets {
    Write-Step "Regenerating image assets"

    if (Test-Path "convert-to-avif.ps1") {
        Write-Info "Converting source images to AVIF"
        try {
            & "./convert-to-avif.ps1"
            Write-Success "AVIF generation complete"
        }
        catch {
            Write-Warning "AVIF conversion failed: $_"
        }
    }
    else {
        Write-Warning "convert-to-avif.ps1 not found"
    }

    if (Test-Path "gen-thumbnails.ps1") {
        Write-Info "Generating thumbnails"
        try {
            & "./gen-thumbnails.ps1"
            Write-Success "Thumbnail generation complete"
        }
        catch {
            Write-Warning "Thumbnail generation failed: $_"
        }
    }
    else {
        Write-Warning "gen-thumbnails.ps1 not found"
    }

    if (Test-Path "gen-imagecaptions.ps1") {
        Write-Info "Generating image captions"
        try {
            & "./gen-imagecaptions.ps1"
            Write-Success "Image captions generated"
        }
        catch {
            Write-Warning "Image caption generation failed: $_"
        }
    }
    else {
        Write-Warning "gen-imagecaptions.ps1 not found"
    }
}

function Build-JekyllCommand {
    $cmd = @("bundle", "exec", "jekyll", "serve")

    $cmd += "--port", $Port.ToString()
    $cmd += "--host", $HostAddress

    if (-not $NoLiveReload -and -not $Production) {
        $cmd += "--livereload"
        $cmd += "--livereload-port", $LiveReloadPort.ToString()
    }

    if (-not $NoDrafts -and -not $Production) {
        $cmd += "--drafts"
    }

    if (-not $NoFuture -and -not $Production) {
        $cmd += "--future"
    }

    return $cmd
}

function Show-StartupInfo {
    Write-Host ""
    Write-Host "Jekyll Development Server" -ForegroundColor Blue
    Write-Host "==========================" -ForegroundColor Blue
    Write-Info "URL: http://$HostAddress`:$Port"
    Write-Info "Mode: $(if ($Production) { 'Production' } else { 'Development' })"

    if (-not $Production -and -not $NoLiveReload) {
        Write-Info "LiveReload: http://$HostAddress`:$LiveReloadPort"
    }

    if (-not $Production) {
        Write-Info "Enabled features:"
        if (-not $NoDrafts) { Write-Host "  - Draft posts" -ForegroundColor Gray }
        if (-not $NoFuture) { Write-Host "  - Future posts" -ForegroundColor Gray }
        if (-not $NoLiveReload) { Write-Host "  - Live reload" -ForegroundColor Gray }
    }

    Write-Host ""
    Write-Info "Press Ctrl+C to stop"
    Write-Host ""
}

function Show-CustomHelp {
    Write-Host ""
    Write-Host "pages.stevengoulet.com - Jekyll Server" -ForegroundColor Blue
    Write-Host "======================================" -ForegroundColor Blue
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor Yellow
    Write-Host "  .\\serve.ps1 [OPTIONS]" -ForegroundColor White
    Write-Host ""
    Write-Host "BASIC EXAMPLES:" -ForegroundColor Yellow
    Write-Host "  .\\serve.ps1                    # Start development server with defaults" -ForegroundColor Gray
    Write-Host "  .\\serve.ps1 -Production        # Start in production mode" -ForegroundColor Gray
    Write-Host "  .\\serve.ps1 -RegenerateImages  # Regenerate image assets before serving" -ForegroundColor Gray
    Write-Host ""
    Write-Host "OPTIONS:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Development Control:" -ForegroundColor Cyan
    Write-Host "    -Production          Production mode (disables drafts, future posts, live reload)" -ForegroundColor White
    Write-Host "    -NoDrafts            Exclude draft posts from build" -ForegroundColor White
    Write-Host "    -NoFuture            Exclude future-dated posts from build" -ForegroundColor White
    Write-Host "    -NoLiveReload        Disable live reload functionality" -ForegroundColor White
    Write-Host ""
    Write-Host "  Server Configuration:" -ForegroundColor Cyan
    Write-Host "    -Port <number>       Specify port to serve on (default: 4000)" -ForegroundColor White
    Write-Host "    -LiveReloadPort <n>  Specify LiveReload port (default: 35729)" -ForegroundColor White
    Write-Host "    -HostAddress <addr>  Specify host address (default: localhost)" -ForegroundColor White
    Write-Host ""
    Write-Host "  Build Options:" -ForegroundColor Cyan
    Write-Host "    -Clean               Clean _site directory before building" -ForegroundColor White
    Write-Host "    -RegenerateImages    Run image processing scripts before serving" -ForegroundColor White
    Write-Host ""
    Write-Host "  Utility:" -ForegroundColor Cyan
    Write-Host "    -CheckOnly           Only verify dependencies, do not serve" -ForegroundColor White
    Write-Host "    -Help, -h            Show this help message" -ForegroundColor White
    Write-Host ""
    Write-Host "ADVANCED EXAMPLES:" -ForegroundColor Yellow
    Write-Host "  .\\serve.ps1 -Port 3000 -HostAddress 0.0.0.0" -ForegroundColor Gray
    Write-Host "    # Serve on port 3000, accessible from other machines" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  .\\serve.ps1 -Clean -RegenerateImages -Production" -ForegroundColor Gray
    Write-Host "    # Clean build, regenerate images, serve in production mode" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  .\\serve.ps1 -NoDrafts -NoFuture -Port 8080" -ForegroundColor Gray
    Write-Host "    # Custom development setup without drafts/future posts" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "DEPENDENCIES:" -ForegroundColor Yellow
    Write-Host "  Required: Ruby Bundler, Jekyll" -ForegroundColor White
    Write-Host "  Optional: FFMPEG, ImageMagick (for image regeneration)" -ForegroundColor White
    Write-Host ""
    Write-Host "For detailed help: Get-Help .\\serve.ps1 -Full" -ForegroundColor Green
    Write-Host ""
}

try {
    if ($Help) {
        Show-CustomHelp
        exit 0
    }

    Write-Host "pages.stevengoulet.com - Jekyll Server" -ForegroundColor Blue
    Write-Host "======================================" -ForegroundColor Blue
    Write-Host ""

    Test-Dependencies

    if ($CheckOnly) {
        Write-Success "Dependency check complete. Ready to serve."
        exit 0
    }

    if ($Clean) {
        Clear-SiteDirectory
    }

    if ($RegenerateImages) {
        Update-ImageAssets
    }

    $jekyllCmd = Build-JekyllCommand

    Show-StartupInfo

    Write-Step "Starting Jekyll server"
    Write-Info "Command: $($jekyllCmd -join ' ')"
    Write-Host ""

    & $jekyllCmd[0] $jekyllCmd[1..($jekyllCmd.Length - 1)]
}
catch {
    Write-Failure "An error occurred: $_"
    exit 1
}
finally {
    Write-Host ""
    Write-Info "Jekyll server stopped."
}
