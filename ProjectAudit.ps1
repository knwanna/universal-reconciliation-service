<#
.SYNOPSIS
    Project Audit Script - Creates a comprehensive report of project structure and source code
.DESCRIPTION
    This script audits a project directory, documenting the structure and source code
    while ignoring sensitive files specified in .gitignore and common sensitive file patterns.
.NOTES
    Author: PowerShell Scripting Team
    Version: 1.2
#>

# Script Parameters
param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectPath = ".",  # Default to current directory
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile = "ProjectAuditReport.txt",  # Output report filename
    
    [Parameter(Mandatory=$false)]
    [switch]$IncludeFileContents = $true  # Include file contents in the report
)

# Function to write section headers to the report
function Write-SectionHeader {
    param(
        [string]$Title,
        [string]$Character = "=",
        [int]$Length = 80
    )
    
    $header = $Character * $Length
    $padding = [math]::Max(0, ($Length - $Title.Length - 2)) / 2
    $titleLine = "$($Character * [math]::Floor($padding)) $Title $($Character * [math]::Ceiling($padding))"
    
    if ($titleLine.Length -gt $Length) {
        $titleLine = $titleLine.Substring(0, $Length)
    }
    
    Add-Content -Path $OutputFile -Value "`n$header"
    Add-Content -Path $OutputFile -Value $titleLine
    Add-Content -Path $OutputFile -Value "$header`n"
}

# Function to get common ignore patterns
function Get-IgnorePatterns {
    $patterns = @()
    
    # Common sensitive file patterns
    $patterns += @('*.env','*.ps1', '*.key', '*.pem', '*.pfx', '*.cert', '*.crt',
                  '*.secret', '*.private', 'credentials*', 'config.*',
                  'appsettings.*.json', 'web.config', 'app.config',
                  'connectionstrings.*', 'secrets.*', '*.token', '*.jwt')
    
    # Common ignore directories
    $patterns += @('node_modules', 'bin', 'obj', 'packages', '__pycache__',
                  '.git', '.vs', '.vscode', '.idea', 'dist', 'build',
                  'target', 'out', 'logs', 'temp', 'tmp')
    
    # Read .gitignore if it exists
    $gitignorePath = Join-Path $ProjectPath ".gitignore"
    if (Test-Path $gitignorePath) {
        $gitignoreContent = Get-Content $gitignorePath
        foreach ($line in $gitignoreContent) {
            $line = $line.Trim()
            if ($line -and !$line.StartsWith('#') -and !$line.StartsWith('!')) {
                $patterns += $line
            }
        }
    }
    
    return $patterns
}

# Function to check if a file should be ignored
function Should-Ignore {
    param(
        [string]$FilePath,
        [array]$IgnorePatterns
    )
    
    $fileName = Split-Path $FilePath -Leaf
    
    foreach ($pattern in $IgnorePatterns) {
        if ($pattern.Contains('/') -or $pattern.Contains('\')) {
            # Path pattern (directory)
            if ($FilePath -like "*$pattern*") {
                return $true
            }
        } else {
            # File pattern
            if ($fileName -like $pattern) {
                return $true
            }
        }
    }
    
    return $false
}

# Function to get file information
function Get-FileInfo {
    param(
        [string]$FilePath
    )
    
    $file = Get-Item $FilePath
    $extension = [System.IO.Path]::GetExtension($FilePath)
    
    $info = @{
        Name = $file.Name
        Path = $file.FullName
        Extension = if ($extension) { $extension } else { "No Extension" }
        Size = $file.Length
        LastModified = $file.LastWriteTime
        Lines = 0
    }
    
    try {
        $content = Get-Content $FilePath -ErrorAction Stop
        $info.Lines = $content.Length
    } catch {
        $info.Lines = "Unable to count lines"
    }
    
    return $info
}

# Function to format file size in a human-readable format
function Format-FileSize {
    param([long]$Size)
    
    if ($Size -gt 1GB) { return "{0:N2} GB" -f ($Size / 1GB) }
    elseif ($Size -gt 1MB) { return "{0:N2} MB" -f ($Size / 1MB) }
    elseif ($Size -gt 1KB) { return "{0:N2} KB" -f ($Size / 1KB) }
    else { return "$Size bytes" }
}

# Main script execution
try {
    # Verify project path exists
    if (-not (Test-Path $ProjectPath -PathType Container)) {
        Write-Error "Project path '$ProjectPath' does not exist or is not a directory"
        exit 1
    }
    
    # Resolve full paths
    $ProjectPath = Resolve-Path $ProjectPath
    $OutputFile = Join-Path $ProjectPath $OutputFile
    
    Write-Host "Starting project audit of: $ProjectPath" -ForegroundColor Green
    Write-Host "Output will be saved to: $OutputFile" -ForegroundColor Green
    
    # Get ignore patterns
    $ignorePatterns = Get-IgnorePatterns
    Write-Host "Loaded $($ignorePatterns.Count) ignore patterns" -ForegroundColor Yellow
    
    # Initialize report
    if (Test-Path $OutputFile) {
        Remove-Item $OutputFile -Force
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $header = @"
PROJECT AUDIT REPORT
Generated: $timestamp
Project Path: $ProjectPath
Audit Script: $($MyInvocation.MyCommand.Name)
Script Version: 1.2

"@
    
    Set-Content -Path $OutputFile -Value $header
    
    # Add project structure section
    Write-SectionHeader -Title "PROJECT STRUCTURE"
    Add-Content -Path $OutputFile -Value "Directory tree of the project:`n"
    
    $treeOutput = cmd /c "tree `"$ProjectPath`" /F /A 2>nul"
    if ($LASTEXITCODE -eq 0) {
        Add-Content -Path $OutputFile -Value $treeOutput
    } else {
        # Fallback if tree command is not available
        Add-Content -Path $OutputFile -Value "Tree command not available. Using Get-ChildItem output:`n"
        $dirs = Get-ChildItem -Path $ProjectPath -Recurse -Directory | Select-Object FullName
        foreach ($dir in $dirs) {
            $relativePath = $dir.FullName.Substring($ProjectPath.Length + 1)
            Add-Content -Path $OutputFile -Value $relativePath
        }
    }
    
    # File inventory section
    Write-SectionHeader -Title "FILE INVENTORY"
    Add-Content -Path $OutputFile -Value "List of all files in the project:`n"
    
    $allFiles = Get-ChildItem -Path $ProjectPath -Recurse -File | 
                Where-Object { $_.FullName -ne $OutputFile } |  # Exclude the report itself
                Sort-Object FullName
    
    $fileCount = 0
    $includedFiles = @()
    
    foreach ($file in $allFiles) {
        $relativePath = $file.FullName.Substring($ProjectPath.Length + 1)
        
        if (Should-Ignore -FilePath $relativePath -IgnorePatterns $ignorePatterns) {
            Write-Host "Ignoring: $relativePath" -ForegroundColor Yellow
            continue
        }
        
        $fileCount++
        $includedFiles += $file.FullName
        
        $fileInfo = Get-FileInfo -FilePath $file.FullName
        $fileSize = Format-FileSize -Size $fileInfo.Size
        
        $fileEntry = "[$fileCount] $relativePath | Size: $fileSize | Lines: $($fileInfo.Lines) | Modified: $($fileInfo.LastModified)"
        Add-Content -Path $OutputFile -Value $fileEntry
    }
    
    Add-Content -Path $OutputFile -Value "`nTotal files included in audit: $fileCount"
    
    # File contents section
    if ($IncludeFileContents) {
        Write-SectionHeader -Title "FILE CONTENTS"
        Add-Content -Path $OutputFile -Value "Detailed contents of each file:`n"
        
        $fileIndex = 1
        foreach ($filePath in $includedFiles) {
            $relativePath = $filePath.Substring($ProjectPath.Length + 1)
            
            # Fixed the variable reference issue here
            Write-Host ("Processing file {0} of {1}: {2}" -f $fileIndex, $fileCount, $relativePath) -ForegroundColor Cyan
            
            Add-Content -Path $OutputFile -Value ("=" * 80)
            Add-Content -Path $OutputFile -Value "FILE: $relativePath"
            Add-Content -Path $OutputFile -Value ("=" * 80)
            
            try {
                $content = Get-Content $filePath -Raw -ErrorAction Stop
                Add-Content -Path $OutputFile -Value $content
                Add-Content -Path $OutputFile -Value "`n"
            } catch {
                Add-Content -Path $OutputFile -Value "Unable to read file content: $($_.Exception.Message)`n"
            }
            
            $fileIndex++
        }
    }
    
    # Summary section
    Write-SectionHeader -Title "AUDIT SUMMARY"
    
    $summary = @"
Audit completed: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Project location: $ProjectPath
Total files scanned: $($allFiles.Count)
Total files included in report: $fileCount
Report file size: $(Format-FileSize -Size (Get-Item $OutputFile).Length)

Ignored patterns:
$($ignorePatterns -join "`n")

This report was generated by the Project Audit Script.
"@
    
    Add-Content -Path $OutputFile -Value $summary
    
    Write-Host "Audit completed successfully!" -ForegroundColor Green
    Write-Host "Report saved to: $OutputFile" -ForegroundColor Green
    Write-Host "Report size: $(Format-FileSize -Size (Get-Item $OutputFile).Length)" -ForegroundColor Green
    
} catch {
    Write-Error "Script execution failed: $($_.Exception.Message)"
    exit 1
}