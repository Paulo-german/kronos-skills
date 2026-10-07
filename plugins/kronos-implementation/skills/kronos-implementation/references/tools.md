# Mapa das tools do conector "Kronos Hub"

As tools pertencem ao conector **Kronos Hub** e todas começam com `kronos_`. Se a plataforma pedir o nome qualificado, use `Kronos Hub:kronos_list_pipelines` e assim por diante.

Leitura sempre é segura. Escrita segue as regras do SKILL.md (confirmar antes, publicar só com aval).

## Conteúdo

- Leitura
- Escrita: agente e funil, catálogo, negociações, campos personalizados, motivos de perda e tags, caixa de entrada, profissionais e agenda, automações
- Só pela interface (por enquanto)
- Escopos do conector

## Leitura

| Tool                                      | Para quê                                                                                                   |
| ----------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| `kronos_get_workspace`                    | Organização, módulos, limites do plano, contagem de agentes                                                |
| `kronos_list_pipelines`                   | Funis e etapas (IDs para vincular agente, mover negociação, automações)                                    |
| `kronos_list_catalog`                     | Produtos, serviços (com categoria e duração), categorias, promoções                                        |
| `kronos_list_professionals`               | Profissionais, serviços que executam, horário semanal e exceções futuras (sem e-mail, telefone ou convite) |
| `kronos_list_agents` / `kronos_get_agent` | Agentes e detalhe completo (persona, modo, funil, publicação)                                              |
| `kronos_list_field_catalog`               | Campos que o agente sabe coletar (nativos) e campos do CRM disponíveis                                     |
| `kronos_get_publish_diff`                 | O que mudou no rascunho desde a última publicação                                                          |
| `kronos_get_agent_metrics`                | Últimos 7 dias: conversas, turnos, tempo de resposta, erros                                                |
| `kronos_list_agent_conversations`         | Metadados das conversas do agente (sem conteúdo das mensagens)                                             |
| `kronos_list_deals` / `kronos_get_deal`   | Negociações (só nome do contato, nunca telefone ou e-mail)                                                 |
| `kronos_list_deal_lost_reasons`           | Motivos de perda ativos                                                                                    |
| `kronos_list_tags`                        | Tags de contato e de negociação (ID, nome e cor)                                                           |
| `kronos_list_inboxes`                     | Caixas de entrada, canal e qual agente (ou grupo) atende cada uma                                          |
| `kronos_get_automation_options`           | Gatilhos, ações, condições e dados da organização para configurar automações                               |
| `kronos_list_automations`                 | Automações existentes, status e execuções                                                                  |

## Escrita - agente e funil

| Tool                           | Observação                                                                                                                                                                              |
| ------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `kronos_create_agent`          | Exige `persona.companyDescription`. Aceita modo (`PRODUCT`, `SERVICE`, `HYBRID`) e funis vinculados. Confira o estado real depois com `kronos_get_agent`; não presuma que nasce inativo |
| `kronos_update_agent_settings` | Persona, modelo, modo, funis, espera antes de responder, horário de atendimento, mensagem fora do horário, proteção de conteúdo. Só muda o que for informado                            |
| `kronos_validate_funnel`       | Testa o funil sem gravar. **Sempre antes** de salvar                                                                                                                                    |
| `kronos_save_funnel`           | Grava as etapas do funil (rascunho). Modo `MERGE` (padrão) ou `REPLACE`                                                                                                                 |
| `kronos_publish_agent`         | Publica o rascunho para valer nos canais. Só com aval explícito                                                                                                                         |
| `kronos_unpublish_agent`       | Despublica e devolve as conversas ao atendimento humano                                                                                                                                 |

## Escrita - catálogo

`kronos_create_product`, `kronos_update_product`, `kronos_create_service_category`, `kronos_create_service`, `kronos_update_service`, `kronos_create_promotion`, `kronos_update_promotion`.

- Promoções: a partir do plano Essential e só para Owner/Admin (o suporte da Kronos não consegue).
- Edição de produto e promoção pede o registro **completo**; campos omitidos voltam ao padrão. Leia antes com `kronos_list_catalog` e reenvie tudo.
- Para desativar, `isActive: false`.

## Escrita - negociações

`kronos_create_deal`, `kronos_update_deal`, `kronos_move_deal_to_stage`, `kronos_set_deal_outcome` (ganha, perdida, reabrir), `kronos_add_deal_activity`, `kronos_create_deal_task`, `kronos_transfer_deal`, `kronos_update_deal_custom_fields`.

Na implantação, use só para o cliente entender como o funil funciona (com autorização). Movimentar negociações reais dispara automações e webhooks.

## Escrita - campos personalizados

`kronos_create_custom_field`: cria campo de contato (`CONTACT`) ou de negociação (`DEAL`). Tipos: `TEXT`, `NUMBER`, `SELECT`, `DATE`, `PHONE`, `EMAIL`, `URL`, `CPF`.

- `SELECT` exige `options` (cada uma com `label` e `value`). O critério do agente usa o `value`.
- Rode `kronos_list_field_catalog` antes: nome repetido na mesma entidade é recusado e a quota do plano vale.
- Não edita nem exclui campo: para ajustar um que já existe, a pessoa usa a interface.

## Escrita - motivos de perda e tags

`kronos_create_lost_reason`, `kronos_update_lost_reason` (renomear ou desativar), `kronos_create_tag`, `kronos_update_tag` (nome e cor).

- Só Owner e Admin (o suporte da Kronos não consegue). Motivo de perda ou tag com nome repetido é recusado; rode `kronos_list_deal_lost_reasons` e `kronos_list_tags` antes.
- Tag tem `scope` `CONTACT` ou `DEAL`, nome de até 30 caracteres e uma cor da paleta (`slate`, `red`, `orange`, `amber`, `green`, `teal`, `blue`, `purple`, `pink`, `indigo`). Tag de negociação respeita a quota do plano.
- Não exclui nem reativa: isso é pela interface.

## Escrita - caixa de entrada

`kronos_link_inbox_to_agent`: define qual agente atende uma caixa (`agentId: null` desvincula). Se a caixa atendia um grupo de agentes, o grupo é desvinculado. Conversas reais usam a versão **publicada** do agente, então vincular um agente ainda não publicado não o coloca no ar; vincular um já publicado, sim. Confirme com a pessoa antes. Conectar o canal (QR code, conta Meta) continua só pela interface.

## Escrita - profissionais e agenda

`kronos_create_professional`, `kronos_update_professional`, `kronos_assign_service_to_professional`, `kronos_remove_service_from_professional`, `kronos_set_professional_weekly_hours`, `kronos_add_professional_schedule_exception`.

- Só Owner, Admin e Suporte. Criar profissional exige plano com agendamento (Light ou superior).
- Ordem: crie os serviços antes (`kronos_create_service`), depois o profissional (já pode receber os `serviceIds`), depois o horário semanal. Rode `kronos_list_professionals` antes: nome repetido é recusado.
- O profissional nasce **sem login e sem convite**: a tool não envia e-mail nem cria usuário. Convite e acesso ao portal do profissional são só pela interface.
- `kronos_update_professional` muda nome, bio e status. Desativar (`isActive: false`) tira o profissional da oferta de novos horários; agendamentos já marcados ficam como estão.
- `kronos_remove_service_from_professional` remove só o vínculo, nunca o profissional nem o serviço.
- `kronos_set_professional_weekly_hours` **substitui** o horário semanal inteiro e devolve o que foi substituído. Envie 7 dias (`dayOfWeek` 0 = domingo a 6 = sábado), `windows` vazio para dia sem atendimento, faixas em `HH:mm` sem sobreposição; várias faixas por dia são permitidas. `serviceIds` vazio na faixa = aberta a todos os serviços do profissional. Leia o horário atual antes e mostre o "antes" à pessoa. Folgas e exceções de data não mudam.
- `kronos_add_professional_schedule_exception`: `OFF` (folga o dia todo) ou `CUSTOM_HOURS` (horário especial, com `windows`), numa data `YYYY-MM-DD`. Só adiciona; se já existe exceção naquela data, é recusado.
- Nenhuma dessas tools confere agendamentos já marcados: trocar o horário não remarca nem avisa ninguém. Se o profissional já atende, avise a pessoa.

## Escrita - automações

`kronos_create_automation` (nasce inativa), `kronos_update_automation`, `kronos_set_automation_active`.

## Só pela interface (por enquanto)

Quando chegar nestes pontos, diga onde a pessoa deve ir, peça para avisar quando terminar e confirme lendo o resultado. Os nomes de menu abaixo são orientação: se a interface estiver diferente, peça para a pessoa procurar pelo nome do item.

| O que                                                                          | Onde                                                | Como confirmar                                      |
| ------------------------------------------------------------------------------ | --------------------------------------------------- | --------------------------------------------------- |
| Criar funil (pipeline) e etapas                                                | Configurações do CRM > Funis                        | `kronos_list_pipelines`                             |
| Editar ou excluir campo personalizado                                          | Configurações do CRM > Campos personalizados        | `kronos_list_field_catalog`                         |
| Excluir ou reativar motivo de perda; excluir tag                               | Configurações do CRM > Motivos de perda / Tags      | `kronos_list_deal_lost_reasons`, `kronos_list_tags` |
| Marcar a etapa que qualifica o lead e a que vira "oportunidade"                | Configurações do CRM > Funis (na etapa)             | pela própria interface                              |
| Convidar profissional e dar acesso ao portal; excluir profissional             | Configurações do CRM > Profissionais                | `kronos_list_professionals` (`hasPortalAccess`)     |
| Remover folga ou exceção de horário; ajustar telefone e e-mail do profissional | Configurações do CRM > Profissionais > profissional | `kronos_list_professionals`                         |
| Conectar WhatsApp, Instagram ou e-mail                                         | Inbox > Configurações > Caixas de entrada           | pela própria interface                              |
| Base de conhecimento do agente                                                 | Agente > aba Conhecimento                           | pela própria interface                              |
| Mensagens rápidas e templates do WhatsApp                                      | Inbox > Configurações                               | fora do escopo desta skill                          |
| Testar o agente no simulador                                                   | Agente > aba Testar                                 | a pessoa relata o resultado                         |
| Convidar equipe, permissões, cobrança                                          | Configurações da organização                        | fora do escopo desta skill                          |

Follow-ups do agente não estão nesta lista: nos agentes do engine são o reengajamento de cada etapa, que vai na declaração do `kronos_save_funnel` (`reengagement`). A aba Follow-ups da interface é dos agentes antigos.

Se a organização já tiver algum desses itens, use o que existe.

## Escopos do conector

Conexão, URL e passo a passo por plataforma: `references/conexao-mcp.md`.

O conector pede permissões por área: `agents:*`, `catalog:*`, `deals:*`, `automations:*`, `crm_setup:write`, `operations:read`. Se uma tool responder que falta permissão, a pessoa precisa remover e adicionar o conector de novo para conceder as áreas novas. A lista de tools também só atualiza depois disso.
