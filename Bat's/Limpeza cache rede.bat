@echo off
:: Script de Limpeza de Cache de Rede Avançado
:: Execute como Administrador

echo [*] Iniciando limpeza de cache de rede...

:: Liberar o endereco IP atual
echo [*] Liberando o endereco IP atual...
ipconfig /release

:: Limpar o cache DNS
echo [*] Limpando o cache DNS...
ipconfig /flushdns

:: Parar servicos de DNS e DHCP
echo [*] Parando o servico de cache DNS...
net stop dnscache >nul 2>&1

echo [*] Parando o servico DHCP...
net stop dhcp >nul 2>&1

:: Reiniciar servicos de DNS e DHCP
echo [*] Reiniciando o servico de cache DNS...
net start dnscache >nul 2>&1

echo [*] Reiniciando o servico DHCP...
net start dhcp >nul 2>&1

:: Registrar novamente o DNS
echo [*] Registrando o DNS novamente...
ipconfig /registerdns

:: Renovar o endereco IP
echo [*] Renovando o endereco IP...
ipconfig /renew

:: Limpar cache ARP
echo [*] Limpando o cache ARP...
arp -d *
netsh interface ip delete arpcache

:: Limpar cache de destino
echo [*] Limpando o cache de destino...
netsh interface ip delete destinationcache

:: Limpar cache NetBIOS
echo [*] Limpando o cache NetBIOS...
nbtstat -R
nbtstat -RR

:: Resetar configuracoes de IP
echo [*] Resetando as configuracoes de IP...
netsh int ip reset >nul 2>&1

:: Resetar o catalogo Winsock
echo [*] Resetando o catalogo Winsock...
netsh winsock reset catalog >nul 2>&1

:: Resetar todas as configuracoes Winsock
echo [*] Resetando todas as configuracoes Winsock...
netsh winsock reset >nul 2>&1

:: Verificar e reparar Winsock (opcional)
echo [*] Verificando e reparando Winsock...
netsh winsock show catalog >nul 2>&1

:: Perguntar se deseja reiniciar o computador
set /p restart="[*] Deseja reiniciar o computador agora? (S/N): "
if /i "%restart%"=="S" (
    echo [*] Reiniciando o computador...
    shutdown /r /t 0
) else (
    echo [*] Limpeza de cache de rede concluída. Reinicialize manualmente se necessário.
)

:: Finalizar script
exit
