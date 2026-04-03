@echo off
:: Script para Verificar e Corrigir Erros no Disco
:: Execute como Administrador

color 2
mode con: cols=80 lines=25
title Verificar e Corrigir Erros no Disco - FBRASILIO V1.0

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
echo SCRIPT PARA VERIFICAR E CORRIGIR ERROS NO DISCO.
echo                        ITENS EXECUTADOS:
echo                              '
echo [*] VERIFICAR E CORRIGIR ERROS NO DISCO:
echo     - Executa o comando CHKDSK para verificar e corrigir erros.
echo                              '
echo [*] OBSERVACOES:
echo     - O processo pode demorar dependendo do tamanho do disco.
echo     - Reinicie o computador após a execução para garantir que as alterações sejam aplicadas.
echo                              '
echo =====================================================================
echo INICIAR VERIFICACAO E CORRECAO DE ERROS NO DISCO
pause

:: Verificar e corrigir erros no disco
echo [*] Verificando e corrigindo erros no disco...
chkdsk %systemdrive% /f /r

:: Reinicialização do sistema
echo [*] Reiniciando o computador...
shutdown /r /t 0

:: Finalização
echo =====================================================================
echo                    VERIFICACAO E CORRECAO DE ERROS CONCLUIDA    
echo =====================================================================
exit