@echo off
:: Script para Atribuir Permissões à Pasta de Fontes
:: Execute como Administrador

color 2
mode con: cols=80 lines=25
title Atribuir Permissões - FBRASILIO V1.0

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
echo SCRIPT PARA ATRIBUIR PERMISSOES A PASTA DE FONTES DO WINDOWS.
echo                        ITENS EXECUTADOS:
echo                              '
echo [*] ENCERRAR EXPLORER:
echo     - Encerra o processo do Explorer.exe para liberar a pasta de fontes.
echo                              '
echo [*] REMOVER ATRIBUTOS DE LEITURA E SISTEMA:
echo     - Remove os atributos de leitura e sistema da pasta de fontes.
echo                              '
echo [*] ASSUMIR PROPRIEDADE DA PASTA:
echo     - Assume a propriedade da pasta de fontes para o usuário atual.
echo                              '
echo [*] ATRIBUIR PERMISSOES:
echo     - Concede permissões totais para Administradores, Todos e Everyone.
echo                              '
echo [*] REINICIAR EXPLORER:
echo     - Reinicia o Explorer.exe para restaurar a interface gráfica.
echo                              '
echo [*] OBSERVACOES:
echo     - O processo pode demorar dependendo do número de fontes no sistema.
echo     - Reinicie o computador após a execução para garantir que as alterações sejam aplicadas.
echo                              '
echo =====================================================================
echo INICIAR ATRIBUICAO DE PERMISSOES
pause

:: Encerrar o Explorer.exe
echo [*] Encerrando o Explorer.exe...
taskkill /im explorer.exe /f

:: Remover atributos de leitura e sistema
echo [*] Removendo atributos de leitura e sistema da pasta de fontes...
attrib -r -s %systemroot%\fonts

:: Assumir propriedade da pasta de fontes
echo [*] Assumindo propriedade da pasta de fontes...
Takeown /f %systemroot%\fonts /r /d y

:: Atribuir permissões para Administradores, Todos e Everyone
echo [*] Atribuindo permissões para Administradores...
Icacls %systemroot%\fonts /grant administradores:F /inheritance:E /T

echo [*] Atribuindo permissões para Administrators...
Icacls %systemroot%\fonts /grant administrators:F /inheritance:E /T

echo [*] Atribuindo permissões para Todos...
Icacls %systemroot%\fonts /grant todos:F /inheritance:E /T

echo [*] Atribuindo permissões para Everyone...
Icacls %systemroot%\fonts /grant Everyone:F /inheritance:E /T

:: Reiniciar o Explorer.exe
echo [*] Reiniciando o Explorer.exe...
start explorer.exe

:: Finalização
echo =====================================================================
echo                    ATRIBUICAO DE PERMISSOES CONCLUIDA    
echo =====================================================================
echo [*] Reinicie o computador para garantir que as alteracoes sejam aplicadas.
pause
exit