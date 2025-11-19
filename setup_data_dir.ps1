# Script to manually create the data directory for Flutter Windows app
# This is needed when flutter run fails to create it automatically

$ErrorActionPreference = "Stop"

Write-Host "Setting up Flutter data directory..."

# Get paths
$projectDir = $PSScriptRoot
$buildDir = Join-Path $projectDir "build\windows\x64"
$dataSource = Join-Path $buildDir "data"
$dataDest = Join-Path $buildDir "runner\Debug\data"

# Check if executable exists
$exePath = Join-Path $buildDir "runner\Debug\pg_db_ui.exe"
if (-not (Test-Path $exePath)) {
    Write-Host "Error: Executable not found at $exePath"
    Write-Host "Please run 'flutter build windows --debug' first"
    exit 1
}

# Try to create data directory using Flutter tools
Write-Host "Running Flutter tool to create data directory..."

# Check if Flutter is available
try {
    $flutterCommand = Get-Command flutter -ErrorAction Stop
    $flutterRoot = $flutterCommand.Source | Split-Path | Split-Path
    Write-Host "Found Flutter at: $flutterRoot"
} catch {
    Write-Host "Warning: Flutter command not found in PATH"
    Write-Host "Skipping tool_backend method..."
    $flutterRoot = $null
}

if ($flutterRoot) {
    $toolBackend = Join-Path $flutterRoot "packages\flutter_tools\bin\tool_backend.bat"
    
    if (Test-Path $toolBackend) {
        Push-Location $buildDir
        try {
            $env:FLUTTER_ROOT = $flutterRoot
            $env:PROJECT_DIR = $projectDir
            $env:FLUTTER_EPHEMERAL_DIR = Join-Path $projectDir "windows\flutter\ephemeral"
            
            Write-Host "Executing tool_backend..."
            $output = & $toolBackend windows-x64 Debug 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Tool backend executed successfully"
            } else {
                Write-Host "Warning: Tool backend exited with code $LASTEXITCODE"
                Write-Host "Output: $output"
            }
        } catch {
            Write-Host "Warning: Tool backend failed: $_"
        } finally {
            Pop-Location
        }
    } else {
        Write-Host "Warning: tool_backend.bat not found at: $toolBackend"
        Write-Host "This may be normal for some Flutter installations"
    }
}

# Check if data was created
if (Test-Path $dataSource) {
    Write-Host "Found data directory at: $dataSource"
    
    # Remove existing destination if it exists
    if (Test-Path $dataDest) {
        Write-Host "Removing existing data directory at destination..."
        try {
            Remove-Item $dataDest -Recurse -Force -ErrorAction Stop
        } catch {
            Write-Host "Error: Failed to remove existing directory: $_"
            exit 1
        }
    }
    
    # Create parent directory
    $parentDir = Split-Path $dataDest
    if (-not (Test-Path $parentDir)) {
        Write-Host "Creating parent directory: $parentDir"
        try {
            New-Item -ItemType Directory -Path $parentDir -Force -ErrorAction Stop | Out-Null
        } catch {
            Write-Host "Error: Failed to create parent directory: $_"
            exit 1
        }
    }
    
    # Copy data directory
    Write-Host "Copying data directory..."
    try {
        Copy-Item $dataSource -Destination $dataDest -Recurse -Force -ErrorAction Stop
        
        # Verify copy succeeded
        if (Test-Path $dataDest) {
            Write-Host "✓ Data directory copied successfully to: $dataDest"
            Write-Host "`nApp should now work! Run: .\build\windows\x64\runner\Debug\pg_db_ui.exe"
        } else {
            Write-Host "✗ Error: Copy operation reported success but destination not found"
            exit 1
        }
    } catch {
        Write-Host "✗ Error: Failed to copy data directory: $_"
        exit 1
    }
} else {
    Write-Host "✗ Data directory not created by tool_backend"
    Write-Host "`nTrying alternative: Use flutter run which should create it..."
    Write-Host "Run: flutter run -d windows"
    Write-Host "(Ignore debug connection errors - app should still launch)"
}

