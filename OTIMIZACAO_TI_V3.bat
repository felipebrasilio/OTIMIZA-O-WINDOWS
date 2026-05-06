@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
title OTIMIZACAO TI
color 0A
mode con: cols=110 lines=35

REM ============================================================
REM OTIMIZACAO TI - V3 ESTAVEL
REM BAT puro com chamadas PowerShell pontuais.
REM Sem bloco interno, sem marcador, sem extracao.
REM ============================================================

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo [OTIMIZACAO TI] Solicitando permissao de administrador...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

if not exist "%ProgramData%\OtimizacaoTI\Logs" mkdir "%ProgramData%\OtimizacaoTI\Logs" >nul 2>&1
for /f %%I in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "STAMP=%%I"
set "LOG=%ProgramData%\OtimizacaoTI\Logs\OtimizacaoTI_%STAMP%.log"

call :log "============================================================"
call :log "OTIMIZACAO TI V3 iniciado"
call :log "Computador: %COMPUTERNAME%"
call :log "Usuario: %USERNAME%"
call :log "Log: %LOG%"
call :log "============================================================"

goto :menu

:banner
cls
echo.
echo ==============================================================================================================
echo                                             OTIMIZACAO TI
echo                         LIMPEZA ^| OTIMIZACAO ^| REDE ^| IMPRESSORA ^| WINDOWS
echo ==============================================================================================================
echo.
echo Log tecnico:
echo %LOG%
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
echo [5] EXECUTAR TUDO
echo [0] SAIR
echo.
set /p OP=Digite a opcao: 

if "%OP%"=="1" goto :limpeza
if "%OP%"=="2" goto :otimizacao
if "%OP%"=="3" goto :rede
if "%OP%"=="4" goto :impressora
if "%OP%"=="5" goto :tudo
if "%OP%"=="0" goto :fim

echo.
echo Opcao invalida.
timeout /t 2 >nul
goto :menu

:log
echo [%date% %time%] %~1
>>"%LOG%" echo [%date% %time%] %~1
exit /b

:run
call :log "%~1"
%~2 >>"%LOG%" 2>&1
if errorlevel 1 (
    call :log "AVISO: comando terminou com erro ou retorno diferente de zero: %~1"
) else (
    call :log "OK: %~1"
)
exit /b

:ps
call :log "%~1"
powershell -NoProfile -ExecutionPolicy Bypass -Command "%~2" >>"%LOG%" 2>&1
if errorlevel 1 (
    call :log "AVISO: PowerShell retornou erro: %~1"
) else (
    call :log "OK: %~1"
)
exit /b

:limpeza
call :banner
call :log "Modulo LIMPEZA iniciado"

echo [1/10] Fechando processos de navegadores para liberar cache...
taskkill /f /im chrome.exe >nul 2>&1
taskkill /f /im msedge.exe >nul 2>&1
taskkill /f /im brave.exe >nul 2>&1
taskkill /f /im firefox.exe >nul 2>&1
taskkill /f /im opera.exe >nul 2>&1
taskkill /f /im vivaldi.exe >nul 2>&1

echo [2/10] Limpando temporarios do Windows...
call :ps "Limpar TEMP do Windows" "$paths=@($env:TEMP,$env:TMP,(Join-Path $env:windir 'Temp')); foreach($p in $paths){ if(Test-Path -LiteralPath $p){ Get-ChildItem -LiteralPath $p -Force -ErrorAction SilentlyContinue | ForEach-Object { Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue } } }"

echo [3/10] Limpando temporarios de todos os usuarios...
call :ps "Limpar TEMP dos usuarios" "$base=Join-Path $env:SystemDrive 'Users'; $skip=@('Public','Default','Default User','All Users'); $users=Get-ChildItem -LiteralPath $base -Directory -Force -ErrorAction SilentlyContinue; foreach($u in $users){ if($skip -contains $u.Name){continue}; $paths=@('AppData\Local\Temp','AppData\Local\Microsoft\Windows\INetCache','AppData\Local\Microsoft\Windows\WebCache','AppData\Local\CrashDumps'); foreach($r in $paths){ $p=Join-Path $u.FullName $r; if(Test-Path -LiteralPath $p){ Get-ChildItem -LiteralPath $p -Force -ErrorAction SilentlyContinue | ForEach-Object { Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue } } } }"

echo [4/10] Limpando cache de navegadores...
call :ps "Limpar cache de navegadores" "$base=Join-Path $env:SystemDrive 'Users'; $skip=@('Public','Default','Default User','All Users'); $users=Get-ChildItem -LiteralPath $base -Directory -Force -ErrorAction SilentlyContinue; $rel=@('AppData\Local\Google\Chrome\User Data\Default\Cache','AppData\Local\Google\Chrome\User Data\Default\Code Cache','AppData\Local\Google\Chrome\User Data\Default\GPUCache','AppData\Local\Google\Chrome\User Data\Default\Service Worker\CacheStorage','AppData\Local\Microsoft\Edge\User Data\Default\Cache','AppData\Local\Microsoft\Edge\User Data\Default\Code Cache','AppData\Local\Microsoft\Edge\User Data\Default\GPUCache','AppData\Local\Microsoft\Edge\User Data\Default\Service Worker\CacheStorage','AppData\Local\BraveSoftware\Brave-Browser\User Data\Default\Cache','AppData\Local\BraveSoftware\Brave-Browser\User Data\Default\Code Cache','AppData\Local\BraveSoftware\Brave-Browser\User Data\Default\GPUCache','AppData\Local\Vivaldi\User Data\Default\Cache','AppData\Local\Opera Software\Opera Stable\Cache','AppData\Local\D3DSCache'); foreach($u in $users){ if($skip -contains $u.Name){continue}; foreach($r in $rel){ $p=Join-Path $u.FullName $r; if(Test-Path -LiteralPath $p){ Get-ChildItem -LiteralPath $p -Force -ErrorAction SilentlyContinue | ForEach-Object { Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue } } }; $ff=Join-Path $u.FullName 'AppData\Local\Mozilla\Firefox\Profiles'; if(Test-Path -LiteralPath $ff){ $fps=Get-ChildItem -LiteralPath $ff -Directory -ErrorAction SilentlyContinue; foreach($fp in $fps){ foreach($folder in @('cache2','startupCache')){ $p=Join-Path $fp.FullName $folder; if(Test-Path -LiteralPath $p){ Get-ChildItem -LiteralPath $p -Force -ErrorAction SilentlyContinue | ForEach-Object { Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue } } } } } }"

echo [5/10] Limpando cache do Windows Update...
net stop wuauserv /y >>"%LOG%" 2>&1
net stop bits /y >>"%LOG%" 2>&1
net stop dosvc /y >>"%LOG%" 2>&1
net stop cryptsvc /y >>"%LOG%" 2>&1
if exist "%windir%\SoftwareDistribution\Download" rd /s /q "%windir%\SoftwareDistribution\Download" >>"%LOG%" 2>&1
mkdir "%windir%\SoftwareDistribution\Download" >nul 2>&1
if exist "%ProgramData%\Microsoft\Windows\DeliveryOptimization\Cache" rd /s /q "%ProgramData%\Microsoft\Windows\DeliveryOptimization\Cache" >>"%LOG%" 2>&1
mkdir "%ProgramData%\Microsoft\Windows\DeliveryOptimization\Cache" >nul 2>&1
net start cryptsvc >>"%LOG%" 2>&1
net start dosvc >>"%LOG%" 2>&1
net start bits >>"%LOG%" 2>&1
net start wuauserv >>"%LOG%" 2>&1
call :log "OK: cache do Windows Update processado"

echo [6/10] Limpando relatorios de erro e dumps antigos...
call :ps "Limpar WER e dumps" "$paths=@((Join-Path $env:ProgramData 'Microsoft\Windows\WER\ReportArchive'),(Join-Path $env:ProgramData 'Microsoft\Windows\WER\ReportQueue'),(Join-Path $env:windir 'Minidump'),(Join-Path $env:windir 'LiveKernelReports')); foreach($p in $paths){ if(Test-Path -LiteralPath $p){ Get-ChildItem -LiteralPath $p -Force -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } | ForEach-Object { Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue } } }"

echo [7/10] Limpando miniaturas e caches graficos...
call :ps "Limpar thumbnails e icon cache" "$base=Join-Path $env:SystemDrive 'Users'; $skip=@('Public','Default','Default User','All Users'); $users=Get-ChildItem -LiteralPath $base -Directory -Force -ErrorAction SilentlyContinue; foreach($u in $users){ if($skip -contains $u.Name){continue}; $exp=Join-Path $u.FullName 'AppData\Local\Microsoft\Windows\Explorer'; if(Test-Path -LiteralPath $exp){ Get-ChildItem -LiteralPath $exp -Force -ErrorAction SilentlyContinue -Include 'thumbcache_*.db','iconcache_*.db' | ForEach-Object { Remove-Item -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue } } }"

echo [8/10] Limpando lixeira...
call :ps "Limpar lixeira" "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"

echo [9/10] Limpando componentes antigos do Windows...
dism /Online /Cleanup-Image /StartComponentCleanup >>"%LOG%" 2>&1

echo [10/10] Limpando cache DNS...
ipconfig /flushdns >>"%LOG%" 2>&1

call :log "Modulo LIMPEZA finalizado"
echo.
echo LIMPEZA FINALIZADA.
echo Log salvo em: %LOG%
echo.
call :pergunta_reinicio
pause
goto :menu

:otimizacao
call :banner
call :log "Modulo OTIMIZACAO iniciado"

echo [1/7] Criando e ativando plano de energia Desempenho Maximo...
call :ps "Ativar plano Desempenho Maximo" "$out=powercfg -duplicatescheme E9A42B02-D5DF-448D-AA00-03F14749EB61; $txt=$out -join ' '; $m=[regex]::Match($txt,'[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}'); if($m.Success){ powercfg /setactive $m.Value; Write-Output ('Plano ativo: ' + $m.Value) } else { Write-Output 'GUID nao identificado. Rode powercfg /list para validar.' }"

echo [2/7] Ajustando timeout de disco para desempenho...
powercfg /change disk-timeout-ac 0 >>"%LOG%" 2>&1
powercfg /change standby-timeout-ac 0 >>"%LOG%" 2>&1
powercfg /change hibernate-timeout-ac 0 >>"%LOG%" 2>&1

echo [3/7] Reparando imagem do Windows com DISM...
dism /Online /Cleanup-Image /RestoreHealth >>"%LOG%" 2>&1

echo [4/7] Verificando arquivos do sistema com SFC...
sfc /scannow >>"%LOG%" 2>&1

echo [5/7] Otimizando discos SSD/HDD...
call :ps "Optimize-Volume em unidades fixas" "$vols=Get-Volume -ErrorAction SilentlyContinue; foreach($v in $vols){ if($v.DriveLetter -and $v.DriveType -eq 'Fixed'){ Write-Output ('Otimizando unidade ' + $v.DriveLetter + ':'); Optimize-Volume -DriveLetter $v.DriveLetter -Verbose -ErrorAction SilentlyContinue } }"

echo [6/7] Atualizando politicas de grupo...
gpupdate /force >>"%LOG%" 2>&1

echo [7/7] Limpando DNS novamente...
ipconfig /flushdns >>"%LOG%" 2>&1

call :log "Modulo OTIMIZACAO finalizado"
echo.
echo OTIMIZACAO FINALIZADA.
echo Log salvo em: %LOG%
echo.
call :pergunta_reinicio
pause
goto :menu

:rede
call :banner
call :log "Modulo REDE iniciado"

echo [1/9] Limpando DNS...
ipconfig /flushdns >>"%LOG%" 2>&1

echo [2/9] Registrando DNS...
ipconfig /registerdns >>"%LOG%" 2>&1

echo [3/9] Liberando IP...
ipconfig /release >>"%LOG%" 2>&1

echo [4/9] Renovando IP...
ipconfig /renew >>"%LOG%" 2>&1

echo [5/9] Limpando ARP e cache de destino...
arp -d * >>"%LOG%" 2>&1
netsh interface ip delete arpcache >>"%LOG%" 2>&1
netsh interface ip delete destinationcache >>"%LOG%" 2>&1

echo [6/9] Limpando NetBIOS...
nbtstat -R >>"%LOG%" 2>&1
nbtstat -RR >>"%LOG%" 2>&1

echo [7/9] Resetando TCP/IP...
netsh int ip reset >>"%LOG%" 2>&1

echo [8/9] Resetando Winsock...
netsh winsock reset catalog >>"%LOG%" 2>&1
netsh winsock reset >>"%LOG%" 2>&1

echo [9/9] Resetando proxy WinHTTP e testando conectividade...
netsh winhttp reset proxy >>"%LOG%" 2>&1
ping 127.0.0.1 -n 2 >>"%LOG%" 2>&1
ping 8.8.8.8 -n 2 >>"%LOG%" 2>&1
ipconfig /all >>"%LOG%" 2>&1

call :log "Modulo REDE finalizado"
echo.
echo REPARO DE REDE FINALIZADO.
echo Reiniciar e recomendado apos reset de IP/Winsock.
echo Log salvo em: %LOG%
echo.
call :pergunta_reinicio
pause
goto :menu

:impressora
call :banner
call :log "Modulo IMPRESSORA iniciado"

echo [1/8] Listando impressoras instaladas...
call :ps "Inventario de impressoras" "try { $printers=Get-Printer -ErrorAction Stop; foreach($p in $printers){ Write-Output ('Impressora: ' + $p.Name + ' | Driver: ' + $p.DriverName + ' | Porta: ' + $p.PortName + ' | Status: ' + $p.PrinterStatus) } } catch { wmic printer get name,drivername,portname,printerstatus }"

echo [2/8] Removendo trabalhos presos nas filas...
call :ps "Limpar filas de impressao" "try { $printers=Get-Printer -ErrorAction Stop; foreach($p in $printers){ $jobs=Get-PrintJob -PrinterName $p.Name -ErrorAction SilentlyContinue; foreach($j in $jobs){ Remove-PrintJob -PrinterName $p.Name -ID $j.ID -ErrorAction SilentlyContinue; Write-Output ('Job removido: ' + $p.Name + ' ID ' + $j.ID) } } } catch { Write-Output 'Get-PrintJob indisponivel ou sem jobs.' }"

echo [3/8] Parando Spooler...
net stop spooler /y >>"%LOG%" 2>&1
timeout /t 2 >nul

echo [4/8] Limpando pasta de spool...
if exist "%windir%\System32\spool\PRINTERS" (
    del /f /s /q "%windir%\System32\spool\PRINTERS\*.*" >>"%LOG%" 2>&1
)

echo [5/8] Configurando Spooler como automatico...
sc config spooler start= auto >>"%LOG%" 2>&1

echo [6/8] Reiniciando servicos relacionados...
net start rpcss >>"%LOG%" 2>&1
net start spooler >>"%LOG%" 2>&1
net start fdPHost >>"%LOG%" 2>&1
net start FDResPub >>"%LOG%" 2>&1
net start SSDPSRV >>"%LOG%" 2>&1
net start upnphost >>"%LOG%" 2>&1
net start LanmanWorkstation >>"%LOG%" 2>&1

echo [7/8] Validando servico spoolsv.exe...
sfc /scanfile=%windir%\System32\spoolsv.exe >>"%LOG%" 2>&1

echo [8/8] Relatorio final de impressoras...
call :ps "Relatorio final de impressoras" "try { $printers=Get-Printer -ErrorAction Stop; foreach($p in $printers){ Write-Output ('Impressora: ' + $p.Name + ' | Offline: ' + $p.WorkOffline + ' | Status: ' + $p.PrinterStatus) } } catch { wmic printer get name,workoffline,printerstatus }"

call :log "Modulo IMPRESSORA finalizado"
echo.
echo REPARO DE IMPRESSORA FINALIZADO.
echo Foram aplicados: limpeza de fila, reset do Spooler, limpeza da pasta PRINTERS e validacao do spoolsv.exe.
echo Log salvo em: %LOG%
echo.
call :pergunta_reinicio
pause
goto :menu

:tudo
call :limpeza_sem_menu
call :otimizacao_sem_menu
call :rede_sem_menu
call :impressora_sem_menu
echo.
echo EXECUCAO COMPLETA FINALIZADA.
echo Log salvo em: %LOG%
echo.
call :pergunta_reinicio
pause
goto :menu

:limpeza_sem_menu
call :log "Execucao TUDO: LIMPEZA"
taskkill /f /im chrome.exe >nul 2>&1
taskkill /f /im msedge.exe >nul 2>&1
taskkill /f /im brave.exe >nul 2>&1
taskkill /f /im firefox.exe >nul 2>&1
taskkill /f /im opera.exe >nul 2>&1
call :ps "Limpeza geral rapida" "$paths=@($env:TEMP,$env:TMP,(Join-Path $env:windir 'Temp')); foreach($p in $paths){ if(Test-Path -LiteralPath $p){ Get-ChildItem -LiteralPath $p -Force -ErrorAction SilentlyContinue | ForEach-Object { Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue } } }; Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
net stop wuauserv /y >>"%LOG%" 2>&1
net stop bits /y >>"%LOG%" 2>&1
if exist "%windir%\SoftwareDistribution\Download" rd /s /q "%windir%\SoftwareDistribution\Download" >>"%LOG%" 2>&1
mkdir "%windir%\SoftwareDistribution\Download" >nul 2>&1
net start bits >>"%LOG%" 2>&1
net start wuauserv >>"%LOG%" 2>&1
ipconfig /flushdns >>"%LOG%" 2>&1
exit /b

:otimizacao_sem_menu
call :log "Execucao TUDO: OTIMIZACAO"
call :ps "Ativar plano Desempenho Maximo" "$out=powercfg -duplicatescheme E9A42B02-D5DF-448D-AA00-03F14749EB61; $txt=$out -join ' '; $m=[regex]::Match($txt,'[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}'); if($m.Success){ powercfg /setactive $m.Value }"
dism /Online /Cleanup-Image /StartComponentCleanup >>"%LOG%" 2>&1
dism /Online /Cleanup-Image /RestoreHealth >>"%LOG%" 2>&1
sfc /scannow >>"%LOG%" 2>&1
call :ps "Optimize-Volume" "$vols=Get-Volume -ErrorAction SilentlyContinue; foreach($v in $vols){ if($v.DriveLetter -and $v.DriveType -eq 'Fixed'){ Optimize-Volume -DriveLetter $v.DriveLetter -Verbose -ErrorAction SilentlyContinue } }"
exit /b

:rede_sem_menu
call :log "Execucao TUDO: REDE"
ipconfig /flushdns >>"%LOG%" 2>&1
ipconfig /registerdns >>"%LOG%" 2>&1
arp -d * >>"%LOG%" 2>&1
netsh interface ip delete arpcache >>"%LOG%" 2>&1
netsh int ip reset >>"%LOG%" 2>&1
netsh winsock reset >>"%LOG%" 2>&1
netsh winhttp reset proxy >>"%LOG%" 2>&1
exit /b

:impressora_sem_menu
call :log "Execucao TUDO: IMPRESSORA"
call :ps "Limpar jobs impressora" "try { $printers=Get-Printer -ErrorAction Stop; foreach($p in $printers){ $jobs=Get-PrintJob -PrinterName $p.Name -ErrorAction SilentlyContinue; foreach($j in $jobs){ Remove-PrintJob -PrinterName $p.Name -ID $j.ID -ErrorAction SilentlyContinue } } } catch {}"
net stop spooler /y >>"%LOG%" 2>&1
if exist "%windir%\System32\spool\PRINTERS" del /f /s /q "%windir%\System32\spool\PRINTERS\*.*" >>"%LOG%" 2>&1
sc config spooler start= auto >>"%LOG%" 2>&1
net start spooler >>"%LOG%" 2>&1
exit /b

:pergunta_reinicio
set /p REBOOT=Deseja reiniciar agora? [S/N]: 
if /I "%REBOOT%"=="S" (
    call :log "Reinicio solicitado pelo usuario"
    shutdown /r /t 5 /c "OTIMIZACAO TI: reinicio solicitado."
)
exit /b

:fim
call :log "OTIMIZACAO TI encerrado"
echo.
echo Encerrado. Log salvo em:
echo %LOG%
echo.
pause
exit /b 0
