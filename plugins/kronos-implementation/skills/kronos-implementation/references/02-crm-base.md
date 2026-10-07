# Fase 2 - Base do CRM

Objetivo: o funil, os campos e os motivos de perda existirem antes de montar o agente, porque o funil do agente **referencia** essas peças (etapas do CRM, campos do CRM). Campos personalizados, motivos de perda e tags você cria pelas tools; o funil (pipeline) e a marcação de qualificação ainda são pela interface, e aí você guia e confirma pela leitura.

## Ordem

1. **Funil comercial (pipeline).**
   - Use o desenho do documento do cliente. Etapas na ordem real do processo, com nomes que o time reconhece.
   - Ganhar e perder **não são etapas**: são o resultado da negociação (ganha, perdida, com motivo). Não crie etapas "Ganho" e "Perdido". O funil descreve só o caminho até lá. Poucas etapas (5 a 8) funcionam melhor que muitas.
   - Cada etapa pode ser marcada como ponto em que o lead vira **qualificado** e/ou em que o contato vira **oportunidade**. Pergunte ao cliente em que etapa isso acontece (item 5).
   - Se já existir um funil padrão da organização, prefira ajustá-lo em vez de criar outro, a menos que o cliente tenha dois processos distintos.
   - Confirme: `kronos_list_pipelines` e mostre etapas e IDs.

2. **Campos personalizados.**
   - Crie só os campos que o agente vai coletar e que o time quer ver na negociação ou no contato (ex.: "Região", "Faixa de orçamento", "Interesse principal").
   - Antes de criar, rode `kronos_list_field_catalog`: se já existe um campo nativo equivalente, não crie outro.
   - Escolha o tipo pelo uso: **seleção** (lista de opções) quando há respostas fechadas, **número** quando há faixa, **texto** para o resto. Existem também data, telefone, e-mail, URL e CPF.
   - Campo de seleção: anote os `value` das opções. O critério do agente (`passingOptions`) usa esses valores exatos.
   - Crie com `kronos_create_custom_field`, **depois de mostrar a lista (nome, entidade, tipo e opções) e a pessoa aprovar**. Editar ou excluir um campo existente é só pela interface.
   - Confirme: `kronos_list_field_catalog`.

3. **Motivos de perda.** Liste os motivos reais pelos quais o negócio perde vendas ("preço", "sem retorno", "escolheu concorrente"). Poucos e distintos.
   - Rode `kronos_list_deal_lost_reasons` antes (nome repetido é recusado), mostre a lista e, com o "pode criar", use `kronos_create_lost_reason`. Renomear ou desativar: `kronos_update_lost_reason`.
   - Confirme: `kronos_list_deal_lost_reasons`.

4. **Tags.** Só se o cliente já usa segmentação por tags ou se alguma automação vai precisar (ex.: "cliente antigo"). Rode `kronos_list_tags`, mostre o que vai criar (tipo contato ou negociação, nome e cor) e, com o "pode criar", use `kronos_create_tag` (ajustes: `kronos_update_tag`). Confirme com `kronos_list_tags`.

5. **Qualificação e ciclo de vida.** Pergunte em qual etapa do funil o lead deve ser considerado qualificado e em qual o contato vira "oportunidade". Isso é marcado nas etapas do funil, pela interface. Sem essa marcação, o contato não avança de estágio sozinho.

## Como guiar a pessoa pela interface

- Diga o que criar, com os nomes exatos, em uma lista curta que ela possa seguir.
- Peça para avisar quando terminar. Depois leia com a tool indicada e mostre o resultado ("Vi as 6 etapas: A, B, C... Está certo?").
- Se algo divergir do combinado, aponte a diferença e peça o ajuste em vez de seguir com o que está lá.

## Checkpoint da fase

Funil, campos e motivos de perda conferidos por leitura. Só então vá para o catálogo.
