# Caminho do log
$logPath = "C:\temp\log.txt"

# Função para registrar tempo
function Log-Action {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $message"
    Add-Content -Path $logPath -Value $logEntry
}

# Limpa o log existente
if (Test-Path $logPath) {
    Remove-Item $logPath
}

# Abrir Microsoft Edge com Google
Log-Action "Starting Microsoft Edge"
Start-Process "msedge.exe" "https://www.google.com"
Start-Process "msedge.exe" "https://www.google.com"
Start-Process "msedge.exe" "https://www.google.com"
Start-Process "msedge.exe" "https://www.google.com"
Start-Process "msedge.exe" "https://www.google.com"
Start-Process "msedge.exe" "https://www.google.com"
Log-Action "Microsoft Edge started"

# Abrir Microsoft Word
Log-Action "Starting Microsoft Word"
Start-Process "winword.exe"
Log-Action "Microsoft Word started"

# Abrir Microsoft Excel
Log-Action "Starting Microsoft Excel"
Start-Process "excel.exe"
Log-Action "Microsoft Excel started"

# Abrir Microsoft PowerPoint
Log-Action "Starting Microsoft PowerPoint"
Start-Process "powerpnt.exe"
Log-Action "Microsoft PowerPoint started"

# Copiar arquivos de C:\temp para C:\temp2
Log-Action "Copying files from C:\temp to C:\temp2"
Copy-Item -Path "C:\temp\*" -Destination "C:\temp2" -Recurse
Log-Action "Files copied"

# Finaliza
Log-Action "Script completed"
