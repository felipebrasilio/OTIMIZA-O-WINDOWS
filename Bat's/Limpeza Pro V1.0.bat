@echo off
:: Script de Limpeza de Computador Avançado
:: Execute como Administrador

color 2
mode con: cols=80 lines=25
title Limpeza de Computador - FBRASILIO V2.0

:: Cabeçalho
echo =====================================================================
echo                    Powered by FBRASILIO V2.0              
echo SCRIPT DE LIMPEZA DE ARQUIVOS TEMPORARIOS E CACHE DE NAVEGADORES.
echo                        ITENS REMOVIDOS:
echo                              '
echo [*] ARQUIVOS TEMPORARIOS DO SISTEMA:
echo     - %windir%\Temp
echo     - %windir%\repair
echo     - %windir%\Installer
echo     - %userprofile%\*.tmp
echo     - %ALLUSERSPROFILE%\*.tmp
echo     - %windir%\system32\dllcache
echo     - %windir%\system32\ReinstallBackups
echo     - %systemdrive%\MSOCache
echo     - %HOMEPATH%\Config~1\Temp
echo     - %SystemDrive%\*.tmp, *.log, *.old, *.chk
echo                              '
echo [*] LOGS DE ERROS DO WINDOWS (WER):
echo     - %SystemRoot%\System32\winevt\Logs
echo     - %userprofile%\AppData\Local\Microsoft\Windows\WER\ReportArchive
echo                              '
echo [*] CACHE DE NAVEGADORES:
echo     - Brave Browser: %LocalAppData%\BraveSoftware\Brave-Browser\User Data\Default\Cache
echo     - Google Chrome: %LocalAppData%\Google\Chrome\User Data\Default\Cache
echo     - Firefox: %LocalAppData%\Mozilla\Firefox\Profiles\*\cache2
echo     - Microsoft Edge: %LocalAppData%\Microsoft\Edge\User Data\Default\Cache
echo     - Opera: %LocalAppData%\Opera Software\Opera Stable\Cache
echo     - Vivaldi: %LocalAppData%\Vivaldi\User Data\Default\Cache
echo                              '
echo [*] CACHE DE USUARIOS:
echo     - %SystemDrive%\Users\*\AppData\Local\Temp
echo     - %SystemDrive%\Users\*\AppData\Local\Microsoft\Windows\INetCache
echo                              '
echo [*] OUTRAS LIMPEZAS:
echo     - Cache do DNS (ipconfig /flushdns)
echo     - Cache do Windows Update (%SystemRoot%\SoftwareDistribution\Download)
echo     - Thumbnails (%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db)
echo                              '
echo =====================================================================
echo INICIAR LIMPEZA
pause

:: Limpeza de arquivos temporários do sistema
echo [*] Limpando arquivos temporários do sistema...
del /f /q "%windir%\Temp\*.*"
del /f /q "%windir%\repair\*.*"
del /f /q "%windir%\Installer\*.*"
del /f /q "%userprofile%\*.tmp"
del /f /q "%ALLUSERSPROFILE%\*.tmp"
del /f /s /q "%windir%\system32\dllcache\*.*"
RD /S /q "%windir%\system32\dllcache"
del /f /s /q "%windir%\system32\ReinstallBackups\*.*"
RD /S /q "%windir%\system32\ReinstallBackups"
del /f /s /q "%systemdrive%\MSOCache\*.*"
DEL "%HOMEPATH%\Config~1\Temp\*.*" /F /S /Q
RD /S /Q "%HOMEPATH%\Config~1\Temp"
MD "%HOMEPATH%\Config~1\Temp"
RD /S /Q "%windir%\Temp"
MD "%windir%\Temp"
del /s /f /q "%SystemDrive%\*.tmp"
del /s /f /q "%SystemDrive%\*.log"
del /s /f /q "%SystemDrive%\*.old"
del /s /f /q "%SystemDrive%\*.chk"

:: Limpeza de cache de navegadores
echo [*] Limpando cache de navegadores...

:: Brave Browser
echo [*] Limpando cache do Brave Browser...
if exist "%LocalAppData%\BraveSoftware\Brave-Browser\User Data\Default\Cache" (
    rmdir /s /q "%LocalAppData%\BraveSoftware\Brave-Browser\User Data\Default\Cache"
)

:: Google Chrome
echo [*] Limpando cache do Google Chrome...
if exist "%LocalAppData%\Google\Chrome\User Data\Default\Cache" (
    rmdir /s /q "%LocalAppData%\Google\Chrome\User Data\Default\Cache"
)

:: Firefox
echo [*] Limpando cache do Firefox...
if exist "%LocalAppData%\Mozilla\Firefox\Profiles" (
    for /d %%i in ("%LocalAppData%\Mozilla\Firefox\Profiles\*") do (
        if exist "%%i\cache2" rmdir /s /q "%%i\cache2"
    )
)

:: Microsoft Edge
echo [*] Limpando cache do Microsoft Edge...
if exist "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache" (
    rmdir /s /q "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache"
)

:: Opera
echo [*] Limpando cache do Opera...
if exist "%LocalAppData%\Opera Software\Opera Stable\Cache" (
    rmdir /s /q "%LocalAppData%\Opera Software\Opera Stable\Cache"
)

:: Vivaldi
echo [*] Limpando cache do Vivaldi...
if exist "%LocalAppData%\Vivaldi\User Data\Default\Cache" (
    rmdir /s /q "%LocalAppData%\Vivaldi\User Data\Default\Cache"
)

:: Limpeza de arquivos temporários de usuários
echo [*] Limpando arquivos temporários de todos os usuários...
for /d %%u in ("%SystemDrive%\Users\*") do (
    if exist "%%u\AppData\Local\Temp" rmdir /s /q "%%u\AppData\Local\Temp"
    if exist "%%u\AppData\Local\Microsoft\Windows\INetCache" rmdir /s /q "%%u\AppData\Local\Microsoft\Windows\INetCache"
    if exist "%%u\AppData\Local\Microsoft\Windows\WER\ReportArchive" rmdir /s /q "%%u\AppData\Local\Microsoft\Windows\WER\ReportArchive"
)

:: Limpeza de logs de erros do Windows (WER)
echo [*] Limpando logs de erros do Windows (WER)...
if exist "%SystemRoot%\System32\winevt\Logs" (
    del /f /s /q "%SystemRoot%\System32\winevt\Logs\*.*"
)

:: Limpeza de cache do Windows Update
echo [*] Limpando cache do Windows Update...
if exist "%SystemRoot%\SoftwareDistribution\Download" (
    rmdir /s /q "%SystemRoot%\SoftwareDistribution\Download"
)

:: Limpeza de cache do DNS
echo [*] Limpando cache do DNS...
ipconfig /flushdns

:: Limpeza de cache do Thumbnails
echo [*] Limpando cache de Thumbnails...
if exist "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db" (
    del /f /q "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db"
)

:: Finalização
echo =====================================================================
echo                    LIMPEZA FINALIZADA COM SUCESSO    
echo =====================================================================
pause

:: Reinicialização opcional
set /p restart="[*] Deseja reiniciar o computador agora? (S/N): "
if /i "%restart%"=="S" (
    echo [*] Reiniciando o computador...
    shutdown /r /t 0
) else (
    echo [*] Limpeza concluída. Reinicialize manualmente se necessário.
)

exit