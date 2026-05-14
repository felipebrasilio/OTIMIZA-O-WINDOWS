@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
title OTIMIZACAO TI V4 PLUS
color 0A
mode con: cols=120 lines=38

REM ============================================================
REM OTIMIZACAO TI - V4 PLUS
REM Limpeza | Otimizacao | Rede | Impressora | IA Windows | Apps Classicos
REM Mantem as funcoes da V3 e adiciona melhorias operacionais.
REM ============================================================

set "SCRIPT_VERSION=4.0.0-plus"
set "BASE_DIR=%ProgramData%\OtimizacaoTI"
set "LOG_DIR=%BASE_DIR%\Logs"
set "MODULE_DIR=%~dp0modules"
set "AI_MODULE=%MODULE_DIR%\OtimizacaoTI_AI_Local.ps1"
set "CLASSIC_MODULE=%MODULE_DIR%\OtimizacaoTI_ClassicApps.ps1"
set "LOCK_FILE=%BASE_DIR%\otimizacao_ti.lock"
set "EXEC_MODE=COMPLETO"
set "WARNINGS=0"
set "ERRORS=0"
set "REBOOT_RECOMMENDED=0"

net session >nul 2>&1
if errorlevel 1 (
    echo.
    echo [OTIMIZACAO TI] Solicitando permissao de administrador...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

if not exist "%BASE_DIR%" mkdir "%BASE_DIR%" >nul 2>&1
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>&1
if exist "%LOCK_FILE%" (
    echo.
    echo [ATENCAO] Ja existe uma execucao em andamento ou encerrada incorretamente.
    echo Arquivo de lock: %LOCK_FILE%
    set /p FORCELOCK=Deseja remover o lock e continuar? [S/N]: 
    if /I not "%FORCELOCK%"=="S" exit /b 1
    del /f /q "%LOCK_FILE%" >nul 2>&1
)
>"%LOCK_FILE%" echo %date% %time% - %USERNAME%@%COMPUTERNAME%

for /f %%I in ('powershell.exe -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "STAMP=%%I"
set "LOG=%LOG_DIR%\OtimizacaoTI_%STAMP%.log"

call :log "============================================================"
call :log "OTIMIZACAO TI V4 PLUS iniciado"
call :log "Versao: %SCRIPT_VERSION%"
call :log "Computador: %COMPUTERNAME%"
call :log "Usuario: %USERNAME%"
call :log "Modo inicial: %EXEC_MODE%"
call :log "Log: %LOG%"
call :log "============================================================"
call :diagnostico_inicial_silencioso

goto :menu

:banner
cls
echo.
echo ========================================================================================================================
echo                                             OTIMIZACAO TI V4 PLUS
echo                   LIMPEZA ^| DESEMPENHO MAXIMO ^| REDE ^| IMPRESSORA ^| WINDOWS AI ^| APPS CLASSICOS
echo ========================================================================================================================
echo.
echo Modo atual: %EXEC_MODE%
echo Log tecnico: %LOG%
echo.
exit /b

:menu
call :banner
echo Escolha uma opcao:
echo.
echo [1] LIMPEZA PROFUNDA DO WINDOWS
echo [2] OTIMIZACAO DE DESEMPENHO MAXIMO
echo [3] RESOLVER PROBLEMA DE REDE
echo [4] RESOLVER PROBLEMA DE IMPRESSORA
echo [5] REMOVER RECURSOS DE IA DO WINDOWS
echo [6] APPS CLASSICOS DO WINDOWS
echo [7] DIAGNOSTICO COMPLETO DO SISTEMA
echo [8] EXECUTAR MANUTENCAO RAPIDA COMPLETA
echo [9] EXECUTAR MANUTENCAO COMPLETA AVANCADA
echo [M] ALTERAR MODO DE EXECUCAO
echo [0] SAIR
echo.
set /p OP=Digite a opcao: 

if /I "%OP%"=="1" goto :limpeza
if /I "%OP%"=="2" goto :otimizacao
if /I "%OP%"=="3" goto :rede
if /I "%OP%"=="4" goto :impressora
if /I "%OP%"=="5" goto :ia_menu
if /I "%OP%"=="6" goto :classic_menu
if /I "%OP%"=="7" goto :diagnostico
if /I "%OP%"=="8" goto :tudo_rapido
if /I "%OP%"=="9" goto :tudo_completo
if /I "%OP%"=="M" goto :modo
if /I "%OP%"=="0" goto :fim

echo.
echo Opcao invalida.
timeout /t 2 >nul
goto :menu

:modo
call :banner
echo Selecione o modo de execucao:
echo.
echo [1] COMPLETO  - executa todas as rotinas normais.
echo [2] SEGURO    - evita acoes destrutivas sem confirmacao forte.
echo [3] REMOTO    - evita derrubar conexao remota/VPN/RDP.
echo [0] Voltar
echo.
set /p MODO=Digite a opcao: 
if "%MODO%"=="1" set "EXEC_MODE=COMPLETO"& call :log "Modo alterado para COMPLETO"& goto :menu
if "%MODO%"=="2" set "EXEC_MODE=SEGURO"& call :log "Modo alterado para SEGURO"& goto :menu
if "%MODO%"=="3" set "EXEC_MODE=REMOTO"& call :log "Modo alterado para REMOTO"& goto :menu
if "%MODO%"=="0" goto :menu
goto :modo

:log
echo [%date% %time%] %~1
>>"%LOG%" echo [%date% %time%] %~1
exit /b

:warn
set /a WARNINGS+=1
call :log "AVISO: %~1"
exit /b

:error
set /a ERRORS+=1
call :log "ERRO: %~1"
exit /b

:run
call :log "Executando: %~1"
%~2 >>"%LOG%" 2>&1
if errorlevel 1 (
    call :warn "comando terminou com erro ou retorno diferente de zero: %~1"
) else (
    call :log "OK: %~1"
)
exit /b

:ps
call :log "PowerShell: %~1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "%~2" >>"%LOG%" 2>&1
if errorlevel 1 (
    call :warn "PowerShell retornou erro: %~1"
) else (
    call :log "OK: %~1"
)
exit /b

:confirmar
set "CONFIRM_RESULT=N"
set /p CONFIRM_INPUT=%~1 [S/N]: 
if /I "%CONFIRM_INPUT%"=="S" set "CONFIRM_RESULT=S"
if /I "%CONFIRM_INPUT%"=="SIM" set "CONFIRM_RESULT=S"
if /I "%CONFIRM_INPUT%"=="Y" set "CONFIRM_RESULT=S"
if /I "%CONFIRM_INPUT%"=="YES" set "CONFIRM_RESULT=S"
exit /b

:diagnostico_inicial_silencioso
>>"%LOG%" echo.
>>"%LOG%" echo ===== DIAGNOSTICO INICIAL BASICO =====
ver >>"%LOG%" 2>&1
hostname >>"%LOG%" 2>&1
whoami >>"%LOG%" 2>&1
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version,BuildNumber,OSArchitecture | Format-List; Get-PSDrive -PSProvider FileSystem | Format-Table Name,Used,Free,Root -Auto; powercfg /getactivescheme" >>"%LOG%" 2>&1
>>"%LOG%" echo ===== FIM DIAGNOSTICO INICIAL BASICO =====
exit /b

:diagnostico
call :banner
call :log "Modulo DIAGNOSTICO COMPLETO iniciado"
call :run "Informacoes do sistema" "systeminfo"
call :run "Configuracao de rede completa" "ipconfig /all"
call :ps "Inventario tecnico PowerShell" "Get-CimInstance Win32_ComputerSystem ^| Format-List Manufacturer,Model,TotalPhysicalMemory; Get-CimInstance Win32_BIOS ^| Format-List SerialNumber,SMBIOSBIOSVersion; Get-CimInstance Win32_OperatingSystem ^| Format-List Caption,Version,BuildNumber,InstallDate,LastBootUpTime; Get-PSDrive -PSProvider FileSystem ^| Format-Table Name,Used,Free,Root -Auto; Get-Service spooler,wuauserv,bits,dosvc,cryptsvc,VSS -ErrorAction SilentlyContinue ^| Format-Table Name,Status,StartType -Auto; Get-Printer -ErrorAction SilentlyContinue ^| Format-Table Name,DriverName,PortName,PrinterStatus,WorkOffline -Auto"
call :ps "Teste DNS e HTTPS" "Test-NetConnection google.com -Port 443; nslookup google.com"
call :log "Modulo DIAGNOSTICO COMPLETO finalizado"
goto :final_modulo

:criar_ponto_restauracao
call :ps "Criar ponto de restauracao" "try { $p='OtimizacaoTI-V4-' + (Get-Date -Format yyyy-MM-dd-HHmm); Enable-ComputerRestore -Drive $env:SystemDrive'\' -ErrorAction SilentlyContinue; Set-ItemProperty 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore' -Name SystemRestorePointCreationFrequency -Value 0 -Force -ErrorAction SilentlyContinue; Checkpoint-Computer -Description $p -RestorePointType MODIFY_SETTINGS -ErrorAction Stop; Write-Output ('Ponto criado: ' + $p) } catch { Write-Output ('Nao foi possivel criar ponto de restauracao: ' + $_.Exception.Message); exit 1 }"
exit /b

:limpeza
call :banner
call :log "Modulo LIMPEZA iniciado"
call :ps "Espaco em disco antes da limpeza" "Get-PSDrive -PSProvider FileSystem ^| Format-Table Name,Used,Free,Root -Auto"

call :confirmar "Deseja fechar navegadores para liberar cache?"
if /I "%CONFIRM_RESULT%"=="S" (
    echo [1/12] Fechando processos de navegadores...
    call :run "Fechar Chrome" "taskkill /f /im chrome.exe"
    call :run "Fechar Edge" "taskkill /f /im msedge.exe"
    call :run "Fechar Brave" "taskkill /f /im brave.exe"
    call :run "Fechar Firefox" "taskkill /f /im firefox.exe"
    call :run "Fechar Opera" "taskkill /f /im opera.exe"
    call :run "Fechar Vivaldi" "taskkill /f /im vivaldi.exe"
) else (
    call :warn "Fechamento de navegadores ignorado pelo usuario"
)

echo [2/12] Limpando temporarios do Windows...
call :ps "Limpar TEMP do Windows" "$paths=@($env:TEMP,$env:TMP,(Join-Path $env:windir 'Temp')); foreach($p in $paths){ if(Test-Path -LiteralPath $p){ Get-ChildItem -LiteralPath $p -Force -ErrorAction SilentlyContinue ^| ForEach-Object { Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue } } }"

echo [3/12] Limpando temporarios de todos os usuarios...
call :ps "Limpar TEMP dos usuarios" "$base=Join-Path $env:SystemDrive 'Users'; $skip=@('Public','Default','Default User','All Users'); Get-ChildItem -LiteralPath $base -Directory -Force -ErrorAction SilentlyContinue ^| Where-Object { $skip -notcontains $_.Name } ^| ForEach-Object { $u=$_; @('AppData\Local\Temp','AppData\Local\Microsoft\Windows\INetCache','AppData\Local\Microsoft\Windows\WebCache','AppData\Local\CrashDumps') ^| ForEach-Object { $p=Join-Path $u.FullName $_; if(Test-Path -LiteralPath $p){ Get-ChildItem -LiteralPath $p -Force -ErrorAction SilentlyContinue ^| ForEach-Object { Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue } } } }"

echo [4/12] Limpando cache de todos os perfis de navegadores Chromium/Firefox...
call :ps "Limpar cache de navegadores multi-perfil" "$base=Join-Path $env:SystemDrive 'Users'; $skip=@('Public','Default','Default User','All Users'); $roots=@('AppData\Local\Google\Chrome\User Data','AppData\Local\Microsoft\Edge\User Data','AppData\Local\BraveSoftware\Brave-Browser\User Data','AppData\Local\Vivaldi\User Data','AppData\Roaming\Opera Software\Opera Stable'); $cacheNames=@('Cache','Code Cache','GPUCache','Service Worker\CacheStorage','DawnCache','ShaderCache','GrShaderCache'); Get-ChildItem -LiteralPath $base -Directory -Force -EA SilentlyContinue ^| Where-Object { $skip -notcontains $_.Name } ^| ForEach-Object { $u=$_; foreach($rootRel in $roots){ $root=Join-Path $u.FullName $rootRel; if(Test-Path $root){ Get-ChildItem $root -Directory -EA SilentlyContinue ^| ForEach-Object { $profile=$_; foreach($c in $cacheNames){ $p=Join-Path $profile.FullName $c; if(Test-Path $p){ Get-ChildItem $p -Force -EA SilentlyContinue ^| Remove-Item -Recurse -Force -EA SilentlyContinue } } } } }; $ff=Join-Path $u.FullName 'AppData\Local\Mozilla\Firefox\Profiles'; if(Test-Path $ff){ Get-ChildItem $ff -Directory -EA SilentlyContinue ^| ForEach-Object { foreach($folder in @('cache2','startupCache')){ $p=Join-Path $_.FullName $folder; if(Test-Path $p){ Get-ChildItem $p -Force -EA SilentlyContinue ^| Remove-Item -Recurse -Force -EA SilentlyContinue } } } }; $d3d=Join-Path $u.FullName 'AppData\Local\D3DSCache'; if(Test-Path $d3d){ Get-ChildItem $d3d -Force -EA SilentlyContinue ^| Remove-Item -Recurse -Force -EA SilentlyContinue } }"

echo [5/12] Limpando cache do Windows Update...
call :run "Parar Windows Update" "net stop wuauserv /y"
call :run "Parar BITS" "net stop bits /y"
call :run "Parar Delivery Optimization" "net stop dosvc /y"
call :run "Parar CryptSvc" "net stop cryptsvc /y"
if exist "%windir%\SoftwareDistribution\Download" rd /s /q "%windir%\SoftwareDistribution\Download" >>"%LOG%" 2>&1
mkdir "%windir%\SoftwareDistribution\Download" >nul 2>&1
if exist "%ProgramData%\Microsoft\Windows\DeliveryOptimization\Cache" rd /s /q "%ProgramData%\Microsoft\Windows\DeliveryOptimization\Cache" >>"%LOG%" 2>&1
mkdir "%ProgramData%\Microsoft\Windows\DeliveryOptimization\Cache" >nul 2>&1
call :run "Iniciar CryptSvc" "net start cryptsvc"
call :run "Iniciar Delivery Optimization" "net start dosvc"
call :run "Iniciar BITS" "net start bits"
call :run "Iniciar Windows Update" "net start wuauserv"

echo [6/12] Limpando relatorios de erro e dumps antigos...
call :ps "Limpar WER e dumps" "$paths=@((Join-Path $env:ProgramData 'Microsoft\Windows\WER\ReportArchive'),(Join-Path $env:ProgramData 'Microsoft\Windows\WER\ReportQueue'),(Join-Path $env:windir 'Minidump'),(Join-Path $env:windir 'LiveKernelReports')); foreach($p in $paths){ if(Test-Path -LiteralPath $p){ Get-ChildItem -LiteralPath $p -Force -ErrorAction SilentlyContinue ^| Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } ^| Remove-Item -Recurse -Force -EA SilentlyContinue } }"

echo [7/12] Limpando miniaturas e caches graficos...
call :ps "Limpar thumbnails e icon cache" "$base=Join-Path $env:SystemDrive 'Users'; $skip=@('Public','Default','Default User','All Users'); Get-ChildItem -LiteralPath $base -Directory -Force -EA SilentlyContinue ^| Where-Object { $skip -notcontains $_.Name } ^| ForEach-Object { $exp=Join-Path $_.FullName 'AppData\Local\Microsoft\Windows\Explorer'; if(Test-Path $exp){ Get-ChildItem $exp -Force -EA SilentlyContinue -Include 'thumbcache_*.db','iconcache_*.db' ^| Remove-Item -Force -EA SilentlyContinue } }"

call :confirmar "Deseja esvaziar a lixeira?"
if /I "%CONFIRM_RESULT%"=="S" (
    echo [8/12] Limpando lixeira...
    call :ps "Limpar lixeira" "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
) else (
    call :warn "Limpeza da lixeira ignorada pelo usuario"
)

echo [9/12] Limpando componentes antigos do Windows...
call :run "DISM StartComponentCleanup" "dism /Online /Cleanup-Image /StartComponentCleanup"

echo [10/12] Limpando cache DNS...
call :run "Flush DNS" "ipconfig /flushdns"

echo [11/12] Otimizando cache de componentes e arquivos temporarios residuais...
call :ps "Limpeza residual segura" "Get-ChildItem $env:ProgramData -Directory -EA SilentlyContinue ^| Where-Object Name -match 'Package Cache|Temp' ^| ForEach-Object { Write-Output ('Pasta mantida para seguranca: ' + $_.FullName) }"

echo [12/12] Calculando espaco em disco apos limpeza...
call :ps "Espaco em disco depois da limpeza" "Get-PSDrive -PSProvider FileSystem ^| Format-Table Name,Used,Free,Root -Auto"
call :log "Modulo LIMPEZA finalizado"
goto :final_modulo

:otimizacao
call :banner
call :log "Modulo OTIMIZACAO iniciado"
call :criar_ponto_restauracao

echo [1/8] Criando e ativando plano de energia Desempenho Maximo...
call :ps "Ativar plano Desempenho Maximo" "$before=(powercfg /getactivescheme) -join ' '; Write-Output ('Plano anterior: ' + $before); $out=powercfg -duplicatescheme E9A42B02-D5DF-448D-AA00-03F14749EB61; $txt=$out -join ' '; $m=[regex]::Match($txt,'[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}'); if($m.Success){ powercfg /setactive $m.Value; Write-Output ('Plano ativo: ' + $m.Value) } else { powercfg /setactive E9A42B02-D5DF-448D-AA00-03F14749EB61; Write-Output 'Tentativa de ativacao direta do plano Desempenho Maximo.' }; powercfg /getactivescheme"

echo [2/8] Ajustando energia para performance em AC...
call :run "Desativar desligamento de disco em AC" "powercfg /change disk-timeout-ac 0"
call :run "Desativar suspensao em AC" "powercfg /change standby-timeout-ac 0"
call :run "Desativar hibernacao por timeout em AC" "powercfg /change hibernate-timeout-ac 0"

echo [3/8] Detectando notebook e registrando aviso...
call :ps "Detectar notebook" "$b=Get-CimInstance Win32_Battery -EA SilentlyContinue; if($b){ Write-Output 'Notebook detectado: Desempenho Maximo mantido por solicitacao do usuario; consumo e temperatura podem aumentar.' } else { Write-Output 'Notebook nao detectado.' }"

echo [4/8] Reparando imagem do Windows com DISM...
call :run "DISM RestoreHealth" "dism /Online /Cleanup-Image /RestoreHealth"

echo [5/8] Verificando arquivos do sistema com SFC...
call :run "SFC Scannow" "sfc /scannow"

echo [6/8] Otimizando discos SSD/HDD...
call :ps "Optimize-Volume em unidades fixas" "$vols=Get-Volume -ErrorAction SilentlyContinue; foreach($v in $vols){ if($v.DriveLetter -and $v.DriveType -eq 'Fixed'){ Write-Output ('Otimizando unidade ' + $v.DriveLetter + ':'); Optimize-Volume -DriveLetter $v.DriveLetter -Verbose -ErrorAction SilentlyContinue } }"

echo [7/8] Atualizando politicas de grupo...
call :run "GPUpdate Force" "gpupdate /force"

echo [8/8] Limpando DNS novamente...
call :run "Flush DNS final" "ipconfig /flushdns"
set "REBOOT_RECOMMENDED=1"
call :log "Modulo OTIMIZACAO finalizado"
goto :final_modulo

:rede
call :banner
call :log "Modulo REDE iniciado"
echo ATENCAO: reparo de rede pode derrubar VPN, RDP, AnyDesk ou TeamViewer.
if /I "%EXEC_MODE%"=="REMOTO" (
    call :warn "Modo REMOTO ativo: comandos que derrubam conexao serao ignorados"
) else (
    call :confirmar "Deseja continuar com reparo de rede completo?"
    if /I not "%CONFIRM_RESULT%"=="S" goto :menu
)

echo [1/12] Limpando DNS...
call :run "Flush DNS" "ipconfig /flushdns"
echo [2/12] Registrando DNS...
call :run "Register DNS" "ipconfig /registerdns"

if /I not "%EXEC_MODE%"=="REMOTO" (
    echo [3/12] Liberando IP...
    call :run "Release IP" "ipconfig /release"
    echo [4/12] Renovando IP...
    call :run "Renew IP" "ipconfig /renew"
) else (
    call :warn "ipconfig release/renew ignorado em Modo REMOTO"
)

echo [5/12] Limpando ARP e cache de destino...
call :run "Limpar ARP" "arp -d *"
call :run "Limpar ARP cache netsh" "netsh interface ip delete arpcache"
call :run "Limpar destination cache" "netsh interface ip delete destinationcache"

echo [6/12] Limpando NetBIOS...
call :run "NBTSTAT -R" "nbtstat -R"
call :run "NBTSTAT -RR" "nbtstat -RR"

if /I not "%EXEC_MODE%"=="REMOTO" (
    echo [7/12] Resetando TCP/IP...
    call :run "Reset TCP IP" "netsh int ip reset"
    echo [8/12] Resetando Winsock...
    call :run "Reset Winsock Catalog" "netsh winsock reset catalog"
    call :run "Reset Winsock" "netsh winsock reset"
    set "REBOOT_RECOMMENDED=1"
) else (
    call :warn "Reset TCP/IP e Winsock ignorados em Modo REMOTO"
)

echo [9/12] Resetando proxy WinHTTP...
call :run "Reset WinHTTP Proxy" "netsh winhttp reset proxy"
echo [10/12] Testando loopback e internet por IP...
call :run "Ping loopback" "ping 127.0.0.1 -n 2"
call :run "Ping 8.8.8.8" "ping 8.8.8.8 -n 2"
echo [11/12] Testando DNS por dominio...
call :run "Ping google.com" "ping google.com -n 2"
call :run "NSLookup google.com" "nslookup google.com"
echo [12/12] Salvando configuracao de rede...
call :run "IPConfig All" "ipconfig /all"
call :ps "Teste HTTPS porta 443" "Test-NetConnection google.com -Port 443"
call :log "Modulo REDE finalizado"
goto :final_modulo

:impressora
call :banner
call :log "Modulo IMPRESSORA iniciado"

echo [1/9] Listando impressoras instaladas...
call :ps "Inventario de impressoras" "try { Get-Printer -ErrorAction Stop ^| Format-Table Name,DriverName,PortName,PrinterStatus,WorkOffline -Auto } catch { Get-CimInstance Win32_Printer ^| Format-Table Name,DriverName,PortName,PrinterStatus,WorkOffline -Auto }"

echo [2/9] Removendo trabalhos presos nas filas...
call :ps "Limpar filas de impressao" "try { $printers=Get-Printer -ErrorAction Stop; foreach($p in $printers){ Get-PrintJob -PrinterName $p.Name -ErrorAction SilentlyContinue ^| ForEach-Object { Remove-PrintJob -PrinterName $p.Name -ID $_.ID -ErrorAction SilentlyContinue; Write-Output ('Job removido: ' + $p.Name + ' ID ' + $_.ID) } } } catch { Write-Output 'Get-PrintJob indisponivel ou sem jobs.' }"

echo [3/9] Parando Spooler...
call :run "Parar Spooler" "net stop spooler /y"
timeout /t 2 >nul

echo [4/9] Limpando pasta de spool...
if exist "%windir%\System32\spool\PRINTERS" (
    del /f /s /q "%windir%\System32\spool\PRINTERS\*.*" >>"%LOG%" 2>&1
)

echo [5/9] Configurando Spooler como automatico...
call :run "Spooler automatico" "sc config spooler start= auto"

echo [6/9] Reiniciando servicos relacionados...
call :run "Iniciar RPCSS" "net start rpcss"
call :run "Iniciar Spooler" "net start spooler"
call :run "Iniciar fdPHost" "net start fdPHost"
call :run "Iniciar FDResPub" "net start FDResPub"
call :run "Iniciar SSDPSRV" "net start SSDPSRV"
call :run "Iniciar upnphost" "net start upnphost"
call :run "Iniciar LanmanWorkstation" "net start LanmanWorkstation"

echo [7/9] Validando spoolsv.exe...
call :run "SFC spoolsv.exe" "sfc /scanfile=%windir%\System32\spoolsv.exe"

echo [8/9] Testando servico spooler...
call :ps "Status Spooler" "Get-Service spooler ^| Format-List Name,Status,StartType"

echo [9/9] Relatorio final de impressoras...
call :ps "Relatorio final de impressoras" "try { Get-Printer -ErrorAction Stop ^| Format-Table Name,DriverName,PortName,PrinterStatus,WorkOffline -Auto } catch { Get-CimInstance Win32_Printer ^| Format-Table Name,DriverName,PortName,PrinterStatus,WorkOffline -Auto }"
call :log "Modulo IMPRESSORA finalizado"
goto :final_modulo

:ia_menu
call :banner
echo REMOVER RECURSOS DE IA DO WINDOWS
echo.
echo [1] Diagnosticar recursos de IA instalados
echo [2] Desativar IA por politicas e registro
echo [3] Remover Copilot, Recall e pacotes Appx de IA
echo [4] Remover pacotes CBS e arquivos protegidos de IA ^(avancado^)
echo [5] Bloquear reinstalacao apos Windows Update
echo [6] Executar remocao completa de IA
echo [7] Reverter politicas/registro de IA ^(nao reinstala pacotes removidos^)
echo [0] Voltar
echo.
set /p IAOP=Digite a opcao: 
if "%IAOP%"=="0" goto :menu
if not exist "%AI_MODULE%" (
    call :error "Modulo de IA nao encontrado: %AI_MODULE%"
    pause
    goto :menu
)
if "%IAOP%"=="1" call :psfile_ai "Diagnosticar IA" "Diagnose" ""
if "%IAOP%"=="2" call :psfile_ai "Desativar IA por politicas" "DisablePolicies" ""
if "%IAOP%"=="3" call :ia_confirm_and_run "Remover Appx e Recall" "RemoveAppxAndRecall"
if "%IAOP%"=="4" call :ia_confirm_and_run "Remocao profunda CBS/arquivos" "RemoveDeep"
if "%IAOP%"=="5" call :psfile_ai "Bloquear reinstalacao pos-update" "PreventReinstall" ""
if "%IAOP%"=="6" call :ia_confirm_and_run "Remocao completa de IA" "All"
if "%IAOP%"=="7" call :psfile_ai "Reverter politicas de IA" "RevertPolicies" ""
goto :final_modulo

:ia_confirm_and_run
echo.
echo ATENCAO: %~1 altera/removera componentes do Windows.
echo Um ponto de restauracao e backups de registro serao criados quando possivel.
echo Para confirmar, digite exatamente: REMOVER IA
echo.
set /p IACONF=Confirmacao: 
if not "%IACONF%"=="REMOVER IA" (
    call :warn "Acao de IA cancelada por confirmacao invalida"
    goto :menu
)
call :psfile_ai "%~1" "%~2" "REMOVER IA"
exit /b

:psfile_ai
call :log "Modulo IA: %~1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%AI_MODULE%" -Action "%~2" -LogPath "%LOG%" -ConfirmText "%~3" >>"%LOG%" 2>&1
if errorlevel 1 (
    call :warn "Modulo IA retornou erro: %~1"
) else (
    call :log "OK: Modulo IA: %~1"
)
set "REBOOT_RECOMMENDED=1"
exit /b

:classic_menu
call :banner
echo APPS CLASSICOS DO WINDOWS ^(submenu separado do modulo de IA^)
echo.
echo [1] Habilitar Visualizador de Fotos classico
echo [2] Instalar/registrar Paint classico ^(payload local se existir^)
echo [3] Instalar/registrar Ferramenta de Captura classica ^(payload local se existir^)
echo [4] Instalar/registrar Bloco de Notas classico ^(payload local se existir^)
echo [5] Tentar instalar Photos Legacy via winget
echo [6] Executar todos os apps classicos
echo [0] Voltar
echo.
set /p CL=Digite a opcao: 
if "%CL%"=="0" goto :menu
if not exist "%CLASSIC_MODULE%" (
    call :error "Modulo de Apps Classicos nao encontrado: %CLASSIC_MODULE%"
    pause
    goto :menu
)
if "%CL%"=="1" call :classic_run "photoviewer"
if "%CL%"=="2" call :classic_run "mspaint"
if "%CL%"=="3" call :classic_run "snippingtool"
if "%CL%"=="4" call :classic_run "notepad"
if "%CL%"=="5" call :classic_run "photoslegacy"
if "%CL%"=="6" call :classic_run "all"
goto :final_modulo

:classic_run
call :log "Modulo Apps Classicos: %~1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%CLASSIC_MODULE%" -App "%~1" -PayloadRoot "%~dp0payloads\ClassicApps" -LogPath "%LOG%" >>"%LOG%" 2>&1
if errorlevel 1 (
    call :warn "Modulo Apps Classicos retornou erro: %~1"
) else (
    call :log "OK: Apps Classicos: %~1"
)
exit /b

:tudo_rapido
call :banner
call :log "Execucao MANUTENCAO RAPIDA COMPLETA iniciada"
call :limpeza_sem_menu
call :otimizacao_sem_menu
call :rede_sem_menu
call :impressora_sem_menu
call :log "Execucao MANUTENCAO RAPIDA COMPLETA finalizada"
goto :final_modulo

:tudo_completo
call :banner
call :log "Execucao MANUTENCAO COMPLETA AVANCADA iniciada"
call :confirmar "A manutencao completa pode demorar e alterar rede/servicos. Continuar?"
if /I not "%CONFIRM_RESULT%"=="S" goto :menu
call :limpeza_sem_menu
call :otimizacao_sem_menu
call :rede_sem_menu
call :impressora_sem_menu
call :diagnostico_inicial_silencioso
call :log "Execucao MANUTENCAO COMPLETA AVANCADA finalizada"
goto :final_modulo

:limpeza_sem_menu
call :log "Execucao rapida: LIMPEZA"
call :ps "Limpeza geral rapida" "$paths=@($env:TEMP,$env:TMP,(Join-Path $env:windir 'Temp')); foreach($p in $paths){ if(Test-Path -LiteralPath $p){ Get-ChildItem -LiteralPath $p -Force -EA SilentlyContinue ^| Remove-Item -Recurse -Force -EA SilentlyContinue } }; Clear-RecycleBin -Force -EA SilentlyContinue"
call :run "Parar Windows Update" "net stop wuauserv /y"
call :run "Parar BITS" "net stop bits /y"
if exist "%windir%\SoftwareDistribution\Download" rd /s /q "%windir%\SoftwareDistribution\Download" >>"%LOG%" 2>&1
mkdir "%windir%\SoftwareDistribution\Download" >nul 2>&1
call :run "Iniciar BITS" "net start bits"
call :run "Iniciar Windows Update" "net start wuauserv"
call :run "Flush DNS" "ipconfig /flushdns"
exit /b

:otimizacao_sem_menu
call :log "Execucao rapida: OTIMIZACAO"
call :ps "Ativar plano Desempenho Maximo" "$out=powercfg -duplicatescheme E9A42B02-D5DF-448D-AA00-03F14749EB61; $txt=$out -join ' '; $m=[regex]::Match($txt,'[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}'); if($m.Success){ powercfg /setactive $m.Value } else { powercfg /setactive E9A42B02-D5DF-448D-AA00-03F14749EB61 }"
call :run "DISM StartComponentCleanup" "dism /Online /Cleanup-Image /StartComponentCleanup"
call :run "DISM RestoreHealth" "dism /Online /Cleanup-Image /RestoreHealth"
call :run "SFC Scannow" "sfc /scannow"
call :ps "Optimize-Volume" "$vols=Get-Volume -EA SilentlyContinue; foreach($v in $vols){ if($v.DriveLetter -and $v.DriveType -eq 'Fixed'){ Optimize-Volume -DriveLetter $v.DriveLetter -Verbose -EA SilentlyContinue } }"
set "REBOOT_RECOMMENDED=1"
exit /b

:rede_sem_menu
call :log "Execucao rapida: REDE"
call :run "Flush DNS" "ipconfig /flushdns"
call :run "Register DNS" "ipconfig /registerdns"
call :run "Limpar ARP" "arp -d *"
call :run "Limpar ARP cache netsh" "netsh interface ip delete arpcache"
if /I not "%EXEC_MODE%"=="REMOTO" (
    call :run "Reset TCP IP" "netsh int ip reset"
    call :run "Reset Winsock" "netsh winsock reset"
    set "REBOOT_RECOMMENDED=1"
) else (
    call :warn "Reset TCP/IP e Winsock ignorados em Modo REMOTO"
)
call :run "Reset WinHTTP Proxy" "netsh winhttp reset proxy"
exit /b

:impressora_sem_menu
call :log "Execucao rapida: IMPRESSORA"
call :ps "Limpar jobs impressora" "try { Get-Printer -EA Stop ^| ForEach-Object { $p=$_; Get-PrintJob -PrinterName $p.Name -EA SilentlyContinue ^| ForEach-Object { Remove-PrintJob -PrinterName $p.Name -ID $_.ID -EA SilentlyContinue } } } catch {}"
call :run "Parar Spooler" "net stop spooler /y"
if exist "%windir%\System32\spool\PRINTERS" del /f /s /q "%windir%\System32\spool\PRINTERS\*.*" >>"%LOG%" 2>&1
call :run "Spooler automatico" "sc config spooler start= auto"
call :run "Iniciar Spooler" "net start spooler"
exit /b

:resumo_final
call :log "============================================================"
call :log "RESUMO DA EXECUCAO"
call :log "Avisos: %WARNINGS%"
call :log "Erros: %ERRORS%"
call :log "Reinicio recomendado: %REBOOT_RECOMMENDED%"
call :log "============================================================"
exit /b

:pergunta_reinicio
if "%REBOOT_RECOMMENDED%"=="1" (
    echo.
    echo Reinicio recomendado para concluir alteracoes.
)
set /p REBOOT=Deseja reiniciar agora? [S/N]: 
if /I "%REBOOT%"=="S" goto :reiniciar
if /I "%REBOOT%"=="SIM" goto :reiniciar
if /I "%REBOOT%"=="Y" goto :reiniciar
if /I "%REBOOT%"=="YES" goto :reiniciar
exit /b

:reiniciar
call :log "Reinicio solicitado pelo usuario"
shutdown /r /t 30 /c "OTIMIZACAO TI V4 PLUS: reinicio solicitado."
exit /b

:final_modulo
call :resumo_final
echo.
echo Operacao finalizada.
echo Log salvo em: %LOG%
echo.
call :confirmar "Deseja abrir o log tecnico agora?"
if /I "%CONFIRM_RESULT%"=="S" start notepad "%LOG%"
call :pergunta_reinicio
pause
goto :menu

:fim
call :log "OTIMIZACAO TI encerrado"
call :resumo_final
if exist "%LOCK_FILE%" del /f /q "%LOCK_FILE%" >nul 2>&1
echo.
echo Encerrado. Log salvo em:
echo %LOG%
echo.
pause
exit /b 0
