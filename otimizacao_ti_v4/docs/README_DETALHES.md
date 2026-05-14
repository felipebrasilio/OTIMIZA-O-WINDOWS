# OTIMIZACAO TI V4 PLUS - Detalhes do Script Final

## Arquivos do pacote

- `OtimizacaoTI_V4_PLUS.bat`: script principal com menu em PT-BR.
- `modules/OtimizacaoTI_AI_Local.ps1`: modulo local para diagnosticar, desativar e remover recursos de IA do Windows.
- `modules/OtimizacaoTI_ClassicApps.ps1`: modulo separado para apps classicos.
- `payloads/ClassicApps/`: pasta preparada para payloads locais de apps classicos.
- `docs/ZOICWARE_RemoveWindowsAI_NOTICE.txt`: credito/licenca do projeto RemoveWindowsAI usado como referencia funcional.

## Menu final

```text
[1] LIMPEZA PROFUNDA DO WINDOWS
[2] OTIMIZACAO DE DESEMPENHO MAXIMO
[3] RESOLVER PROBLEMA DE REDE
[4] RESOLVER PROBLEMA DE IMPRESSORA
[5] REMOVER RECURSOS DE IA DO WINDOWS
[6] APPS CLASSICOS DO WINDOWS
[7] DIAGNOSTICO COMPLETO DO SISTEMA
[8] EXECUTAR MANUTENCAO RAPIDA COMPLETA
[9] EXECUTAR MANUTENCAO COMPLETA AVANCADA
[M] ALTERAR MODO DE EXECUCAO
[0] SAIR
```

## Melhorias adicionadas sobre a V3

1. Mantido o plano **Desempenho Maximo** como padrao da otimizacao.
2. Modo de execucao: COMPLETO, SEGURO e REMOTO.
3. Lock file para evitar duas execucoes simultaneas.
4. Log tecnico centralizado em `%ProgramData%\OtimizacaoTI\Logs`.
5. Contador de avisos e erros.
6. Resumo final de execucao.
7. Diagnostico inicial automatico no log.
8. Diagnostico completo no menu.
9. Confirmacao antes de fechar navegadores.
10. Confirmacao antes de esvaziar a lixeira.
11. Aviso antes de reparo de rede.
12. Modo REMOTO evita `ipconfig /release`, `ipconfig /renew`, `netsh int ip reset` e `netsh winsock reset`.
13. Testes de rede ampliados: loopback, IP publico, DNS por dominio, `nslookup` e HTTPS porta 443.
14. Limpeza de cache de navegadores ampliada para multiplos perfis Chromium/Firefox.
15. Uso padronizado de `:run` e `:ps` para logging.
16. Criacao de ponto de restauracao antes de otimizacao e rotinas pesadas quando possivel.
17. Calculo/log de espaco em disco antes/depois da limpeza.
18. Opcao para abrir log ao final.
19. Reinicio com 30 segundos em vez de 5.
20. Submenu separado para Apps Classicos.

## Modulo 5 - Remover Recursos de IA do Windows

Submenu:

```text
[1] Diagnosticar recursos de IA instalados
[2] Desativar IA por politicas e registro
[3] Remover Copilot, Recall e pacotes Appx de IA
[4] Remover pacotes CBS e arquivos protegidos de IA (avancado)
[5] Bloquear reinstalacao apos Windows Update
[6] Executar remocao completa de IA
[7] Reverter politicas/registro de IA
[0] Voltar
```

### O que cobre

- Copilot.
- Recall.
- Input Insights/dados de digitacao.
- Click To Do.
- AI Components no app Configuracoes.
- Copilot no Edge.
- AI no Office via politicas.
- Rewrite do Notepad por chave de politica/registro.
- Pacotes Appx/provisionados relacionados a IA.
- Optional Features relacionadas a Recall/AI/Copilot.
- Tarefas agendadas relacionadas a Recall/Copilot/AI.
- Pacotes CBS detectados por padroes de IA.
- Arquivos/pastas remanescentes movidos para quarentena por padrao.
- Bloqueio de reinstalacao por chaves de deprovisionamento.
- Tarefa agendada de limpeza pos-update.

### Confirmacao forte

Acoes destrutivas exigem digitar exatamente:

```text
REMOVER IA
```

## Modulo 6 - Apps Classicos do Windows

Separado do modulo de IA, conforme solicitado.

Submenu:

```text
[1] Habilitar Visualizador de Fotos classico
[2] Instalar/registrar Paint classico (payload local se existir)
[3] Instalar/registrar Ferramenta de Captura classica (payload local se existir)
[4] Instalar/registrar Bloco de Notas classico (payload local se existir)
[5] Tentar instalar Photos Legacy via winget
[6] Executar todos os apps classicos
[0] Voltar
```

### Observacao sobre binarios classicos

O pacote nao inclui binarios proprietarios do Windows. Para Paint, Snipping Tool e Notepad classicos, coloque os arquivos licenciados/localmente em:

```text
payloads/ClassicApps/mspaint/
payloads/ClassicApps/snippingtool/
payloads/ClassicApps/notepad/
```

O script copia para `%ProgramData%\OtimizacaoTI\ClassicApps` e cria atalhos no Menu Iniciar.

## Como executar

1. Extraia o ZIP.
2. Clique com botao direito em `OtimizacaoTI_V4_PLUS.bat`.
3. Selecione **Executar como administrador**.
4. Use o menu.

## Logs

Todos os logs ficam em:

```text
%ProgramData%\OtimizacaoTI\Logs
```

## Ponto de atencao

As opcoes de remocao de IA e remocao profunda CBS/arquivos alteram componentes sensiveis do Windows. O script cria backup de registro e tenta criar ponto de restauracao, mas a reversao completa de pacotes removidos pode exigir Windows Update, DISM com fonte de instalacao, reparo in-place ou reinstalacao de apps pela Microsoft Store.
