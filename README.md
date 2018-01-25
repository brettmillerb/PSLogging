# PSLogging

Forked from https://github.com/9to5IT/PSLogging

## Usage
I have tried to design this so that it can be used as an unattended log creation with the option to output to console if required for debugging.

### Start-Log
```
Start-Log -LogPath c:\scripts -LogName log.log
```

Output provides the values passed to the parameters of the function if the `-Verbose` parameter is used.
```
VERBOSE: c:\scripts
VERBOSE: log.log
VERBOSE: Removing existing log file in c:\scripts\log.log
VERBOSE: Creating new log file in c:\scripts\log.log
```

The `Start-Log` function initialises the log file as per:
```
[2018-01-25 15:55:30] Log Started processing.
```
### Write-Log
Writing information to the log file can be done in various ways:
```
Write-Log -LogPath C:\Scripts\log.log -Message 'Message to Add to Log'
```

The function automatically adds a timestamp to the beginning of the log entry
```
[2018-01-25 16:03:02] Log Started processing.
[2018-01-25 16:03:32] Message to add to log
[2018-01-25 16:03:32] Message 1
[2018-01-25 16:03:32] Message 2
[2018-01-25 16:03:32] Message 3
```

Output provides the values passed to the parameters if the `-Verbose` parameter is used
```
VERBOSE: C:\Scripts\log.log
VERBOSE: Message 4
VERBOSE: C:\Scripts\log.log
VERBOSE: Message 5
```