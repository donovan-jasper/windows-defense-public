# Monitor network connections
Get-NetTCPConnection | Where-Object { $_.State -eq "Established" -and $_.RemoteAddress -notlike "0.0.0.0" -and $_.RemoteAddress -notlike "127.0.0.1" } | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess | Sort-Object RemoteAddress
