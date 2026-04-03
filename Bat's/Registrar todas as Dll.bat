@echo off
:: Script para Registrar Todas as DLLs no Sistema
:: Execute como Administrador

color 2
mode con: cols=80 lines=25
title Registrar DLLs - FBRASILIO V1.0

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
echo SCRIPT PARA REGISTRAR TODAS AS DLLs NO SISTEMA.
echo                        ITENS EXECUTADOS:
echo                              '
echo [*] REGISTRAR DLLs DE 64 BITS:
echo     - Registra todas as DLLs no diretorio C:\ usando regsvr32 (System32).
echo                              '
echo [*] REGISTRAR DLLs DE 32 BITS:
echo     - Registra todas as DLLs no diretorio C:\ usando regsvr32 (SysWOW64).
echo                              '
echo [*] OBSERVACOES:
echo     - O processo pode demorar dependendo do numero de DLLs no sistema.
echo     - Reinicie o computador apos a execucao para garantir que as alteracoes sejam aplicadas.
echo                              '
echo =====================================================================
echo INICIAR REGISTRO DE DLLs
pause

:: Registrar DLLs de 64 bits
echo [*] Registrando DLLs de 64 bits...
FOR /R C:\ %%G IN (*.dll) DO (
    echo Registrando: %%G
    "%systemroot%\system32\regsvr32.exe" /s "%%G"
)

:: Registrar DLLs de 32 bits
echo [*] Registrando DLLs de 32 bits...
FOR /R C:\ %%G IN (*.dll) DO (
    echo Registrando: %%G
    "%systemroot%\syswow64\regsvr32.exe" /s "%%G"
)

:: Finalização
echo =====================================================================
echo                    REGISTRO DE DLLs CONCLUIDO    
echo =====================================================================
echo [*] Reinicie o computador para garantir que as alteracoes sejam aplicadas.
pause
exit