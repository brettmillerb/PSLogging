function Get-LogDate {
    <#
    .SYNOPSIS
    Creates a Date and Timestamp to be used in log file creation

    .DESCRIPTION
    Creates a nicely formatted timestamp for use in log creation

    .PARAMETER Format
    Displays the date and time in the Microsoft .NET Framework format indicated by the format specifier.
    Enter a format specifier. For a list of available format specifiers, see DateTimeFormatInfo Class http://msdn.microsoft.com/library/system.globalization.datetimeformatinfo.aspx (http://msdn.microsoft.com/library/system.globalization.datetimeformatinfo.aspx) in MSDN.

    .EXAMPLE
    Get-LogDate

    .EXAMPLE
    Get-LogDate -Format 'yyyy-MM-dd HH:mm:ss'

    .EXAMPLE
    Get-LogDate

    .NOTES
    Default formatting if no formatting provided: 'yyyy-MM-dd HH:mm:ss'
    #>
    Param(
        [Parameter(Position=0)]
        [String]$Format = 'yyyy-MM-dd HH:mm:ss'
    )

    Get-Date -Format ("[{0}]" -f $Format)
}

Function Start-Log {
    <#
    .SYNOPSIS
    Creates a log file for use with the other functions.
    
    .DESCRIPTION
    Checks if a log file with the same name exists in the location and removes before creating a new log.
    Once created writes initial timestamped logging information.
    
    .PARAMETER LogPath
    Folder to save the log file
    
    .PARAMETER LogName
    Name of the log file to be used.
    
    .EXAMPLE
    Start-Log -LogPath C:\logs -LogName build.log
    
    .NOTES
    Forked from https://github.com/9to5IT/PSLogging
    #>

    [CmdletBinding()]

    Param (
        [Parameter(Mandatory = $true,
            Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$LogPath,

        [Parameter(Mandatory = $true,
            Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$LogName
    )

    Process {
        $PSBoundParameters['LogPath','LogName'] | Write-Verbose

        $logFile = Join-Path -Path $LogPath -ChildPath $LogName

        #Check if file exists and delete if it does
        If ( (Test-Path -Path $logFile) ) {
            "Removing existing log file in {0}" -f $logFile | Write-Verbose
            Remove-Item -Path $logFile -Force
        }

        #Create file and start logging
        "Creating new log file in {0}" -f $logFile | Write-Verbose
        New-Item -Path $logFile -ItemType File | Out-Null

        "{0} Log Started processing." -f (Get-LogDate) | Add-Content -Path $logFile
    }
}

Function Write-Log {
    <#
    .SYNOPSIS
    Writes string messages to a specified log file
    
    .DESCRIPTION
    Appends string messages to a log file
    
    .PARAMETER LogPath
    Path of the log file to append the string messages.
    
    .PARAMETER Message
    Message to be written to the log file.
    
    .EXAMPLE
    Write-LogInfo -LogPath $Logfile -Message 'This is a log message'

    .EXAMPLE
    "This is a {0} message" -f $stringdata | Write-LogInfo -LogPath $Logfile

    .EXAMPLE
    'An','array','of','strings' | Write-LogInfo -LogPath -$Logfile
    
    .NOTES
    Forked from https://github.com/9to5IT/PSLogging
    #>

    [CmdletBinding()]

    Param (
        [Parameter(Mandatory = $true, 
            Position = 0)]
        [string]$LogPath,

        [Parameter(Mandatory = $true,
            Position = 1,
            ValueFromPipeline = $true)]
        [string]$Message
    )

    Process {
        $PSBoundParameters['LogPath','Message'] | Write-Verbose
        
        "{0} {1}" -f (Get-LogDate), $Message | Add-Content -Path $LogPath
    }
}

Function Stop-Log {
    <#
    .SYNOPSIS
    Writes closing data to log file and optionally exits the script calling the function.

    .DESCRIPTION
    Writes closing data to log file and optionally exits the script calling the function.

    .PARAMETER LogPath
    Path of the log file to Append/Close

    .PARAMETER NoExit
    Prevents exiting the caller script

    .EXAMPLE
    Stop-Log -LogPath $Logfile -NoExit

    .NOTES
    Forked from https://github.com/9to5IT/PSLogging
    #>

    [CmdletBinding()]

    Param (
        [Parameter(Mandatory=$true,
            Position=0)]
        [string]$LogPath,

        [Parameter(Mandatory=$false,
            Position=1)]
        [switch]$NoExit
    )

    Process {
        "{0} Log Finished" -f (Get-LogDate) | Write-Verbose
        "{0} Log Finished" -f (Get-LogDate) | Add-Content -Path $LogPath

        #Exit calling script if NoExit has not been specified or is set to False
        If( !($NoExit) -or ($NoExit -eq $False) ){
            Exit
        }
    }
}