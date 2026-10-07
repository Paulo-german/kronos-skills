# Fase 5 - Automações do CRM

Objetivo: tarefas repetitivas resolvidas sozinhas (lembretes, avisos internos, tarefas de follow-up) sem duplicar o que o agente já faz.

## Princípios

- **Poucas e úteis.** Comece com 2 a 4 automações que resolvem uma dor concreta do briefing. Mais automação não é melhor.
- **Não duplique o agente.** Retomada de cliente que sumiu é reengajamento do agente (fase 4), não automação. Mover negociação no meio da conversa também é ação da etapa do agente.
- **Automação que envia mensagem a cliente é sensível.** Mostre o texto exato e o gatilho, e só ative com um "pode ligar" claro.
- **Nascem inativas.** `kronos_create_automation` cria desligada de propósito. Ative com `kronos_set_automation_active` depois da revisão, ou com `activate: true` só se a pessoa já pediu para ligar.

## Sequência

1. `kronos_list_automations` para ver o que já existe.
2. `kronos_get_automation_options` **antes de montar qualquer uma**. Ele traz gatilhos, ações, condições, regras de compatibilidade e os dados da organização (membros, tags, caixas de entrada WhatsApp). Funis e etapas vêm de `kronos_list_pipelines`; motivos de perda de `kronos_list_deal_lost_reasons`.
3. Proponha cada automação em uma linha: "Quando [gatilho], se [condição], então [ação]". Peça correção.
4. `kronos_create_automation` (nasce inativa), depois leia com `kronos_list_automations` e mostre.
5. Revise com a pessoa e ative com `kronos_set_automation_active`.

## Ideias comuns (ofereça só as que fazem sentido para o cliente)

| Situação                                                     | Formato                                                                        |
| ------------------------------------------------------------ | ------------------------------------------------------------------------------ |
| Lembrar o cliente de um agendamento                          | Gatilho `APPOINTMENT_UPCOMING` (com antecedência) + enviar mensagem            |
| Avisar o vendedor de negociação parada ou de nova negociação | Gatilho `DEAL_CREATED` ou `DEAL_STALE` (negociação parada) + notificar usuário |
| Criar tarefa de acompanhamento ao entrar numa etapa          | Gatilho `DEAL_MOVED` (entrou na etapa) ou `DEAL_IDLE_IN_STAGE` + criar tarefa  |
| Marcar o contato com uma tag ao ganhar ou perder             | Gatilho `DEAL_STATUS_CHANGED` (ganha ou perdida) + adicionar tag               |

O nome exato dos gatilhos e das ações e o formato de configuração vêm de `kronos_get_automation_options`. Use os nomes de lá.

## Regras que aparecem nos erros

- **Compatibilidade gatilho x ação:** gatilhos de contato aceitam só um conjunto de ações; gatilhos de agendamento outro. O erro diz qual combinação é inválida; ajuste em vez de insistir.
- **Antecedência de lembrete:** só valores permitidos (por exemplo 10 min, 30 min, 1 h, 6 h, 12 h, 1 dia, 2 dias, 3 dias). Confira em `kronos_get_automation_options`.
- **Até 5 condições** por automação.
- **Cota de automações** do plano: se estourar, avise e priorize.
- **Mensagem por template da Meta** (WhatsApp Cloud) é configurada pela interface.

## Editar

`kronos_update_automation` muda só o que for informado. Para ligar e desligar, use sempre `kronos_set_automation_active`. Se a mudança altera o que é enviado a clientes e a automação está ativa, avise antes.

## Checkpoint da fase

Lista das automações com gatilho, ação e status (ativa ou não), aprovada pela pessoa.
