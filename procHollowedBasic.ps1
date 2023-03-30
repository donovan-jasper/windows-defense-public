# Get the list of running processes
$processes = Get-Process

# Loop through each process and check if it has been hollowed
foreach ($process in $processes) {

    # Get the process memory information
    $meminfo = Get-Process -Id $process.Id | Select-Object VirtualMemorySize64

    # Get the process image file path
    $path = $process.Path

    # Get the hash of the process image file
    $hash = (Get-FileHash $path).Hash

    # Check if the process has been hollowed
    $hollowed = $false
    $sections = [System.Diagnostics.ProcessModule]::GetModules($process.Id)
    foreach ($section in $sections) {
        $sectionSize = $section.ModuleMemorySize
        if ($sectionSize -lt $meminfo.VirtualMemorySize64) {
            $hollowed = $true
            break
        }
    }

    # If the process has been hollowed, print its details
    if ($hollowed) {
        Write-Host "Process $process.Name with PID $process.Id has been hollowed"
        Write-Host "Image File: $path"
        Write-Host "Image Hash: $hash"
    }
}
