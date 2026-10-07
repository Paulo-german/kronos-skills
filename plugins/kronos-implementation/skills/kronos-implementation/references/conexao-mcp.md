# Fase 1 (início) - Verificar e guiar a conexão do conector

Objetivo: antes de ler ou gravar qualquer coisa, ter certeza de que o conector **Kronos Hub** está conectado **à organização certa**. Se não estiver, conduzir a pessoa pela conexão, com a URL pronta e o passo a passo da plataforma que ela usa. A fase 0 (briefing) não precisa disso; é aqui que a conexão passa a ser exigida.

## Contents

- Como verificar
- Como ler o resultado
- Montar a URL do servidor
- Passo a passo por plataforma (Claude, ChatGPT, Gemini)
- Depois de conectar
- Quando a conexão falha

## Como verificar

1. Procure entre as suas tools as que começam com `kronos_` (conector "Kronos Hub").
2. Se existirem, chame `kronos_get_workspace`. Ele confirma a organização (nome e slug), os módulos e o plano.
3. Compare o slug retornado com o cliente que está sendo implantado. O conector enxerga **uma organização só**, a da URL com que foi conectado.

## Como ler o resultado

| O que aconteceu                                  | Significa                                                                       | O que fazer                                                                                            |
| ------------------------------------------------ | ------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| Tools `kronos_*` não aparecem                    | Conector não conectado (ou desligado nesta conversa)                            | Guiar a conexão (abaixo)                                                                               |
| Tool responde e o slug é o do cliente            | Conectado à organização certa                                                   | Seguir com o diagnóstico                                                                               |
| Tool responde, mas o slug é de outra organização | Conectado ao cliente errado                                                     | Guiar a conexão da organização certa (a pessoa pode ter os dois conectores; peça para ligar o correto) |
| Erro de permissão ou escopo                      | Conexão antiga, sem as áreas novas                                              | Remover o conector e adicionar de novo (também atualiza a lista de tools)                              |
| Erro de "não encontrado"                         | Kronos MCP não liberado para essa pessoa ou organização, ou plano sem o recurso | Ver "Quando a conexão falha"                                                                           |

Nunca simule dados nem siga como se tivesse lido. Sem conexão validada, continue só o briefing.

## Montar a URL do servidor

```
https://app.kronoshub.com.br/api/mcp/o/{slug-da-organização}
```

- O `{slug}` é o trecho que aparece no endereço do Kronos no navegador: `.../org/{slug}/...`. Se a pessoa não souber, peça para olhar a barra de endereço com o Kronos aberto na organização do cliente.
- Ela pode também copiar a URL pronta em **Configurações > Conectores** do Kronos (o Kronos mostra a URL certa da organização e guia a conexão de cada plataforma). Se houver diferença entre o que a tela mostra e o que está aqui, vale o que a tela mostra.
- Entregue a URL em bloco de código, para copiar com um clique, já com o slug preenchido.

## Passo a passo por plataforma

Pergunte qual plataforma a pessoa usa (Claude, ChatGPT ou Gemini), a menos que já esteja claro. Entregue **só** a dela. Nomes de menu mudam com frequência: se algo estiver diferente, peça para procurar por "conector personalizado" (custom connector ou custom MCP) na ajuda da plataforma. A URL e a autorização são as mesmas.

### Claude

1. Abra este link, que já preenche o nome e a URL (troque `{slug}` pelo slug real; se preferir, monte o link com a URL codificada):
   `https://claude.ai/customize/connectors?modal=add-custom-connector&connectorName=Kronos%20Hub&connectorUrl=https%3A%2F%2Fapp.kronoshub.com.br%2Fapi%2Fmcp%2Fo%2F{slug}`
2. Confira o nome "Kronos Hub" e a URL e clique em **Add**.
3. Clique em **Connect**. O Kronos abre para autorizar o acesso, com a conta do Kronos da pessoa.
4. Volte ao chat, confirme que o conector está ligado na conversa e avise.

Equipe Team ou Enterprise: o dono da conta pode adicionar o conector para toda a organização em `https://claude.ai/admin-settings/connectors` (mesmos parâmetros); depois cada pessoa só clica em **Connect**.

### ChatGPT

1. Copie a URL do servidor (bloco de código acima).
2. Ative o **Developer mode** em Settings > Apps > Advanced settings. Em Team e Enterprise, um admin do workspace precisa liberar isso antes.
3. Em Settings > Apps, crie um conector personalizado: nome "Kronos Hub", cole a URL e escolha autenticação **OAuth**.
4. Autorize o acesso quando o Kronos abrir.
5. Numa conversa nova, ative o conector pelo botão **+** e avise.

Conectores personalizados exigem os planos Plus, Pro, Team, Enterprise ou Edu.

### Gemini (Gemini Enterprise, pelo Google Cloud)

Este é o caminho mais longo, e pede alguém com acesso ao Google Cloud do cliente.

1. No Kronos, em **Configurações > Conectores > Gemini**, gere as credenciais (Client ID e Secret). O Secret aparece **uma única vez**: guarde na hora.
2. No Google Cloud, em Gemini Enterprise, crie um data store do tipo "Custom MCP server" e cole a URL do servidor.
3. Na autenticação, informe:
   - Authorization URL: `https://app.kronoshub.com.br/api/mcp/oauth/authorize`
   - Token URL: `https://app.kronoshub.com.br/api/mcp/oauth/token`
   - Client ID e Client Secret gerados no passo 1.
   - Redirect URI (para cadastrar no Google): `https://vertexaisearch.cloud.google.com/oauth-redirect`
4. Autorize o acesso quando o Kronos abrir.

Não confirmado: se o Gemini Enterprise consegue chamar as tools do conector a partir de uma skill. Se as tools não aparecerem depois de conectar, avise a pessoa e siga só o briefing, ou sugira Claude ou ChatGPT para a implantação.

### Outra plataforma

Qualquer cliente MCP que aceite "servidor remoto com OAuth" serve: cadastre a URL do servidor como conector personalizado e autorize pelo Kronos.

## Depois de conectar

1. Peça para a pessoa avisar quando terminar. Você não consegue conectar por ela.
2. Se as tools ainda não aparecerem, peça para abrir uma **conversa nova** com o conector ligado (a lista de tools é lida na conexão).
3. Rode de novo `kronos_get_workspace` e confirme o slug. Só então siga com o diagnóstico (`SKILL.md`, fase 1).

## Quando a conexão falha

- **Quem autoriza:** só quem é Owner, Admin ou Suporte da organização consegue autorizar. Membro comum e profissional não conseguem: peça a alguém com esse papel.
- **Recurso não liberado:** o módulo de agentes precisa estar ativo e o plano precisa incluir o Kronos MCP (a partir do Essential). Se o Kronos negar, ou se o servidor responder como se não existisse, o recurso pode ainda não estar liberado para a conta: explique isso à pessoa, peça para falar com a Kronos e não tente contornar.
- **Slug errado:** a autorização dá "organização não encontrada" ou você vê dados de outro cliente. Refaça a URL com o slug correto e reconecte.
- Nunca peça senha, token ou secret na conversa (o Client Secret do Gemini a pessoa cola direto no Google Cloud).
