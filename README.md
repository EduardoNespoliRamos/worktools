# Worktools

Este projeto centraliza scripts, skills e hooks pessoais para apoiar um fluxo de desenvolvimento com IA usando:

* OpenCode
* Kiro
* Git
* Skills reutilizáveis para análise, testes, review e commit

A ideia principal é criar uma camada de automação local para que agentes de IA usem Git e skills reutilizáveis para gerar análise, testes, review e commits com mais controle.

---

## Objetivo

O objetivo deste projeto é manter um conjunto reutilizável de ferramentas pessoais para desenvolvimento assistido por IA.

O fluxo desejado é:

```text
Editor / IDE
  ↓
Arquivo é salvo ou alterado
  ↓
OpenCode ou Kiro usam git diff
  ↓
Skills executam análise, testes, review e commit
```

Com isso, a IA usa Git como fonte única de verdade para arquivos alterados durante a sessão.

---

## Estrutura do Projeto

```text
worktools/
  README.md

  config-kiro-opencode.sh
    -> .config/scripts/config-kiro-opencode.sh

  .config/
    scripts/
      config-kiro-opencode.sh

    skills/
      skill-logistics-analyst/
        SKILL.md

      skill-test-implementation/
        SKILL.md

      skill-review/
        SKILL.md

      skill-git-commit/
        SKILL.md

  .kiro/
    skills/
```

---

## Diretórios Principais

### `.config/scripts`

Contém scripts globais usados pelos hooks e agentes.

Atualmente:

```text
.config/scripts/config-kiro-opencode.sh
```

Após a configuração, esses scripts são linkados para:

```text
~/.config/scripts/
```

---

### `.config/skills`

Contém as skills reutilizáveis.

Essas skills são usadas pelo OpenCode e também podem ser linkadas para o Kiro.

Skills atuais:

```text
skill-logistics-analyst
skill-test-implementation
skill-review
skill-git-commit
```

Destino para OpenCode:

```text
~/.config/opencode/skills/
```

Destino para Kiro:

```text
~/.kiro/skills/
```

---

## Script de Configuração

O projeto possui um script principal para configurar os links simbólicos necessários para OpenCode, Kiro e scripts globais.

O script real fica em:

```text
.config/scripts/config-kiro-opencode.sh
```

Na raiz do projeto existe um link simbólico com o mesmo nome, apontando para o script real:

```text
config-kiro-opencode.sh -> .config/scripts/config-kiro-opencode.sh
```

Isso permite executar o setup diretamente da raiz do projeto, mantendo o script versionado junto com os demais scripts internos.

---

## Como Rodar o Setup

Na raiz do projeto `worktools`, execute:

```bash
./config-kiro-opencode.sh
```

Para substituir links existentes ou mover arquivos existentes para backup antes de criar novos links:

```bash
./config-kiro-opencode.sh --force
```

O script deve ser executado a partir da raiz do projeto, onde existe o link simbólico:

```text
worktools/
  config-kiro-opencode.sh -> .config/scripts/config-kiro-opencode.sh
```

---

## O que o Script Configura

O script cria links simbólicos entre os arquivos versionados neste repositório e os diretórios esperados pelas ferramentas.

### Scripts globais

Origem:

```text
.config/scripts/*
```

Destino:

```text
~/.config/scripts/*
```

Exemplo:

```text
.config/scripts/config-kiro-opencode.sh
  -> ~/.config/scripts/config-kiro-opencode.sh
```

---

### Skills do OpenCode

Origem:

```text
.config/skills/*
```

Destino:

```text
~/.config/opencode/skills/*
```

Exemplo:

```text
.config/skills/skill-logistics-analyst
  -> ~/.config/opencode/skills/skill-logistics-analyst
```

---

### Skills do Kiro

Origem:

```text
.config/skills/*
```

Destino:

```text
~/.kiro/skills/*
```

Exemplo:

```text
.config/skills/skill-review
  -> ~/.kiro/skills/skill-review
```

---

## Por que Usar Link Simbólico na Raiz?

O script principal fica dentro de `.config/scripts` para manter todos os scripts organizados no mesmo lugar.

Ao mesmo tempo, o link simbólico na raiz facilita o uso:

```bash
./config-kiro-opencode.sh
```

Sem precisar chamar:

```bash
.config/scripts/config-kiro-opencode.sh
```

Isso deixa o projeto mais organizado e mantém a execução simples.

---

## Recriando o Link da Raiz

Caso o link simbólico da raiz seja removido, ele pode ser recriado com:

```bash
ln -s .config/scripts/config-kiro-opencode.sh config-kiro-opencode.sh
```

Para validar:

```bash
ls -la config-kiro-opencode.sh
```

Resultado esperado:

```text
config-kiro-opencode.sh -> .config/scripts/config-kiro-opencode.sh
```

---

## Permissões

Garanta que o script real tenha permissão de execução:

```bash
chmod +x .config/scripts/config-kiro-opencode.sh
```

---

## Fluxo de Skills

O fluxo principal das skills é:

```text
skill-logistics-analyst
  ↓
skill-test-implementation
  ↓
skill-review
  ↓
skill-git-commit
```

---

## Skill: `skill-logistics-analyst`

Essa skill usa o Git para analisar o que foi alterado.

Ela deve:

* usar `git status` e `git diff` para encontrar arquivos modificados
* analisar os arquivos modificados
* ignorar arquivos grandes, binários, gerados ou não úteis
* gerar um relatório Markdown da análise

Saída esperada:

```text
docs/change-analysis/YYYY-MM-DD-HHMM-change-analysis.md
```

Esse relatório descreve:

* resumo executivo
* arquivos alterados
* áreas lógicas de mudança
* impacto potencial
* riscos
* testes recomendados
* arquivos ignorados

---

## Skill: `skill-test-implementation`

Essa skill usa o Git e implementa ou incrementa testes para os arquivos de código modificados.

Ela deve:

* usar `git diff --name-only` para encontrar arquivos de produção modificados
* selecionar apenas arquivos de código de produção
* procurar testes existentes
* criar ou melhorar testes
* preferir testes funcionais ou orientados a comportamento
* mirar 80% de cobertura para o código alterado
* não adicionar bibliotecas de teste automaticamente
* verificar se a biblioteca de teste já existe no projeto
* perguntar antes de adicionar dependências
* evitar mocks complexos
* se o teste ficar complexo demais, adicionar comentário/TODO no arquivo de teste

---

## Skill: `skill-review`

Essa skill faz o review do que foi alterado.

Ela usa:

```text
git diff
docs/change-analysis/*-change-analysis.md
```

Ela deve:

* revisar os arquivos modificados no Git
* usar o relatório da `skill-logistics-analyst` como contexto
* gerar um relatório Markdown de review
* classificar achados por severidade
* apontar riscos, bugs, problemas de teste e manutenção
* depois de gerar o review, apagar o relatório anterior da análise

Saída esperada:

```text
docs/reviews/YYYY-MM-DD-HHMM-skill-review.md
```

---

## Skill: `skill-git-commit`

Essa skill cria um commit Git local.

Ela usa:

* arquivos modificados do Git
* o relatório Markdown da `skill-review`

Ela deve:

* usar `git status` e `git diff` como fonte dos arquivos do commit
* ler `docs/reviews/*-skill-review.md`
* gerar uma mensagem de commit baseada nas mudanças e no review
* validar a branch atual
* nunca commitar diretamente em `main`, `master` ou `develop`
* se estiver em branch protegida, perguntar qual branch deve ser criada ou usada
* criar o commit local
* nunca fazer push
* depois do commit, apagar o Markdown de review usado como entrada

Branches protegidas:

```text
main
master
develop
```

O push deve ser feito manualmente pela pessoa.

---

## Fluxo Completo Sugerido

Durante o desenvolvimento:

```text
1. Rodar skill-logistics-analyst
2. Rodar skill-test-implementation
3. Rodar skill-review
4. Rodar skill-git-commit
5. Fazer push manualmente
```

Exemplo no OpenCode:

```text
Use the skill-logistics-analyst skill.
```

Depois:

```text
Use the skill-test-implementation skill.
```

Depois:

```text
Use the skill-review skill.
```

Depois:

```text
Use the skill-git-commit skill.
```

---

## Integração com OpenCode

As skills são linkadas para:

```text
~/.config/opencode/skills/
```

Assim elas ficam disponíveis globalmente para o OpenCode.

Exemplo:

```text
~/.config/opencode/skills/skill-logistics-analyst
~/.config/opencode/skills/skill-test-implementation
~/.config/opencode/skills/skill-review
~/.config/opencode/skills/skill-git-commit
```

---

## Segurança

Algumas regras importantes do fluxo:

* as skills de análise e review não devem alterar código
* a skill de testes só pode criar ou editar testes
* a skill de commit nunca deve fazer push
* commits não devem ser feitos diretamente em `main`, `master` ou `develop`
* arquivos grandes, binários ou gerados devem ser ignorados
* dependências novas de teste não devem ser adicionadas sem confirmação
* relatórios temporários devem ser removidos pelas skills responsáveis

---

## Validação do Setup

Depois de rodar:

```bash
./config-kiro-opencode.sh
```

Verifique:

```bash
ls -la ~/.config/scripts
ls -la ~/.config/opencode/skills
ls -la ~/.kiro/skills
ls -la ~/.kiro/hooks
```

---

## Troubleshooting

### O script não executa

Verifique permissão:

```bash
chmod +x .config/scripts/config-kiro-opencode.sh
```

---

### O link da raiz não existe

Recrie com:

```bash
ln -s .config/scripts/config-kiro-opencode.sh config-kiro-opencode.sh
```

---

### O link aponta para lugar errado

Rode:

```bash
./config-kiro-opencode.sh --force
```

O script deve mover arquivos existentes para backup antes de substituir.

---

### A skill não aparece no OpenCode

Verifique se os links existem:

```bash
ls -la ~/.config/opencode/skills
```

E confira se cada skill possui:

```text
SKILL.md
```

---

### A skill não aparece no Kiro

Verifique:

```bash
ls -la ~/.kiro/skills
```

E confira se cada skill possui:

```text
SKILL.md
```

---

## Estado Atual

Este projeto atualmente monta uma base para um fluxo pessoal de desenvolvimento com IA orientado por arquivos alterados.

O foco é permitir que OpenCode e Kiro usem um contexto local confiável para:

* entender o que foi alterado
* implementar testes
* fazer review
* gerar commits locais seguros

O projeto ainda pode evoluir para incluir:

* comandos globais do OpenCode
* templates de prompts
* integração mais completa com VSCode
* watcher bash independente
* análise de cobertura automatizada
* integração com base vetorial ou grafo de dependências
* análise de impacto entre serviços
* geração automática de documentação técnica
