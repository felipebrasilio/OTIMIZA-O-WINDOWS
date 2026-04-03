@echo off
:: Script de Automação de Tarefas para Técnicos em Informática
:: Execute como Administrador

color 2
mode con: cols=80 lines=25
title Automação de Tarefas de TI - FBRASILIO V1.0

:: Verificar se o script está sendo executado como administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERRO] Este script deve ser executado como administrador.
    pause
    exit /b
)

:: Cabeçalho
echo =====================================================================
echo                    Powered by FBRASILIO V1.0              
echo SCRIPT DE AUTOMACAO DE TAREFAS PARA TECNICOS EM INFORMATICA.
echo                        ITENS EXECUTADOS:
echo                              '
echo [*] LIMPEZA DE ARQUIVOS TEMPORARIOS:
echo     - Limpa arquivos temporários do sistema e de usuários.
echo                              '
echo [*] LIMPEZA DE CACHE DE NAVEGADORES:
echo     - Limpa cache dos navegadores Chrome, Firefox, Edge e Brave.
echo                              '
echo [*] VERIFICACAO DE INTEGRIDADE DO SISTEMA:
echo     - Verifica e corrige arquivos do sistema corrompidos (SFC e DISM).
echo                              '
echo [*] OTIMIZACAO DE DISCO:
echo     - Limpa arquivos desnecessários e desfragmenta o disco (se HDD).
echo                              '
echo [*] ATUALIZACAO DE POLITICAS DE GRUPO:
echo     - Atualiza as políticas de grupo (gpupdate /force).
echo                              '
echo [*] REINICIALIZACAO DO SISTEMA:
echo     - Reinicia o computador após a execução.
echo                              '
echo =====================================================================
echo INICIAR AUTOMACAO DE TAREFAS
pause

:: Limpeza de arquivos temporários
echo [*] Limpando arquivos temporários do sistema...
del /f /s /q %systemdrive%\*.tmp
del /f /s /q %systemdrive%\*.log
del /f /s /q %systemdrive%\*.old
del /f /s /q %systemdrive%\*.chk
del /f /s /q %windir%\Temp\*.*
del /f /s /q %userprofile%\AppData\Local\Temp\*.*

:: Limpeza de cache de navegadores
echo [*] Limpando cache de navegadores...
if exist "%LocalAppData%\Google\Chrome\User Data\Default\Cache" (
    rmdir /s /q "%LocalAppData%\Google\Chrome\User Data\Default\Cache"
)
if exist "%LocalAppData%\Mozilla\Firefox\Profiles" (
    for /d %%i in ("%LocalAppData%\Mozilla\Firefox\Profiles\*") do (
        if exist "%%i\cache2" rmdir /s /q "%%i\cache2"
    )
)
if exist "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache" (
    rmdir /s /q "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache"
)
if exist "%LocalAppData%\BraveSoftware\Brave-Browser\User Data\Default\Cache" (
    rmdir /s /q "%LocalAppData%\BraveSoftware\Brave-Browser\User Data\Default\Cache"
)

:: Verificação de integridade do sistema
echo [*] Verificando integridade do sistema (SFC)...
sfc /scannow

echo [*] Verificando integridade do sistema (DISM)...
DISM /Online /Cleanup-Image /RestoreHealth

:: Otimização de disco
echo [*] Otimizando disco (limpeza e desfragmentação)...
cleanmgr /sagerun:1
if exist "%systemdrive%\pagefile.sys" (
    echo [*] Desfragmentando disco (se HDD)...
    defrag %systemdrive% /U /V
)

:: Atualização de políticas de grupo
echo [*] Atualizando políticas de grupo...
gpupdate /force

:: Reinicialização do sistema
echo [*] Reiniciando o computador...
shutdown /r /t 0

:: Finalização
echo =====================================================================
echo                    AUTOMACAO DE TAREFAS CONCLUIDA    
echo =====================================================================
exit