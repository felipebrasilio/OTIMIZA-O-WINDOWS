@echo off
:: Script de Reset de Políticas de Grupo (Group Policies)
:: Execute como Administrador

color 2
mode con: cols=80 lines=25
title Reset de Políticas de Grupo - FBRASILIO V1.0

:: Cabeçalho
echo =====================================================================
echo                    Powered by FBRASILIO V1.0              
echo SCRIPT DE RESET DE POLITICAS DE GRUPO (GROUP POLICIES) DO WINDOWS.
echo                        ITENS EXECUTADOS:
echo                              '
echo [*] RESTAURAR POLITICAS PADRAO:
echo     - Aplica configuracoes padrao do Windows (defltbase.inf).
echo                              '
echo [*] REMOVER POLITICAS DE USUARIOS E COMPUTADOR:
echo     - Exclui a pasta GroupPolicyUsers (%WinDir%\System32\GroupPolicyUsers).
echo     - Exclui a pasta GroupPolicy (%WinDir%\System32\GroupPolicy).
echo                              '
echo [*] ATUALIZAR POLITICAS DE GRUPO:
echo     - Forca a atualizacao das politicas de grupo (gpupdate /force).
echo                              '
echo [*] REINICIALIZACAO DO SISTEMA:
echo     - Reinicia o computador automaticamente apos a execucao.
echo                              '
echo =====================================================================
echo INICIAR RESET DE POLITICAS DE GRUPO
pause

:: Restaurar políticas padrão do Windows
echo [*] Restaurando politicas padrao do Windows...
secedit /configure /cfg %windir%\inf\defltbase.inf /db defltbase.sdb /verbose

:: Remover pastas de políticas de grupo
echo [*] Removendo pastas de politicas de grupo...
RD /S /Q "%WinDir%\System32\GroupPolicyUsers"
RD /S /Q "%WinDir%\System32\GroupPolicy"

:: Forçar atualização das políticas de grupo
echo [*] Atualizando politicas de grupo...
gpupdate /force

:: Reinicializar o computador
echo [*] Reiniciando o computador...
shutdown.exe -r -f -t 0

:: Finalização
echo =====================================================================
echo                    RESET DE POLITICAS CONCLUIDO    
echo =====================================================================
exit