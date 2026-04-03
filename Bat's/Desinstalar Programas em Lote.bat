@echo off
:: Script para Desinstalar Programas em Lote
:: Execute como Administrador

color 2
mode con: cols=80 lines=25
title Desinstalar Programas em Lote - FBRASILIO V1.0

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
echo SCRIPT PARA DESINSTALAR PROGRAMAS EM LOTE.
echo                        ITENS EXECUTADOS:
echo                              '
echo [*] LISTAR PROGRAMAS INSTALADOS:
echo     - Exibe a lista de programas instalados.
echo                              '
echo [*] DESINSTALAR PROGRAMAS:
echo     - Desinstala os programas selecionados.
echo                              '
echo =====================================================================
echo INICIAR DESINSTALACAO DE PROGRAMAS EM LOTE
pause

:: Listar programas instalados
echo [*] Listando programas instalados...
wmic product get name

:: Desinstalar programas
set /p programas="Digite os nomes dos programas que deseja desinstalar (separados por vírgula): "
for %%i in (%programas%) do (
    echo [*] Desinstalando %%i...
    wmic product where name="%%i" call uninstall /nointeractive
)

:: Finalização
echo =====================================================================
echo                    DESINSTALACAO DE PROGRAMAS CONCLUIDA    
echo =====================================================================
pause
exit