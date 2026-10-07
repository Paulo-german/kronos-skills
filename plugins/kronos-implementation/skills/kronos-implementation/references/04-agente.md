# Fase 4 - Agente de IA

Objetivo: um agente com persona e funil de atendimento fiéis ao briefing, validado e testado, ainda **em rascunho**. A publicação é a fase 6.

## Conteúdo

1. Criar o agente
2. Configurações
3. Desenhar o funil (no papel primeiro): campos, caminhos, ações, `scheduling`, `reengagement`
4. Validar, gravar e revisar
5. Pela interface e vínculo da caixa
6. Ajustar

## Sequência

1. Criar o agente (persona, modo, funis vinculados).
2. Ajustar configurações (espera, horário, proteção).
3. Desenhar o funil no papel e aprovar.
4. Validar, gravar e revisar.
5. Pontos da interface: conhecimento e testes. Vincular a caixa de entrada é pela tool.
6. Ajustar com base nos testes.

Antes de criar, rode `kronos_list_agents`. Se já existe agente para o mesmo fim, pergunte se é para editar.

**Se for editar um agente que já existe**, leia `kronos_get_agent` primeiro e mostre um resumo do "antes" (persona, configurações, etapas com IDs e o que está publicado). Ele é a referência para desfazer a mudança: não há restauração automática do rascunho, e só publicar faz a mudança valer para clientes.

## 1. Criar o agente

`kronos_create_agent` com:

- `name`: nome interno claro (ex.: "Atendimento comercial").
- `agentMode`: `PRODUCT` (vendas e reuniões), `SERVICE` (agendar serviços do catálogo) ou `HYBRID` (os dois). Decidido no briefing.
- `pipelineIds`: os funis do CRM em que o agente atua (IDs de `kronos_list_pipelines`). **Obrigatório** para a ação de mover negociação funcionar no funil do agente. Na edição, a lista enviada **substitui** a atual: reenvie todos os que devem ficar.
- `persona`, montada do briefing:

| Campo                              | Como preencher                                                                                                            |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| `companyDescription` (obrigatório) | O que o negócio faz, em poucas frases, com a oferta e o público. É a base do conhecimento do agente. Máx. 2000 caracteres |
| `role`                             | `sdr` (qualifica), `closer` (fecha), `support`, `receptionist` (recepção e agenda) ou `custom` + `roleCustom`             |
| `tone`                             | `formal`, `professional`, `friendly`, `casual`                                                                            |
| `salesAggressiveness`              | `consultative`, `balanced`, `persistent`, `incisive`. Na dúvida, `consultative` ou `balanced`                             |
| `responseLength`                   | `short`, `medium`, `detailed`. WhatsApp costuma pedir `short` ou `medium`                                                 |
| `emojiFrequency`                   | `none`, `low`, `medium`, `high`                                                                                           |
| `language`                         | `pt-BR` na maioria dos casos                                                                                              |
| `guidelines`                       | Regras positivas: o que sempre fazer, como tratar objeções comuns, como se dirigir ao cliente                             |
| `restrictions`                     | O que nunca fazer: não prometer prazo, não citar preço de serviço sob avaliação, não falar de concorrente                 |

Até 30 itens em `guidelines` e em `restrictions`, cada um com até 500 caracteres. Uma regra por item, em frase direta.

**Onde vai a especificidade do negócio:** nas diretrizes, restrições e na orientação de cada etapa. Nunca dependa de o agente "adivinhar" o setor.

Depois de criar, confirme com `kronos_get_agent` o estado real (ativo ou não, modo, funis vinculados, caixas de entrada vinculadas e histórico de publicações). Não afirme à pessoa que "nasce em rascunho" sem ter lido.

## 2. Configurações

`kronos_update_agent_settings` (só muda o que for informado):

- `debounceSeconds` (0 a 120): quanto esperar o cliente terminar de digitar. 8 a 15 segundos evita responder mensagem picada.
- `businessHoursEnabled`, `businessHoursTimezone` (ex.: `America/Sao_Paulo`), `businessHoursConfig` (por dia da semana, com `enabled`, `start`, `end` em HH:MM) e `outOfHoursMessage`. Só ligue se o cliente quer que o agente responda apenas em certos horários; senão ele atende 24 horas.
- `guardrailConfig`: proteção de conteúdo. Mantenha ligada.
- `modelId`: só mude se houver motivo. O padrão serve.

## 3. Desenhar o funil (no papel primeiro)

Apresente à pessoa uma tabela **antes** de qualquer tool:

| #   | Etapa | Objetivo | Campos a coletar | Para onde vai (sim/não) | Ações |
| --- | ----- | -------- | ---------------- | ----------------------- | ----- |

Regras de desenho:

- **Uma etapa, um objetivo**, em uma frase. Etapas longas viram etapas menores.
- Etapas típicas: recepção (`GREETING`), qualificação (`QUALIFICATION`), apresentação (`PRESENTATION`), agendamento (`SCHEDULING`), negociação (`NEGOTIATION`), fechamento (`CLOSING`), pós-venda (`POST_SALE`), `OTHER`. Nem todo negócio usa todas.
- **Campos por etapa:** só o que é necessário para decidir o próximo passo. Perguntar demais afasta o cliente.
- **Cada campo tem um modo:**
  - `COLLECT`: só coleta. Não trava a etapa nem decide caminho. Use para dados úteis ao CRM (nome, e-mail).
  - `REQUIRED`: **trava**: a etapa não avança sem esse dado.
  - `BRANCHING`: **direciona sem travar**: a resposta decide se o cliente segue o caminho positivo ou o negativo.
- **Critério do campo** (o que conta como resposta "boa"): lista de **opções** aceitas (`passingOptions`, com os `value` das opções do campo), uma **descrição** em linguagem natural (até 300 caracteres) ou uma **faixa** numérica (`min`, `max`, `unit`).
- **Polaridade (`resultPolarity`):** `ANY` (padrão) aceita qualquer resposta. `POSITIVE_ONLY` faz o critério valer: resposta fora dele conta como negativa e a conversa vai para `onNegativeRef`. Para qualquer campo `REQUIRED` ou `BRANCHING` que **desqualifica ou desvia**, use `POSITIVE_ONLY`, e então `onNegativeRef` é **obrigatório** na etapa (o validador recusa sem ele). Critério em campo `COLLECT` não tem efeito.
- **Caminhos:** `onPositiveRef` é para onde vai quando o cliente atende o critério; `onNegativeRef` quando não atende. Use `ref` curto e estável em cada etapa (ex.: `qualificacao`) e referencie por ele. Uma saída não pode apontar para a própria etapa.
- **Linha principal e desvios:** as etapas que não são desvio formam a linha principal, que avança na ordem em que as etapas foram declaradas. Uma etapa de **desvio** (`isBranch: true`), como "fora da área" ou "não tem interesse", fica fora dessa linha: só se chega nela por um caminho explícito (`onPositiveRef` ou `onNegativeRef`), nunca por avanço automático. Declare os desvios **depois** da linha principal. O funil precisa de pelo menos uma etapa fora dos desvios.
- **Campo reaproveitado em duas etapas com critérios diferentes causa erro de leitura.** Se a mesma informação aparece em dois pontos com critério diferente, use dois campos distintos.
- **Campos de origem:** `AGENT` é um catálogo fixo e curado de campos de qualificação (por exemplo cidade, orçamento, forma de pagamento; a lista completa e as opções vêm de `kronos_list_field_catalog`). `ENTITY_FIELD` são campos do CRM (nome ou ID do campo criado na fase 2). Use os nomes exatos. Se a informação que o cliente quer coletar não está em nenhum dos dois, crie o campo no CRM (fase 2) antes de declarar o funil.
- **Ações da etapa** (até 5, executam quando a etapa conclui):
  - `move_deal`: move a negociação para uma etapa do funil do CRM (`targetStage`). Exige funis vinculados ao agente.
  - `create_task`: cria tarefa (`title`, `dueDays`).
  - `hand_off_to_human`: `transfer` pausa a IA e passa para um humano; `notify` só avisa e a IA continua (`notifyTarget`: `none`, `deal_assignee` ou `specific_number`).
  - `update_contact_stage`: `LEAD`, `OPPORTUNITY` ou `CUSTOMER`.
- **Textos da etapa:** `name` (até 100), `goal` (até 800), `guidanceNote` (até 2000, orientações de como conduzir), `messageExamples` (até 10 exemplos de fala, cada um até 1000). Bons exemplos vêm das mensagens reais do briefing. Diga o que **fazer**; evite regras só de proibição.
- **Repasse para humano:** há dois mecanismos que se somam. (1) Escreva nas `guidelines` da persona quando o agente deve passar a conversa (o cliente pede uma pessoa, reclama, foge do escopo): o agente avalia essas diretrizes a cada turno. (2) Use a ação `hand_off_to_human` numa etapa quando o repasse é parte planejada do funil (por exemplo, ao chegar em "proposta"). Sem nenhum dos dois o agente insiste.
- **Toda rota precisa terminar em algum lugar** (agendamento, fechamento, repasse ou uma despedida clara). Nenhum caminho deve morrer no meio.

Veja `references/exemplo-clinica-agendamento.md` para um funil completo comentado.

### Agendamento na etapa (`scheduling`)

Coloque em uma etapa `SCHEDULING`.

- `mode: MEETING`: reunião na agenda do responsável. Ajuste `durationMinutes` (15, 30, 45, 60, 90 ou 120) e `window` (dias e horários agendáveis; padrão seg a sex, 09h às 18h).
- `mode: SERVICE`: serviço do catálogo na agenda do profissional. Exige agente em `SERVICE` ou `HYBRID`, e `serviceNamesOrIds` com os serviços que a etapa pode marcar (com um só, o agente não pergunta qual). `professionalPolicy`: `client_choice` (cliente pode citar o profissional) ou `auto` (distribuição automática). `createDeal` cria ou vincula negociação ao agendar. `mentionPrice` mostra o preço.
- Campos de um modo no outro modo dão erro. Não misture.
- `allowReschedule` e `onCancel` (`continue`, `route` com `onCancelRef`, ou `team`) definem o que o agente faz ao remarcar e cancelar.
- `titleTemplate` aceita `{{contact.firstName}}`, `{{contact.name}}`, `{{deal.title}}` e, em SERVICE, `{{service.name}}`.
- Os serviços precisam estar ativos no catálogo e ter profissionais e horários configurados (fase 3, `kronos_list_professionals` para conferir), senão não há vaga para oferecer.
- Garanta que todo caminho do funil que envolve marcar horário **passa por essa etapa**. Se o agendamento acontecer fora dela, as ações da etapa (mover negociação, criar tarefa) não rodam.

### Reengajamento (`reengagement`)

Retomar clientes que pararam de responder, por etapa.

- Até 5 cutucadas; cada uma com `delayMinutes` (15 minutos a 7 dias).
- `mode: scripted` (texto fixo, aceita `{{primeiro nome}}`) ou `generative` (você escolhe o ângulo, o agente escreve). Ângulos: `resume` (retomar), `reinforce` (reforçar valor), `check_in` (perguntar se ainda faz sentido), `urgency` (exige `urgencyOffer` e prazo) e `social_proof` (exige `socialProof`).
- **`urgency` e `social_proof` só com fato real informado pelo cliente** (prazo verdadeiro, depoimento verdadeiro). Nunca invente.
- Escada com intervalos crescentes e ângulos diferentes funciona melhor que repetir a mesma mensagem. Exemplo: 1 hora (retomar), 1 dia (reforçar), 3 dias (check-in).
- `exhaustedAction` quando esgotar: `none`, `notify` ou `move_deal` (com `exhaustedStage`).
- Depois do go-live, confira nas conversas se as cutucadas saem no espaçamento combinado. Adiamentos por horário de atendimento podem aproximar mensagens.

## 4. Validar, gravar e revisar

1. `kronos_validate_funnel` com a declaração completa. Ele roda as mesmas regras do salvar sem gravar. Corrija cada erro citando o campo e a regra, e valide de novo até `valid: true`.
2. Mostre à pessoa a lista final de etapas (`stepOrder`) e peça o "pode gravar".
3. `kronos_save_funnel`. `MERGE` (padrão) atualiza a etapa existente que tiver o mesmo **nome** (ou cujo ID você passar no `ref`), cria as novas e mantém as etapas que você não citou. `REPLACE` **apaga** toda etapa existente que não estiver na declaração. Em agente que já tem funil, use `MERGE` e `deletedStepRefs` para remover etapas específicas, e só use `REPLACE` com a confirmação explícita de que o funil atual pode ser descartado. Renomear uma etapa em `MERGE` cria uma nova em vez de atualizar; para renomear, passe o ID da etapa existente (de `kronos_get_agent`) no `ref`.
4. `kronos_get_agent` e `kronos_get_publish_diff` para conferir que o rascunho está como combinado. As mudanças **só valem para clientes depois de publicar**.

## 5. Pela interface e vínculo da caixa

- **Base de conhecimento** (aba Conhecimento do agente): FAQ, políticas, descrições longas. Prepare o texto pronto a partir das perguntas e objeções do briefing e entregue para a pessoa colar.
- **Conexão**: o canal (WhatsApp, Instagram, e-mail) a pessoa conecta pela interface, em Inbox > Configurações > Caixas de entrada. Com a caixa existente, rode `kronos_list_inboxes`, confirme qual caixa o agente vai atender e use `kronos_link_inbox_to_agent` (avise que, depois de publicado, o agente responde clientes reais ali). Sem o vínculo o agente não responde ninguém.
- **Testar** (aba Testar): simulador. Peça para a pessoa rodar os cenários abaixo e relatar o que viu.

Cenários mínimos de teste: cliente ideal do início ao fim; cliente que responde fora do critério; cliente que pede preço logo de cara; cliente que pergunta algo fora do escopo; cliente que pede um humano; (se agenda) cliente que quer remarcar e cancelar; cliente que some (reengajamento).

## 6. Ajustar

Para cada problema relatado, identifique se é persona (tom, regras), orientação da etapa (`guidanceNote`, `messageExamples`), critério do campo ou caminho do funil. Ajuste o mínimo, valide, grave e peça para testar de novo o mesmo cenário.

## Checkpoint da fase

Agente criado, funil validado e gravado, conhecimento cadastrado, caixa de entrada vinculada e cenários testados sem problema aberto. Rascunho ainda **não publicado**.
