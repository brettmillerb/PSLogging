###
# Author: Luca Sturlese
# URL: http://9to5IT.com
###

Set-StrictMode -Version Latest

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
     Creates a new log file

    .DESCRIPTION
     Creates a log file with the path and name specified in the parameters. Checks if log file exists, and if it does deletes it and creates a new one.
     Once created, writes initial logging data

    .PARAMETER LogPath
     Mandatory. Path of where log is to be created. Example: C:\Windows\Temp

    .PARAMETER LogName
     Mandatory. Name of log file to be created. Example: Test_Script.log

    .PARAMETER ToScreen
     Optional. When parameter specified will display the content to screen as well as write to log file. This provides an additional
     another option to write content to screen as opposed to using debug mode.

    .INPUTS
     Parameters above

    .OUTPUTS
    Log file created

    .NOTES
     Version:        1.0
     Author:         Luca Sturlese
     Creation Date:  10/05/12
     Purpose/Change: Initial function development.

     Version:        1.1
     Author:         Luca Sturlese
     Creation Date:  19/05/12
     Purpose/Change: Added debug mode support.

     Version:        1.2
     Author:         Luca Sturlese
     Creation Date:  02/09/15
     Purpose/Change: Changed function name to use approved PowerShell Verbs. Improved help documentation.

     Version:        1.3
     Author:         Luca Sturlese
     Creation Date:  07/09/15
     Purpose/Change: Resolved issue with New-Item cmdlet. No longer creates error. Tested - all ok.

     Version:        1.4
     Author:         Luca Sturlese
     Creation Date:  12/09/15
     Purpose/Change: Added -ToScreen parameter which will display content to screen as well as write to the log file.

    .LINK
     http://9to5IT.com/powershell-logging-v2-easily-create-log-files

    .EXAMPLE
     Start-Log -LogPath "C:\Windows\Temp" -LogName "Test_Script.log"

     Creates a new log file with the file path of C:\Windows\Temp\Test_Script.log. Initialises the log file with
     the date and time the log was created (or the calling script started executing) and the calling script's version.
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
                $sFullPath = Join-Path -Path $LogPath -ChildPath $LogName
        
                #Check if file exists and delete if it does
                If ( (Test-Path -Path $sFullPath) ) {
                    "Removing existing logfile" | Write-Verbose
                    Remove-Item -Path $sFullPath -Force
                }
        
                #Create file and start logging
                "Creating new log file in {0}" -f $sFullPath | Write-Verbose
                New-Item -Path $sFullPath -ItemType File | Out-Null
        
                "{0} Log Started processing." -f (Get-LogDate) | Add-Content -Path $sFullPath
            }
        }

Function Write-LogInfo {
    <#
    .SYNOPSIS
     Writes informational message to specified log file

    .DESCRIPTION
     Appends a new informational message to the specified log file

    .PARAMETER LogPath
     Mandatory. Full path of the log file you want to write to. Example: C:\Windows\Temp\Test_Script.log

    .PARAMETER Message
     Mandatory. The string that you want to write to the log

    .PARAMETER TimeStamp
     Optional. When parameter specified will append the current date and time to the end of the line. Useful for knowing
     when a task started and stopped.

    .INPUTS
     Parameters above

    .OUTPUTS
     None

    .NOTES
     Version:        1.0
     Author:         Luca Sturlese
     Creation Date:  10/05/12
     Purpose/Change: Initial function development.

     Version:        1.1
     Author:         Luca Sturlese
     Creation Date:  19/05/12
     Purpose/Change: Added debug mode support.

     Version:        1.2
     Author:         Luca Sturlese
     Creation Date:  02/09/15
     Purpose/Change: Changed function name to use approved PowerShell Verbs. Improved help documentation.

     Version:        1.3
     Author:         Luca Sturlese
     Creation Date:  02/09/15
     Purpose/Change: Changed parameter name from LineValue to Message to improve consistency across functions.

     Version:        1.4
     Author:         Luca Sturlese
     Creation Date:  12/09/15
     Purpose/Change: Added -TimeStamp parameter which append a timestamp to the end of the line. Useful for knowing when a task started and stopped.

     Version:        1.5
     Author:         Luca Sturlese
     Creation Date:  12/09/15
     Purpose/Change: Added -ToScreen parameter which will display content to screen as well as write to the log file.

    .LINK
     http://9to5IT.com/powershell-logging-v2-easily-create-log-files

    .EXAMPLE
     Write-LogInfo -LogPath "C:\Windows\Temp\Test_Script.log" -Message "This is a new line which I am appending to the end of the log file."

     Writes a new informational log message to a new line in the specified log file.
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
        "{0} {1}" -f (Get-LogDate), $Message | Add-Content -Path $LogPath
    }
}

Function Stop-Log {
  <#
  .SYNOPSIS
    Write closing data to log file & exits the calling script

  .DESCRIPTION
    Writes finishing logging data to specified log file and then exits the calling script

  .PARAMETER LogPath
    Mandatory. Full path of the log file you want to write finishing data to. Example: C:\Windows\Temp\Test_Script.log

  .PARAMETER NoExit
    Optional. If parameter specified, then the function will not exit the calling script, so that further execution can occur (like Send-Log)

  .PARAMETER ToScreen
    Optional. When parameter specified will display the content to screen as well as write to log file. This provides an additional
    another option to write content to screen as opposed to using debug mode.

  .INPUTS
    Parameters above

  .OUTPUTS
    None

  .NOTES
    Version:        1.0
    Author:         Luca Sturlese
    Creation Date:  10/05/12
    Purpose/Change: Initial function development.

    Version:        1.1
    Author:         Luca Sturlese
    Creation Date:  19/05/12
    Purpose/Change: Added debug mode support.

    Version:        1.2
    Author:         Luca Sturlese
    Creation Date:  01/08/12
    Purpose/Change: Added option to not exit calling script if required (via optional parameter).

    Version:        1.3
    Author:         Luca Sturlese
    Creation Date:  02/09/15
    Purpose/Change: Changed function name to use approved PowerShell Verbs. Improved help documentation.

    Version:        1.4
    Author:         Luca Sturlese
    Creation Date:  12/09/15
    Purpose/Change: Changed -NoExit parameter to switch type so no longer need to specify $True or $False (see example for info).

    Version:        1.5
    Author:         Luca Sturlese
    Creation Date:  12/09/15
    Purpose/Change: Added -ToScreen parameter which will display content to screen as well as write to the log file.

  .LINK
    http://9to5IT.com/powershell-logging-v2-easily-create-log-files

  .EXAMPLE
    Stop-Log -LogPath "C:\Windows\Temp\Test_Script.log"

    Writes the closing logging information to the log file and then exits the calling script.

    Note: If you don't specify the -NoExit parameter, then the script will exit the calling script.

  .EXAMPLE
    Stop-Log -LogPath "C:\Windows\Temp\Test_Script.log" -NoExit

    Writes the closing logging information to the log file but does not exit the calling script. This then
    allows you to continue executing additional functionality in the calling script (such as calling the
    Send-Log function to email the created log to users).
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

Function Send-Log {
  <#
  .SYNOPSIS
    Emails completed log file to list of recipients

  .DESCRIPTION
    Emails the contents of the specified log file to a list of recipients

  .PARAMETER SMTPServer
    Mandatory. FQDN of the SMTP server used to send the email. Example: smtp.google.com

  .PARAMETER LogPath
    Mandatory. Full path of the log file you want to email. Example: C:\Windows\Temp\Test_Script.log

  .PARAMETER EmailFrom
    Mandatory. The email addresses of who you want to send the email from. Example: "admin@9to5IT.com"

  .PARAMETER EmailTo
    Mandatory. The email addresses of where to send the email to. Seperate multiple emails by ",". Example: "admin@9to5IT.com, test@test.com"

  .PARAMETER EmailSubject
    Mandatory. The subject of the email you want to send. Example: "Cool Script - [" + (Get-Date).ToShortDateString() + "]"

  .INPUTS
    Parameters above

  .OUTPUTS
    Email sent to the list of addresses specified

  .NOTES
    Version:        1.0
    Author:         Luca Sturlese
    Creation Date:  05.10.12
    Purpose/Change: Initial function development.

    Version:        1.1
    Author:         Luca Sturlese
    Creation Date:  02/09/15
    Purpose/Change: Changed function name to use approved PowerShell Verbs. Improved help documentation.

    Version:        1.2
    Author:         Luca Sturlese
    Creation Date:  02/09/15
    Purpose/Change: Added SMTPServer parameter to pass SMTP server as oppposed to having to set it in the function manually.

  .LINK
    http://9to5IT.com/powershell-logging-v2-easily-create-log-files

  .EXAMPLE
    Send-Log -SMTPServer "smtp.google.com" -LogPath "C:\Windows\Temp\Test_Script.log" -EmailFrom "admin@9to5IT.com" -EmailTo "admin@9to5IT.com, test@test.com" -EmailSubject "Cool Script"

    Sends an email with the contents of the log file as the body of the email. Sends the email from admin@9to5IT.com and sends
    the email to admin@9to5IT.com and test@test.com email addresses. The email has the subject of Cool Script. The email is
    sent using the smtp.google.com SMTP server.
  #>

  [CmdletBinding()]

  Param (
    [Parameter(Mandatory=$true,Position=0)][string]$SMTPServer,
    [Parameter(Mandatory=$true,Position=1)][string]$LogPath,
    [Parameter(Mandatory=$true,Position=2)][string]$EmailFrom,
    [Parameter(Mandatory=$true,Position=3)][string]$EmailTo,
    [Parameter(Mandatory=$true,Position=4)][string]$EmailSubject
  )

  Process {
    Try {
      $sBody = ( Get-Content $LogPath | Out-String )

      #Create SMTP object and send email
      $oSmtp = new-object Net.Mail.SmtpClient( $SMTPServer )
      $oSmtp.Send( $EmailFrom, $EmailTo, $EmailSubject, $sBody )
      Exit 0
    }

    Catch {
      Exit 1
    }
  }
}