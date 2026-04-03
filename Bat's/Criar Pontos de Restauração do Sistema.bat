@echo off
:: Script para Criar Pontos de Restauração do Sistema
:: Execute como Administrador

color 2
mode con: cols=80 lines=25
title Criar Ponto de Restauração - FBRASILIO V1.0

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
echo SCRIPT PARA CRIAR PONTOS DE RESTAURACAO DO SISTEMA.
echo                        ITENS EXECUTADOS:
echo                              '
echo [*] CRIAR PONTO DE RESTAURACAO:
echo     - Cria um ponto de restauração do sistema.
echo                              '
echo =====================================================================
echo INICIAR CRIACAO DE PONTO DE RESTAURACAO
pause

:: Criar ponto de restauração
echo [*] Criando ponto de restauração...
wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "Ponto de Restauração Automático", 100, 7

:: Finalização
echo =====================================================================
echo                    PONTO DE RESTAURACAO CRIADO COM SUCESSO    
echo =====================================================================
pause
exit