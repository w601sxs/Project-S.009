### Step 1: Install libewbp and add bin folder to path
### Step 2: Install 7zip and add to path
###
### Change Watcher.Path
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = "Path\To\webpwatcherscript\" 
    $watcher.Filter = "*.*"
    $watcher.IncludeSubdirectories = $true
    $watcher.EnableRaisingEvents = $true  

### Action definition function (Comment out compression if not neecssary)
    $action = { $path = $Event.SourceEventArgs.FullPath
                $changeType = $Event.SourceEventArgs.ChangeType
		$name = $Event.SourceEventArgs.Name
		If ($name -Like "*.jpg" -or $name -Like "*.jpeg" -or $name -Like "*.tiff" -or $name -Like "*.png"){
			$timeStamp = $Event.TimeGenerated
			$logline = "$(Get-Date), $changeType, $path"
			Write-Host "The file '$name' was $changeType at $timeStamp"
			$newname = [System.IO.Path]::GetDirectoryName($path) +"\"+ [System.IO.Path]::GetFileNameWithoutExtension($path)+".webp"
			$newnamezip = [System.IO.Path]::GetDirectoryName($path) +"\"+ [System.IO.Path]::GetFileNameWithoutExtension($path)+".tgz"
			cwebp -q 25 $path -o $newname -mt
			Write-Host "New file written to $newname" -fore green
			7z a $newnamezip $newname
			Write-Host "... and compressed to $newnamezip" -fore Magenta

		} ElseIf ($name -Like "*.pdf") {
			Write-Host "Compressing pdf..."
			$newnamezip = [System.IO.Path]::GetDirectoryName($path) +"\"+ [System.IO.Path]::GetFileNameWithoutExtension($path)+".tgz"
			7z a $newnamezip $path
			Write-Host "Compressed to $newnamezip" -fore Magenta
		} Else {
			Write-Host "Not an image, ignoring..." -fore red
		}
              }

### DECIDE WHICH EVENTS SHOULD BE WATCHED 
    Register-ObjectEvent $watcher "Created" -Action $action
    Register-ObjectEvent $watcher "Changed" -Action $action
### Register-ObjectEvent $watcher "Deleted" -Action $action
    Register-ObjectEvent $watcher "Renamed" -Action $action
while ($true) {sleep 1}