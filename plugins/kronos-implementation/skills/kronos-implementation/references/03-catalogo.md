# Fase 3 - Catálogo

Objetivo: produtos, serviços e promoções cadastrados corretamente, porque o agente usa o catálogo para responder preço, descrever ofertas e (em modo SERVICE ou HYBRID) agendar.

## Antes de criar

1. Rode `kronos_list_catalog` e compare com a lista do documento do cliente. Não duplique: se já existe, edite.
2. Confira a cota do plano em `kronos_get_workspace` (limite de produtos). Se a lista for maior que o limite, avise agora e combine o que priorizar.
3. Monte a lista completa em uma tabela (nome, preço, duração, categoria) e peça confirmação **uma vez** antes de gravar em lote.

## Serviços (agendáveis)

- Ordem: primeiro as categorias (`kronos_create_service_category`), depois os serviços (`kronos_create_service`) apontando para a categoria.
- Cada serviço precisa de nome, duração em minutos (até 720) e preço. A duração define o tamanho do horário na agenda, então pergunte a real, não uma média.
- Serviço sem preço fixo (orçamento após avaliação): pergunte como o cliente quer tratar. Se cadastrar com preço zero, o agente não deve citar valor; oriente isso na persona (restrição) e, no funil, deixe `mentionPrice` desligado (padrão).
- O agente só agenda serviços **ativos** do catálogo. Um serviço desativado (`isActive: false`) some para o agente.
- Quem executa cada serviço e em que horários é configurado logo abaixo, em "Profissionais e agenda".

## Profissionais e agenda (só se o negócio agenda)

Sem profissional com serviço e horário, o agente não tem vaga para oferecer. Faça depois que os serviços existirem.

1. Rode `kronos_list_professionals` e compare com a equipe do documento do cliente. Não duplique: nome repetido é recusado.
2. Peça por profissional: nome, quais serviços executa e os dias e horários de atendimento (inclusive pausas, como almoço, que viram duas faixas no dia). Não presuma horário padrão.
3. Mostre a tabela completa (profissional, serviços, horário por dia) e peça confirmação **uma vez** antes de gravar.
4. Grave com `kronos_create_professional` (já com os `serviceIds`) e `kronos_set_professional_weekly_hours`. Para vincular ou desvincular depois, `kronos_assign_service_to_professional` e `kronos_remove_service_from_professional`.
5. Folga ou horário especial numa data (feriado, evento): `kronos_add_professional_schedule_exception`, só quando a pessoa pedir.
6. Se o profissional já existe, leia o horário atual e mostre o "antes": o horário semanal é **substituído** por inteiro.
7. Confira com `kronos_list_professionals`: cada profissional ativo tem serviços e horário.

O profissional é criado sem login. Convidar para o portal (acesso à própria agenda) e excluir profissional são pela interface (Configurações do CRM > Profissionais); avise a pessoa se o cliente quiser isso.

## Produtos

- `kronos_create_product`: nome, preço, descrição curta útil para o agente ("o que é, para quem serve").
- Recorrência: `ONE_TIME` (padrão), `RECURRING_OPEN` (exige ciclo de cobrança) ou `RECURRING_CONTRACT` (exige ciclo e duração do contrato em meses). Pergunte se é assinatura antes de escolher.
- Editar (`kronos_update_product`) exige o produto **completo**; campos omitidos voltam ao padrão. Leia e reenvie tudo.
- Imagens e mídia dos produtos são enviadas pela interface.

## Promoções (combos)

- `kronos_create_promotion`: preço final, tipo de desconto (`PERCENTAGE` ou `FIXED`) e itens (produtos ou serviços existentes). Cadastre depois dos itens.
- Disponível a partir do plano Essential e só para Owner/Admin. Se quem está implantando é o suporte da Kronos e receber erro de permissão, explique e peça que o dono do cliente crie pela interface.

## Depois de gravar

Rode `kronos_list_catalog` de novo e mostre o resultado organizado por categoria. Pergunte se falta algo ou se algum preço está errado. Não avance com erro de preço: o agente vai repeti-lo aos clientes.
