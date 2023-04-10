
# Import Active Directory module
Import-Module ActiveDirectory

# Function to perform a simple port scan
function Test-Port {
    param (
        [string]$ComputerName,
        [int]$Port
    )

    try {
        $TCPClient = New-Object System.Net.Sockets.TcpClient
        $TCPClient.Connect($ComputerName, $Port)
        $TCPClient.Close()
        return $true
    }
    catch {
        return $false
    }
}

# Get computers from the domain
$Computers = Get-ADComputer -Filter * -Properties Name | Select-Object -ExpandProperty Name

# Enumerate services, ports, and PIDs on each computer
ForEach ($Computer in $Computers) {
    Write-Host "Enumerating services and scanning ports on: $Computer"
    
    # Check if the computer is reachable
    if (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
        
        # Get the services running on the computer
        try {
            $Services = Get-WmiObject -Query "SELECT * FROM Win32_Service" -ComputerName $Computer
            Write-Host "Services on $Computer:"
            $Services | Format-Table Name, DisplayName, State, ProcessId -AutoSize

            # Port scan
            $PortsToScan = 1..1024
            Write-Host "Scanning ports on $Computer:"
            ForEach ($Port in $PortsToScan) {
                if (Test-Port -ComputerName $Computer -Port $Port) {
                    Write-Host "Port $Port is open on $Computer"
                }
            }
        }
        catch {
            Write-Host "Error retrieving services on $Computer. Please check permissions or connectivity."
        }
        
    } else {
        Write-Host "Unable to reach $Computer. Skipping..."
    }
}
