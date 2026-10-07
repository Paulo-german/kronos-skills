# Fase 6 - Go-live

Objetivo: colocar o agente no ar com segurança, deixar o cliente sabendo o que fazer e acompanhar os primeiros dias.

## Checklist antes de publicar

Confira item por item, pela leitura das tools quando possível, e mostre o resultado à pessoa:

- [ ] Briefing e pendências resolvidas (ou pendências aceitas conscientemente).
- [ ] Funil do CRM, campos e motivos de perda existem (`kronos_list_pipelines`, `kronos_list_field_catalog`).
- [ ] Catálogo cadastrado e preços conferidos (`kronos_list_catalog`).
- [ ] Agente com persona, modo e funis vinculados corretos (`kronos_get_agent`).
- [ ] Funil salvo e validado; `kronos_get_publish_diff` mostra exatamente o que vai valer.
- [ ] Base de conhecimento cadastrada (interface).
- [ ] Caixa de entrada conectada (interface) e vinculada ao agente (`kronos_list_inboxes`).
- [ ] Se agenda: serviços ativos, profissionais com serviços e horários configurados (`kronos_list_professionals`); um teste de agendamento no simulador deu certo.
- [ ] Cenários do simulador testados sem problema aberto.
- [ ] Automações revisadas; as que enviam mensagem foram aprovadas.
- [ ] Alguém da equipe do cliente sabe assumir uma conversa quando o agente repassa.

Se algum item falhar, pare e resolva antes de publicar.

## Publicar

1. Mostre o resumo do que vai valer (`kronos_get_publish_diff`) e pergunte: "Posso publicar o agente [nome] agora? A partir daí ele responde clientes reais nas caixas de entrada vinculadas."
2. Só com um "sim" nesta conversa, `kronos_publish_agent`.
3. Confirme com `kronos_get_agent` que o estado é publicado.
4. Ative as automações aprovadas (`kronos_set_automation_active`), uma a uma, com o aval da pessoa.

Se algo der errado logo depois, `kronos_unpublish_agent` devolve as conversas ao atendimento humano. Ofereça isso como saída, mas só execute se a pessoa pedir.

## O que o cliente ainda faz na interface

Entregue uma lista curta e objetiva, com o que ficou fora do MCP e não foi feito na implantação (por exemplo: convidar a equipe, templates do WhatsApp, mensagens rápidas, ajustar a base de conhecimento, faturamento).

## Acompanhamento (primeiros dias)

- `kronos_get_agent_metrics`: conversas atendidas, turnos, tempo médio de resposta e erros nos últimos 7 dias. Erros acima do esperado merecem investigação.
- `kronos_list_agent_conversations`: status, etapa atual e datas das conversas (sem o conteúdo das mensagens). Procure conversas paradas na mesma etapa, muito tempo sem avançar.
- `kronos_list_deals`: negociações criadas e etapas em que estão.
- Para ajustar comportamento, volte à fase 4 (persona, orientação das etapas, critérios) e repita: validar, gravar, publicar com novo aval.
- Peça ao cliente 3 a 5 conversas reais reclamadas ou estranhas na primeira semana. Elas mostram o que ajustar melhor que qualquer teste.

## Resumo final da implantação

Entregue em um bloco só:

1. **Configurado:** funil, campos, catálogo (quantidade), agente (nome, modo, publicado), automações (nome e status).
2. **Feito pela interface:** o que foi criado fora do MCP.
3. **Pendências:** informação que faltou e quem vai trazer.
4. **Próximos passos do cliente:** com prazo sugerido.
5. **Como acompanhar:** onde olhar métricas e conversas nos primeiros 7 dias.
