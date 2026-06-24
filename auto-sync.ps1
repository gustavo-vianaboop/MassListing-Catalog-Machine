# MassListing Catalog Machine - Auto Sync
# Monitora alteracoes no index.html e envia automaticamente ao GitHub

$projectPath = "C:\Users\mindg\Documents\MassListing-Catalog-Machine"
$ghPath = "C:\Program Files\GitHub CLI\gh.exe"

Write-Host "MassListing Auto-Sync iniciado. Monitorando alteracoes..." -ForegroundColor Cyan
Write-Host "Pasta: $projectPath" -ForegroundColor Gray
Write-Host "Pressione Ctrl+C para parar.`n" -ForegroundColor Gray

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $projectPath
$watcher.Filter = "index.html"
$watcher.NotifyFilter = [System.IO.NotifyFilters]::LastWrite
$watcher.EnableRaisingEvents = $true

$lastSync = [datetime]::MinValue

while ($true) {
    $change = $watcher.WaitForChanged([System.IO.WatcherChangeTypes]::Changed, 2000)

    if (-not $change.TimedOut) {
        $now = Get-Date
        # Debounce: aguarda 3 segundos apos ultima alteracao antes de sincronizar
        if (($now - $lastSync).TotalSeconds -gt 3) {
            $lastSync = $now
            $timestamp = $now.ToString("yyyy-MM-dd HH:mm:ss")

            Write-Host "[$timestamp] Alteracao detectada. Sincronizando..." -ForegroundColor Yellow

            Set-Location $projectPath
            git add index.html
            $status = git status --porcelain

            if ($status) {
                git commit -m "Update: $timestamp"
                git push origin master 2>&1 | Out-Null
                Write-Host "[$timestamp] Enviado ao GitHub com sucesso." -ForegroundColor Green
            } else {
                Write-Host "[$timestamp] Sem alteracoes para enviar." -ForegroundColor Gray
            }
        }
    }
}
