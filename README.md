# Kronos Skills

Skills de agente da Kronos Hub. Hoje há uma: **kronos-implementation**, que guia quem está implantando um cliente no Kronos (CRM com agentes de IA), passo a passo: briefing, base do CRM, catálogo, agente de IA com funil de atendimento, automações e go-live.

A skill executa as configurações pelas tools do conector MCP **Kronos Hub**. Na Fase 1 ela orienta a conectar esse conector. A URL do conector é por organização, por isso o plugin não embute o conector.

> Os nomes de menu das plataformas abaixo mudam com frequência. Se algo não bater, procure por "Skills" nas configurações.

## Instalação

### Claude Code e Cowork (marketplace de plugins)

```
/plugin marketplace add Paulo-german/kronos-skills
/plugin install kronos-implementation@kronos
```

### claude.ai (navegador)

1. Gere o zip com `bash scripts/build-zip.sh` (sai em `dist/kronos-implementation.zip`) ou baixe o zip enviado pela Kronos.
2. Vá em Customize > Skills, escolha criar uma skill e use "Upload a skill".
3. Envie o zip. É preciso um plano com skills habilitadas (e execução de código ativada).
4. Em Team e Enterprise, o dono da organização pode enviar a skill pelas configurações da organização para liberá-la a todos os membros.

### ChatGPT

Em Skills, use o upload do zip (`dist/kronos-implementation.zip`). Skills no ChatGPT existem apenas nos planos Business, Enterprise e Edu, e não em Plus ou Pro. Em Enterprise e Edu, um admin do workspace pode precisar habilitar skills e o upload antes.

### Gemini CLI

O Gemini CLI instala skills direto de um repositório git, apontando a subpasta da skill:

```
gemini skills install https://github.com/Paulo-german/kronos-skills.git --path plugins/kronos-implementation/skills/kronos-implementation
```

Alternativa manual: copie a pasta `plugins/kronos-implementation/skills/kronos-implementation` para `~/.gemini/skills/`.

## Para quem mantém este repositório

Este é o repositório de origem da skill: edite os arquivos de `plugins/kronos-implementation/skills/kronos-implementation/` aqui mesmo. Os cenários de teste ficam em `evals/` e não vão no plugin nem no zip.

Sempre que uma tool do conector MCP mudar (nome, entrada, escopo ou comportamento), revise `references/tools.md` e as fases que a usam.

Para gerar o zip dos uploads manuais:

```
bash scripts/build-zip.sh
```

Não há versionamento: o Claude Code usa o commit como versão.
