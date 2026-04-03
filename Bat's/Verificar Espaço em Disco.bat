@echo off
:: Script para Verificar Espaço em Disco
:: Execute como Administrador

color 2
mode con: cols=80 lines=25
title Verificar Espaço em Disco - FBRASILIO V1.0

:: Cabeçalho
echo =====================================================================
echo                    Powered by FBRASILIO V1.0              
echo SCRIPT PARA VERIFICAR ESPACO EM DISCO.
echo                        ITENS EXECUTADOS:
echo                              '
echo [*] VERIFICAR ESPACO EM DISCO:
echo     - Exibe o espaço livre e total de todas as unidades.
echo                              '
echo =====================================================================
echo INICIAR VERIFICACAO DE ESPACO EM DISCO
pause

:: Verificar espaço em disco
echo [*] Verificando espaço em disco...
for /f "skip=1 tokens=2" %%i in ('wmic logicaldisk get size,freespace,caption') do (
    echo Unidade: %%i
    echo Espaço Livre: %%~zi
    echo Espaço Total: %%~zi
    echo.
)

:: Finalização
echo =====================================================================
echo                    VERIFICACAO DE ESPACO EM DISCO CONCLUIDA    
echo =====================================================================
pause
exit