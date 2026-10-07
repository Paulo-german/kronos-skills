# Exemplo: clínica com agendamento de avaliação

Modelo genérico de negócio de serviço que capta pelo WhatsApp, qualifica e agenda uma avaliação. Use como **ponto de partida**, nunca copie sem adaptar ao briefing do cliente. Os nomes, critérios e textos abaixo são ilustrativos.

## Conteúdo

- Configuração do agente
- Funil (5 etapas na linha principal e 1 desvio)
- Trechos de declaração (`kronos_save_funnel`): qualificação, agendamento, desvio "fora da área"
- O que adaptar por cliente

## Configuração do agente

- `agentMode`: `SERVICE`
- Persona: `role: receptionist`, `tone: friendly`, `responseLength: short`, `emojiFrequency: low`, `language: pt-BR`.
- `guidelines` (exemplos): "Chame o cliente pelo primeiro nome", "Conduza para marcar a avaliação, sem empurrar preço", "Uma pergunta por mensagem", "Se o cliente pedir para falar com uma pessoa ou reclamar, passe a conversa para a equipe".
- `restrictions` (exemplos): "Não informe valor de tratamento antes da avaliação", "Não prometa resultado nem prazo", "Não dê orientação clínica".

## Funil (6 etapas: 5 na linha principal e 1 desvio)

Linha principal, na ordem declarada:

| ref            | Etapa        | Tipo            | Objetivo                                         | Campos                                                                      | Caminho                                         | Ações                                     |
| -------------- | ------------ | --------------- | ------------------------------------------------ | --------------------------------------------------------------------------- | ----------------------------------------------- | ----------------------------------------- |
| `recepcao`     | Recepção     | `GREETING`      | Cumprimentar, entender o motivo do contato       | nenhum                                                                      | segue                                           | -                                         |
| `qualificacao` | Qualificação | `QUALIFICATION` | Descobrir o interesse e a região                 | Interesse (`REQUIRED`, sem critério), Região (`BRANCHING`, `POSITIVE_ONLY`) | positivo: `apresentacao`; negativo: `fora-area` | -                                         |
| `apresentacao` | Apresentação | `PRESENTATION`  | Explicar como funciona a avaliação e o benefício | -                                                                           | segue                                           | `update_contact_stage: OPPORTUNITY`       |
| `agendamento`  | Agendamento  | `SCHEDULING`    | Marcar a avaliação                               | scheduling `SERVICE` com o serviço "Avaliação"                              | positivo: `confirmacao`                         | `move_deal` para "Agendado"               |
| `confirmacao`  | Confirmação  | `CLOSING`       | Confirmar data, hora e endereço                  | -                                                                           | fim                                             | `create_task` de lembrete para a recepção |

Desvio (`isBranch: true`, declarado depois da linha principal):

| ref         | Etapa        | Tipo    | Objetivo                                                 | Ações                                                                     |
| ----------- | ------------ | ------- | -------------------------------------------------------- | ------------------------------------------------------------------------- |
| `fora-area` | Fora da área | `OTHER` | Encerrar com cordialidade quando a região não é atendida | `hand_off_to_human` em modo `notify` (avisa o responsável, a IA continua) |

O repasse para humano quando o cliente pede uma pessoa fica nas `guidelines` da persona, não numa etapa. Marcar a negociação como perdida é decisão da equipe (resultado da negociação), não uma etapa do funil.

## Trechos de declaração (`kronos_save_funnel`)

Qualificação, com um campo obrigatório (trava até responder) e um de ramificação (desvia quem está fora da região):

```json
{
  "ref": "qualificacao",
  "kind": "QUALIFICATION",
  "name": "Qualificação",
  "goal": "Descobrir o que o cliente procura e se ele está na região atendida.",
  "guidanceNote": "Pergunte uma coisa por vez. Se o cliente já disse o interesse, não repita a pergunta.",
  "messageExamples": ["Perfeito, [nome]! Você mora em qual região?"],
  "fields": [
    {
      "source": "ENTITY_FIELD",
      "name": "Interesse principal",
      "mode": "REQUIRED"
    },
    {
      "source": "ENTITY_FIELD",
      "name": "Região",
      "mode": "BRANCHING",
      "resultPolarity": "POSITIVE_ONLY",
      "criterion": { "passingOptions": ["Centro", "Zona Sul"] }
    }
  ],
  "onPositiveRef": "apresentacao",
  "onNegativeRef": "fora-area"
}
```

Agendamento de serviço, com reengajamento:

```json
{
  "ref": "agendamento",
  "kind": "SCHEDULING",
  "name": "Agendamento",
  "goal": "Marcar a avaliação no melhor horário para o cliente.",
  "scheduling": {
    "mode": "SERVICE",
    "serviceNamesOrIds": ["Avaliação"],
    "professionalPolicy": "auto",
    "createDeal": true,
    "allowReschedule": true,
    "onCancel": "continue"
  },
  "actions": [{ "type": "move_deal", "targetStage": "Agendado" }],
  "reengagement": {
    "enabled": true,
    "nudges": [
      { "delayMinutes": 60, "mode": "generative", "intent": "resume" },
      { "delayMinutes": 1440, "mode": "generative", "intent": "reinforce" },
      { "delayMinutes": 4320, "mode": "generative", "intent": "check_in" }
    ],
    "exhaustedAction": "notify"
  },
  "onPositiveRef": "confirmacao"
}
```

Desvio "fora da área":

```json
{
  "ref": "fora-area",
  "kind": "OTHER",
  "name": "Fora da área",
  "goal": "Explicar com cordialidade que ainda não atendemos a região do cliente e encerrar.",
  "isBranch": true,
  "actions": [
    {
      "type": "hand_off_to_human",
      "mode": "notify",
      "notifyTarget": "deal_assignee"
    }
  ]
}
```

Os outros passos (recepção, apresentação e confirmação) seguem o mesmo formato, sem campos de critério.

## O que adaptar por cliente

- Os nomes dos campos precisam existir no CRM (fase 2) com **exatamente** esse nome, e as opções do critério têm de bater com as opções do campo.
- O serviço "Avaliação" precisa estar ativo no catálogo, com profissional e horários configurados (fase 3, pelas tools de profissionais).
- A etapa "Agendado" precisa existir no funil do CRM vinculado ao agente, e os `value` das opções dos campos precisam bater com o `passingOptions`.
- Se o negócio vende produto em vez de agendar, troque `agendamento` por uma etapa de negociação e fechamento, e use `PRODUCT`. Se faz os dois, `HYBRID`.
