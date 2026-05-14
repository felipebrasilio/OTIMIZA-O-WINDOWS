<#
OTIMIZACAO TI - Modulo Local de Remocao de Recursos de IA do Windows
Inspirado no mapeamento funcional do projeto RemoveWindowsAI by zoicware.
Este modulo NAO baixa codigo remoto, NAO usa irm/iwr e executa apenas funcoes locais.
Para a licenca/credito do projeto de referencia, consulte docs/ZOICWARE_RemoveWindowsAI_NOTICE.txt.
#>
[CmdletBinding()]
param(
    [ValidateSet('Diagnose','DisablePolicies','RemoveAppxAndRecall','RemoveDeep','PreventReinstall','All','RevertPolicies')]
    [string]$Action = 'Diagnose',
    [string]$LogPath = "$env:ProgramData\OtimizacaoTI\Logs\OtimizacaoTI_AI.log",
    [string]$ConfirmText = '',
    [switch]$SkipRestorePoint,
    [switch]$PurgeFiles
)

$ErrorActionPreference = 'Continue'
$BaseDir = Join-Path $env:ProgramData 'OtimizacaoTI'
$BackupDir = Join-Path $BaseDir 'Backups\AI'
$QuarantineDir = Join-Path $BaseDir 'Quarantine\AI'
$ModuleInstallDir = Join-Path $BaseDir 'Modules'
New-Item -ItemType Directory -Force -Path $BackupDir,$QuarantineDir,$ModuleInstallDir | Out-Null

function Write-OTILog {
    param([string]$Message,[ValidateSet('INFO','OK','WARN','ERROR')]$Level='INFO')
    $line = '[{0}] [{1}] {2}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Level, $Message
    Write-Host $line
    Add-Content -Path $LogPath -Value $line -Encoding UTF8 -ErrorAction SilentlyContinue
}
function Assert-Admin {
    $p = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-OTILog 'Execute como administrador.' 'ERROR'
        exit 1
    }
}
function Assert-WindowsPowerShell51 {
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        Write-OTILog 'PowerShell 7+ nao suportado para este modulo. Use powershell.exe Windows PowerShell 5.1.' 'ERROR'
        exit 1
    }
    if ($ExecutionContext.SessionState.LanguageMode -ne 'FullLanguage') {
        Write-OTILog "PowerShell em modo $($ExecutionContext.SessionState.LanguageMode). Necessario FullLanguage." 'ERROR'
        exit 1
    }
}
function Invoke-Native {
    param([string]$FilePath,[string[]]$Arguments,[string]$Description)
    Write-OTILog "Executando: $Description"
    try {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $FilePath
        $psi.Arguments = ($Arguments -join ' ')
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.UseShellExecute = $false
        $p = [System.Diagnostics.Process]::Start($psi)
        $out = $p.StandardOutput.ReadToEnd()
        $err = $p.StandardError.ReadToEnd()
        $p.WaitForExit()
        if ($out) { Add-Content -Path $LogPath -Value $out -Encoding UTF8 }
        if ($err) { Add-Content -Path $LogPath -Value $err -Encoding UTF8 }
        if ($p.ExitCode -ne 0) { Write-OTILog "Retorno $($p.ExitCode): $Description" 'WARN' } else { Write-OTILog "OK: $Description" 'OK' }
        return $p.ExitCode
    } catch {
        Write-OTILog "Falha em $Description: $($_.Exception.Message)" 'ERROR'
        return 999
    }
}
function Export-RegKeySafe {
    param([string]$RegPath,[string]$Name)
    $file = Join-Path $BackupDir ("{0}_{1}.reg" -f (Get-Date -Format yyyyMMdd_HHmmss), ($Name -replace '[^a-zA-Z0-9_-]','_'))
    & reg.exe export $RegPath $file /y *> $null
    if ($LASTEXITCODE -eq 0) { Write-OTILog "Backup de registro criado: $file" 'OK' }
}
function New-OTIRestorePoint {
    if ($SkipRestorePoint) { Write-OTILog 'Ponto de restauracao ignorado por parametro.' 'WARN'; return }
    try {
        $vss = Get-Service VSS -ErrorAction SilentlyContinue
        if ($vss -and $vss.StartType -eq 'Disabled') { Set-Service VSS -StartupType Manual -ErrorAction SilentlyContinue }
        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
        Set-ItemProperty 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore' -Name SystemRestorePointCreationFrequency -Value 0 -Force -ErrorAction SilentlyContinue
        $name = 'OtimizacaoTI-RemoveWindowsAI-' + (Get-Date -Format 'yyyy-MM-dd-HHmm')
        Write-OTILog "Criando ponto de restauracao: $name"
        Checkpoint-Computer -Description $name -RestorePointType MODIFY_SETTINGS -ErrorAction Stop
        Write-OTILog 'Ponto de restauracao criado.' 'OK'
    } catch {
        Write-OTILog "Nao foi possivel criar ponto de restauracao: $($_.Exception.Message)" 'WARN'
    }
}
function Require-StrongConfirmation {
    param([string]$ForAction)
    if ($ConfirmText -ne 'REMOVER IA') {
        Write-OTILog "Confirmacao forte ausente para $ForAction. Use ConfirmText='REMOVER IA'." 'ERROR'
        exit 2
    }
}
function Set-RegDword {
    param([string]$Path,[string]$Name,[int]$Value)
    try {
        New-Item -Path $Path -Force -ErrorAction SilentlyContinue | Out-Null
        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType DWord -Force -ErrorAction Stop | Out-Null
        Write-OTILog "Registro: $Path\$Name = $Value" 'OK'
    } catch { Write-OTILog "Falha ao gravar registro $Path\$Name: $($_.Exception.Message)" 'WARN' }
}
function Remove-RegValueSafe {
    param([string]$Path,[string]$Name)
    try { Remove-ItemProperty -Path $Path -Name $Name -Force -ErrorAction SilentlyContinue; Write-OTILog "Registro removido: $Path\$Name" 'OK' } catch {}
}
function Add-SettingsPageVisibilityHide {
    param([string]$Page)
    $path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'
    New-Item -Path $path -Force | Out-Null
    $current = (Get-ItemProperty -Path $path -Name SettingsPageVisibility -ErrorAction SilentlyContinue).SettingsPageVisibility
    if ([string]::IsNullOrWhiteSpace($current)) { $new = "hide:$Page" }
    elseif ($current -notmatch [regex]::Escape($Page)) { $new = "$current;$Page" }
    else { $new = $current }
    New-ItemProperty -Path $path -Name SettingsPageVisibility -Value $new -PropertyType String -Force | Out-Null
    Write-OTILog "SettingsPageVisibility atualizado: $new" 'OK'
}
function Get-AIPatterns {
    @('copilot','recall','windowsai','windows.ai','client.aix','aix','aihub','windowsworkload','semantic','ai.machinelearning','mlhost','aihost')
}
function Test-NameMatchesAI {
    param([string]$Text)
    if ([string]::IsNullOrWhiteSpace($Text)) { return $false }
    foreach($p in Get-AIPatterns){ if($Text -match [regex]::Escape($p)){ return $true } }
    return $false
}
function Backup-AIRegistryAreas {
    Export-RegKeySafe 'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'HKLM_WindowsAI_Policies'
    Export-RegKeySafe 'HKCU\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'HKCU_WindowsAI_Policies'
    Export-RegKeySafe 'HKCU\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' 'HKCU_WindowsCopilot_Policies'
    Export-RegKeySafe 'HKLM\SOFTWARE\Policies\Microsoft\Edge' 'HKLM_Edge_Policies'
    Export-RegKeySafe 'HKCU\SOFTWARE\Policies\Microsoft\Edge' 'HKCU_Edge_Policies'
    Export-RegKeySafe 'HKLM\SOFTWARE\Policies\Microsoft\office' 'HKLM_Office_Policies'
}
function Disable-AIRegistryKeys {
    Write-OTILog 'Desativando chaves/politicas de IA do Windows, Copilot, Recall, Edge, Office e apps.'
    Backup-AIRegistryAreas
    foreach($hive in @('HKLM:','HKCU:')) {
        $wai = "$hive\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"
        Set-RegDword $wai 'DisableAIDataAnalysis' 1
        Set-RegDword $wai 'AllowRecallEnablement' 0
        Set-RegDword $wai 'DisableClickToDo' 1
        Set-RegDword $wai 'TurnOffSavingSnapshots' 1
        Set-RegDword $wai 'DisableSettingsAgent' 1
        Set-RegDword $wai 'DisableAgentConnectors' 1
        Set-RegDword $wai 'DisableAgentWorkspaces' 1
        Set-RegDword $wai 'DisableRemoteAgentConnectors' 1
    }
    foreach($hive in @('HKLM:','HKCU:')) {
        Set-RegDword "$hive\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" 'TurnOffWindowsCopilot' 1
        Set-RegDword "$hive\SOFTWARE\Policies\Microsoft\Windows\Explorer" 'DisableSearchBoxSuggestions' 1
    }
    Set-RegDword 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowCopilotButton' 0
    Set-RegDword 'HKCU:\Software\Microsoft\input\Settings' 'InsightsEnabled' 0
    Set-RegDword 'HKCU:\Software\Microsoft\Windows\Shell\ClickToDo' 'DisableClickToDo' 1

    foreach($hive in @('HKLM:','HKCU:')) {
        $edge = "$hive\SOFTWARE\Policies\Microsoft\Edge"
        'HubsSidebarEnabled','CopilotPageContext','EdgeHistoryAISearchEnabled','ComposeInlineEnabled','BuiltInAIAPIsEnabled','AIGenThemesEnabled','DevToolsGenAiSettings','AllowBrowsingWithCopilot','CopilotNewTabPageEnabled','M365LinksAutoOpenCopilotEnabled','SearchInSidebarEnabled','StandaloneHubsSidebarEnabled','EdgeEntraCopilotPageContext' | ForEach-Object { Set-RegDword $edge $_ 0 }
    }
    Set-RegDword 'HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common\ai\training\general' 'disabletraining' 1
    Set-RegDword 'HKCU:\SOFTWARE\Policies\Microsoft\office\16.0\common\ai\training\general' 'disabletraining' 1
    Set-RegDword 'HKCU:\Software\Microsoft\Notepad' 'RewriteEnabled' 0
    Set-RegDword 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Photos' 'DisableAI' 1
    Set-RegDword 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Paint' 'DisableAI' 1
    Add-SettingsPageVisibilityHide 'ai-components'
    Write-OTILog 'Politicas de IA aplicadas.' 'OK'
}
function Revert-AIRegistryKeys {
    Write-OTILog 'Revertendo politicas/registro de IA conhecidas. Pacotes removidos nao sao reinstalados automaticamente.'
    foreach($hive in @('HKLM:','HKCU:')) {
        $wai = "$hive\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"
        'DisableAIDataAnalysis','AllowRecallEnablement','DisableClickToDo','TurnOffSavingSnapshots','DisableSettingsAgent','DisableAgentConnectors','DisableAgentWorkspaces','DisableRemoteAgentConnectors' | ForEach-Object { Remove-RegValueSafe $wai $_ }
        Remove-RegValueSafe "$hive\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" 'TurnOffWindowsCopilot'
        Remove-RegValueSafe "$hive\SOFTWARE\Policies\Microsoft\Windows\Explorer" 'DisableSearchBoxSuggestions'
        $edge = "$hive\SOFTWARE\Policies\Microsoft\Edge"
        'HubsSidebarEnabled','CopilotPageContext','EdgeHistoryAISearchEnabled','ComposeInlineEnabled','BuiltInAIAPIsEnabled','AIGenThemesEnabled','DevToolsGenAiSettings','AllowBrowsingWithCopilot','CopilotNewTabPageEnabled','M365LinksAutoOpenCopilotEnabled','SearchInSidebarEnabled','StandaloneHubsSidebarEnabled','EdgeEntraCopilotPageContext' | ForEach-Object { Remove-RegValueSafe $edge $_ }
    }
    Remove-RegValueSafe 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowCopilotButton'
    Remove-RegValueSafe 'HKCU:\Software\Microsoft\input\Settings' 'InsightsEnabled'
    Remove-RegValueSafe 'HKCU:\Software\Microsoft\Windows\Shell\ClickToDo' 'DisableClickToDo'
    Remove-RegValueSafe 'HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common\ai\training\general' 'disabletraining'
    Remove-RegValueSafe 'HKCU:\SOFTWARE\Policies\Microsoft\office\16.0\common\ai\training\general' 'disabletraining'
    Remove-RegValueSafe 'HKCU:\Software\Microsoft\Notepad' 'RewriteEnabled'
    Write-OTILog 'Reversao basica concluida.' 'OK'
}
function Disable-CopilotPoliciesJson {
    Write-OTILog 'Procurando IntegratedServicesRegionPolicySet.json para desativar Copilot/Recall por politica regional.'
    $candidates = @(
        Join-Path $env:windir 'System32\IntegratedServicesRegionPolicySet.json',
        Join-Path $env:windir 'SysWOW64\IntegratedServicesRegionPolicySet.json'
    ) | Where-Object { Test-Path $_ }
    foreach($file in $candidates) {
        try {
            $backup = Join-Path $BackupDir ((Split-Path $file -Leaf) + '.' + (Get-Date -Format yyyyMMdd_HHmmss) + '.bak')
            Copy-Item $file $backup -Force
            $raw = Get-Content $file -Raw -ErrorAction Stop
            $new = $raw -replace '"enabled"\s*:\s*true','"enabled": false'
            if($new -ne $raw) {
                takeown.exe /f $file /a *> $null
                icacls.exe $file /grant Administrators:F *> $null
                Set-Content -Path $file -Value $new -Encoding UTF8 -Force
                Write-OTILog "Arquivo de politica atualizado: $file" 'OK'
            } else { Write-OTILog "Nenhuma alteracao necessaria em $file" 'WARN' }
        } catch { Write-OTILog "Falha ao alterar $file: $($_.Exception.Message)" 'WARN' }
    }
}
function Remove-RecallOptionalFeature {
    Write-OTILog 'Removendo recursos opcionais relacionados ao Recall.'
    try {
        $features = Get-WindowsOptionalFeature -Online -ErrorAction SilentlyContinue | Where-Object { $_.FeatureName -match 'Recall|AI|Copilot' }
        foreach($f in $features) {
            Write-OTILog "Feature encontrada: $($f.FeatureName) Estado: $($f.State)"
            if ($f.State -ne 'DisabledWithPayloadRemoved') {
                Disable-WindowsOptionalFeature -Online -FeatureName $f.FeatureName -Remove -NoRestart -ErrorAction SilentlyContinue | Out-Null
                Write-OTILog "Feature removida/desativada: $($f.FeatureName)" 'OK'
            }
        }
    } catch { Write-OTILog "Falha ao processar optional features: $($_.Exception.Message)" 'WARN' }
}
function Remove-RecallScheduledTasks {
    Write-OTILog 'Removendo tarefas agendadas relacionadas ao Recall/Copilot/AI.'
    try {
        Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object { $_.TaskName -match 'Recall|Copilot|WindowsAI|AI' -or $_.TaskPath -match 'Recall|Copilot|WindowsAI|AI' } | ForEach-Object {
            Write-OTILog "Removendo tarefa: $($_.TaskPath)$($_.TaskName)"
            Unregister-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -Confirm:$false -ErrorAction SilentlyContinue
        }
    } catch { Write-OTILog "Falha ao remover tarefas: $($_.Exception.Message)" 'WARN' }
}
function Get-AIAppxPackages {
    $all = @()
    try { $all += Get-AppxPackage -AllUsers -ErrorAction SilentlyContinue } catch {}
    try { $all += Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue } catch {}
    $all | Where-Object { Test-NameMatchesAI ($_.Name + ' ' + $_.PackageFullName + ' ' + $_.PackageName + ' ' + $_.DisplayName) } | Sort-Object PackageFullName,PackageName -Unique
}
function Remove-AIAppxPackages {
    Write-OTILog 'Removendo pacotes Appx/Provisioned relacionados a IA.'
    $packages = Get-AIAppxPackages
    if(-not $packages){ Write-OTILog 'Nenhum pacote Appx/Provisioned de IA encontrado.' 'WARN'; return }
    foreach($pkg in $packages) {
        $id = if($pkg.PackageFullName){$pkg.PackageFullName}else{$pkg.PackageName}
        Write-OTILog "Pacote IA encontrado: $id"
        if($pkg.PackageFullName) {
            try { Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -ErrorAction SilentlyContinue; Write-OTILog "Remove-AppxPackage solicitado: $id" 'OK' } catch { Write-OTILog "Falha Remove-AppxPackage $id: $($_.Exception.Message)" 'WARN' }
        }
        if($pkg.PackageName) {
            try { Remove-AppxProvisionedPackage -Online -PackageName $pkg.PackageName -ErrorAction SilentlyContinue | Out-Null; Write-OTILog "Remove-AppxProvisionedPackage solicitado: $id" 'OK' } catch { Write-OTILog "Falha Remove-AppxProvisionedPackage $id: $($_.Exception.Message)" 'WARN' }
        }
        Prevent-AppxPackageReinstall -PackageIdentity $id
    }
}
function Prevent-AppxPackageReinstall {
    param([string]$PackageIdentity)
    if([string]::IsNullOrWhiteSpace($PackageIdentity)){return}
    try {
        $safe = $PackageIdentity -replace '[\\/:*?"<>|]','_'
        $path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\$safe"
        New-Item -Path $path -Force -ErrorAction SilentlyContinue | Out-Null
        New-ItemProperty -Path $path -Name 'OtimizacaoTI' -Value 1 -PropertyType DWord -Force -ErrorAction SilentlyContinue | Out-Null
        Write-OTILog "Bloqueio de reprovisionamento registrado: $safe" 'OK'
    } catch { Write-OTILog "Falha ao bloquear reprovisionamento de $PackageIdentity: $($_.Exception.Message)" 'WARN' }
}
function Prevent-AIPackageReinstall {
    Write-OTILog 'Aplicando bloqueios de reinstalacao de pacotes IA.'
    Get-AIAppxPackages | ForEach-Object { Prevent-AppxPackageReinstall -PackageIdentity ($(if($_.PackageFullName){$_.PackageFullName}else{$_.PackageName})) }
    Install-UpdateCleanupTask
}
function Unlock-CBSPackageForRemoval {
    param([string]$PackageName)
    $reg = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\$PackageName"
    if(-not (Test-Path $reg)){ return }
    try {
        New-ItemProperty -Path $reg -Name Visibility -Value 1 -PropertyType DWord -Force -ErrorAction SilentlyContinue | Out-Null
        Remove-Item -Path (Join-Path $reg 'Owners') -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path (Join-Path $reg 'Updates') -Recurse -Force -ErrorAction SilentlyContinue
        Write-OTILog "CBS desbloqueado para tentativa de remocao: $PackageName" 'OK'
    } catch { Write-OTILog "Falha ao desbloquear CBS $PackageName: $($_.Exception.Message)" 'WARN' }
}
function Remove-AICBSPackages {
    Write-OTILog 'Procurando pacotes CBS relacionados a IA/Copilot/Recall.'
    $out = & dism.exe /Online /Get-Packages /English 2>&1
    Add-Content -Path $LogPath -Value $out -Encoding UTF8
    $ids = $out | Select-String -Pattern 'Package Identity\s*:\s*(.+)$' | ForEach-Object { $_.Matches[0].Groups[1].Value.Trim() } | Where-Object { Test-NameMatchesAI $_ } | Sort-Object -Unique
    if(-not $ids){ Write-OTILog 'Nenhum pacote CBS de IA encontrado.' 'WARN'; return }
    foreach($id in $ids) {
        Write-OTILog "Pacote CBS IA encontrado: $id"
        Unlock-CBSPackageForRemoval -PackageName $id
        Invoke-Native dism.exe @('/Online','/Remove-Package',"/PackageName:$id",'/NoRestart') "Remover CBS $id" | Out-Null
    }
}
function Move-Or-RemovePath {
    param([string]$Path)
    if(-not (Test-Path -LiteralPath $Path)){ return }
    try {
        if($PurgeFiles) {
            takeown.exe /f $Path /r /d y *> $null
            icacls.exe $Path /grant Administrators:F /t *> $null
            Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction SilentlyContinue
            Write-OTILog "Arquivo/pasta removido: $Path" 'OK'
        } else {
            $name = ($Path -replace '[:\\/ ]','_')
            $dest = Join-Path $QuarantineDir $name
            takeown.exe /f $Path /r /d y *> $null
            icacls.exe $Path /grant Administrators:F /t *> $null
            Move-Item -LiteralPath $Path -Destination $dest -Force -ErrorAction SilentlyContinue
            Write-OTILog "Arquivo/pasta movido para quarentena: $Path -> $dest" 'OK'
        }
    } catch { Write-OTILog "Falha ao processar $Path: $($_.Exception.Message)" 'WARN' }
}
function Remove-AIFiles {
    Write-OTILog 'Processando arquivos/pastas remanescentes de IA. Por padrao move para quarentena; use -PurgeFiles para remover.'
    $roots = @(
        Join-Path $env:windir 'SystemApps',
        Join-Path $env:ProgramFiles 'WindowsApps',
        Join-Path $env:ProgramData 'Microsoft\Windows',
        Join-Path $env:LOCALAPPDATA 'Packages'
    ) | Where-Object { Test-Path $_ }
    foreach($root in $roots) {
        try {
            Get-ChildItem -LiteralPath $root -Force -ErrorAction SilentlyContinue | Where-Object { Test-NameMatchesAI $_.Name } | ForEach-Object { Move-Or-RemovePath -Path $_.FullName }
        } catch { Write-OTILog "Falha ao varrer $root: $($_.Exception.Message)" 'WARN' }
    }
    $users = Get-ChildItem (Join-Path $env:SystemDrive 'Users') -Directory -Force -ErrorAction SilentlyContinue | Where-Object { $_.Name -notin @('Public','Default','Default User','All Users') }
    foreach($u in $users) {
        $pkg = Join-Path $u.FullName 'AppData\Local\Packages'
        if(Test-Path $pkg){ Get-ChildItem $pkg -Force -EA SilentlyContinue | Where-Object { Test-NameMatchesAI $_.Name } | ForEach-Object { Move-Or-RemovePath -Path $_.FullName } }
    }
}
function Install-UpdateCleanupTask {
    Write-OTILog 'Criando/atualizando tarefa de limpeza pos-Windows Update.'
    try {
        $target = Join-Path $ModuleInstallDir 'OtimizacaoTI_AI_Local.ps1'
        Copy-Item -LiteralPath $PSCommandPath -Destination $target -Force
        $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$target`" -Action PreventReinstall -LogPath `"$LogPath`" -SkipRestorePoint"
        $trigger1 = New-ScheduledTaskTrigger -AtStartup
        $trigger2 = New-ScheduledTaskTrigger -Daily -At 12:00
        $principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -RunLevel Highest
        Register-ScheduledTask -TaskName 'OtimizacaoTI_RemoveWindowsAI_UpdateCleanup' -Action $action -Trigger @($trigger1,$trigger2) -Principal $principal -Force | Out-Null
        Write-OTILog 'Tarefa criada: OtimizacaoTI_RemoveWindowsAI_UpdateCleanup' 'OK'
    } catch { Write-OTILog "Falha ao criar tarefa pos-update: $($_.Exception.Message)" 'WARN' }
}
function Diagnose-AI {
    Write-OTILog '===== DIAGNOSTICO DE RECURSOS DE IA ====='
    Write-OTILog "Windows: $((Get-CimInstance Win32_OperatingSystem).Caption) Build $((Get-CimInstance Win32_OperatingSystem).BuildNumber)"
    Write-OTILog "PowerShell: $($PSVersionTable.PSVersion) LanguageMode=$($ExecutionContext.SessionState.LanguageMode)"
    Write-OTILog 'Pacotes Appx/Provisioned relacionados:'
    $pkgs = Get-AIAppxPackages
    if($pkgs){ $pkgs | ForEach-Object { Write-OTILog (' - ' + ($(if($_.PackageFullName){$_.PackageFullName}else{$_.PackageName}))) } } else { Write-OTILog ' - Nenhum pacote detectado.' }
    Write-OTILog 'Optional Features relacionadas:'
    try { Get-WindowsOptionalFeature -Online -ErrorAction SilentlyContinue | Where-Object { $_.FeatureName -match 'Recall|AI|Copilot' } | ForEach-Object { Write-OTILog " - $($_.FeatureName): $($_.State)" } } catch {}
    Write-OTILog 'Tarefas agendadas relacionadas:'
    try { Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object { $_.TaskName -match 'Recall|Copilot|WindowsAI|AI' -or $_.TaskPath -match 'Recall|Copilot|WindowsAI|AI' } | ForEach-Object { Write-OTILog " - $($_.TaskPath)$($_.TaskName)" } } catch {}
    Write-OTILog '===== FIM DIAGNOSTICO DE IA ====='
}

Assert-Admin
Assert-WindowsPowerShell51
Write-OTILog "Modulo IA iniciado. Action=$Action"

switch($Action){
    'Diagnose' { Diagnose-AI }
    'DisablePolicies' { New-OTIRestorePoint; Disable-AIRegistryKeys; Disable-CopilotPoliciesJson; Diagnose-AI }
    'RemoveAppxAndRecall' { Require-StrongConfirmation 'RemoveAppxAndRecall'; New-OTIRestorePoint; Disable-AIRegistryKeys; Disable-CopilotPoliciesJson; Remove-RecallOptionalFeature; Remove-RecallScheduledTasks; Remove-AIAppxPackages; Prevent-AIPackageReinstall; Diagnose-AI }
    'RemoveDeep' { Require-StrongConfirmation 'RemoveDeep'; New-OTIRestorePoint; Remove-AICBSPackages; Remove-AIFiles; Prevent-AIPackageReinstall; Diagnose-AI }
    'PreventReinstall' { Prevent-AIPackageReinstall; Diagnose-AI }
    'All' { Require-StrongConfirmation 'All'; New-OTIRestorePoint; Disable-AIRegistryKeys; Disable-CopilotPoliciesJson; Remove-RecallOptionalFeature; Remove-RecallScheduledTasks; Remove-AIAppxPackages; Remove-AICBSPackages; Remove-AIFiles; Prevent-AIPackageReinstall; Diagnose-AI }
    'RevertPolicies' { New-OTIRestorePoint; Revert-AIRegistryKeys; Diagnose-AI }
}
Write-OTILog "Modulo IA finalizado. Action=$Action" 'OK'
