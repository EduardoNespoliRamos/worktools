# Worktools

Este projeto centraliza scripts, skills e hooks pessoais para apoiar um fluxo de desenvolvimento com IA usando:

* OpenCode
* Kiro
* SQLite local
* File Watchers / hooks / scripts de terminal
* Git
* Skills reutilizáveis para análise, testes, review e commit

A ideia principal é criar uma camada de automação local para acompanhar os arquivos alterados durante o desenvolvimento, registrar essas mudanças em uma base SQLite e permitir que agentes de IA usem esse contexto para gerar análise, testes, review e commits com mais controle.

---

## Objetivo

O objetivo deste projeto é manter um conjunto reutilizável de ferramentas pessoais para desenvolvimento assistido por IA.

O fluxo desejado é:

```text
Editor / IDE
  ↓
Arquivo é salvo ou alterado
  ↓
Script registra alteração no SQLite
  ↓
OpenCode ou Kiro leem a base SQLite
  ↓
Skills executam análise, testes, review e commit
```

Com isso, a IA não precisa depender apenas de `git diff` ou do contexto atual do chat. Ela pode consultar uma base local com os arquivos modificados durante a sessão.

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
      track-file-change.sh

    skills/
      skill-logistics-analyst/
        SKILL.md

      skill-test-implementation/
        SKILL.md

      skill-review/
        SKILL.md

      skill-git-commit/
        SKILL.md

    samples/
      intellij-file-watc.xml

  .kiro/
    hooks/
      track-file-change.json

    skills/
```

---

## Diretórios Principais

### `.config/scripts`

Contém scripts globais usados pelos editores, hooks e agentes.

Atualmente:

```text
.config/scripts/config-kiro-opencode.sh
.config/scripts/track-file-change.sh
```

Após a configuração, esses scripts são linkados para:

```text
~/.config/scripts/
```

Exemplo:

```text
.config/scripts/track-file-change.sh
  -> ~/.config/scripts/track-file-change.sh
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

### `.kiro/hooks`

Contém hooks do Kiro.

Atualmente:

```text
.kiro/hooks/track-file-change.json
```

Esse hook chama o script `track-file-change.sh` quando arquivos são salvos no Kiro.

Destino após setup:

```text
~/.kiro/hooks/track-file-change.json
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
.config/scripts/track-file-change.sh
  -> ~/.config/scripts/track-file-change.sh
```

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

### Hooks do Kiro

Origem:

```text
.kiro/hooks/*
```

Destino:

```text
~/.kiro/hooks/*
```

Exemplo:

```text
.kiro/hooks/track-file-change.json
  -> ~/.kiro/hooks/track-file-change.json
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

Como o arquivo da raiz é apenas um link simbólico, não é necessário aplicar `chmod` diretamente nele.

Também garanta permissão de execução no script de tracking:

```bash
chmod +x .config/scripts/track-file-change.sh
```

---

## Script de Tracking de Arquivos

O script principal de tracking é:

```text
.config/scripts/track-file-change.sh
```

Após o setup, ele fica acessível em:

```text
~/.config/scripts/track-file-change.sh
```

Ele recebe:

```bash
track-file-change.sh <file_path> <project_dir>
```

Exemplo:

```bash
~/.config/scripts/track-file-change.sh "$(pwd)/build.gradle.kts" "$(pwd)"
```

Esse script grava os dados em:

```text
<projeto>/.ai/file_changes.sqlite
```

---

## Banco SQLite

Cada projeto monitorado passa a ter uma base local:

```text
.ai/file_changes.sqlite
```

Essa base guarda os arquivos modificados durante a sessão.

Tabelas principais:

```text
changed_files
file_change_events
```

---

### Tabela `changed_files`

Mantém o último estado conhecido de cada arquivo alterado.

Campos esperados:

```text
file_path
project_dir
first_seen_at
last_seen_at
change_count
git_branch
git_status
file_hash
```

---

### Tabela `file_change_events`

Mantém o histórico de eventos de alteração.

Campos esperados:

```text
id
file_path
project_dir
changed_at
git_branch
git_status
file_hash
```

---

## Consultas Úteis

Listar arquivos alterados recentemente:

```bash
sqlite3 .ai/file_changes.sqlite \
  "SELECT file_path, change_count, last_seen_at, git_status FROM changed_files ORDER BY last_seen_at DESC;"
```

Listar últimos eventos:

```bash
sqlite3 .ai/file_changes.sqlite \
  "SELECT changed_at, file_path, git_status FROM file_change_events ORDER BY id DESC LIMIT 20;"
```

Limpar a base manualmente, se necessário:

```bash
sqlite3 .ai/file_changes.sqlite \
  "DELETE FROM changed_files; DELETE FROM file_change_events; VACUUM;"
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

Essa skill lê o SQLite e entende logicamente o que foi alterado.

Ela deve:

* consultar `.ai/file_changes.sqlite`
* usar a tabela `changed_files`
* analisar os arquivos modificados
* ignorar arquivos grandes, binários, gerados ou não úteis
* remover da base os arquivos ignorados
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
* limpeza feita na base SQLite

---

## Skill: `skill-test-implementation`

Essa skill lê o SQLite e implementa ou incrementa testes para os arquivos de código modificados.

Ela deve:

* consultar `.ai/file_changes.sqlite`
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

Essa skill não deve limpar o SQLite.

---

## Skill: `skill-review`

Essa skill faz o review do que foi alterado.

Ela usa:

```text
.ai/file_changes.sqlite
docs/change-analysis/*-change-analysis.md
```

Ela deve:

* revisar os arquivos rastreados no SQLite
* usar o relatório da `skill-logistics-analyst` como contexto
* gerar um relatório Markdown de review
* classificar achados por severidade
* apontar riscos, bugs, problemas de teste e manutenção
* depois de gerar o review, apagar o relatório anterior da análise
* zerar as tabelas do SQLite

Saída esperada:

```text
docs/reviews/YYYY-MM-DD-HHMM-skill-review.md
```

Após gerar o relatório, ela deve limpar:

```sql
DELETE FROM changed_files;
DELETE FROM file_change_events;
VACUUM;
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
1. Salvar arquivos no editor
2. Hook/File Watcher registra arquivos no SQLite
3. Rodar skill-logistics-analyst
4. Rodar skill-test-implementation
5. Rodar skill-review
6. Rodar skill-git-commit
7. Fazer push manualmente
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

## Integração com Kiro

O hook do Kiro fica em:

```text
.kiro/hooks/track-file-change.json
```

Após o setup, ele é linkado para:

```text
~/.kiro/hooks/track-file-change.json
```

Esse hook chama:

```text
~/.config/scripts/track-file-change.sh
```

Sempre que um arquivo compatível for salvo.

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

## Integração com IntelliJ

O projeto pode ser usado com File Watchers do IntelliJ.

O objetivo é chamar:

```text
~/.config/scripts/track-file-change.sh
```

Sempre que um arquivo for salvo.

Exemplo de chamada esperada:

```bash
~/.config/scripts/track-file-change.sh "$FilePath$" "$ProjectFileDir$"
```

Também existe um exemplo em:

```text
.config/samples/intellij-file-watc.xml
```

---

## Integração com VSCode

No VSCode, o mesmo comportamento pode ser obtido com extensões como:

* Run on Save
* Trigger Task on Save

Ou com um watcher bash rodando no terminal.

A chamada esperada continua sendo:

```bash
~/.config/scripts/track-file-change.sh "<arquivo>" "<diretorio-do-projeto>"
```

Exemplo usando variáveis do VSCode:

```bash
~/.config/scripts/track-file-change.sh "${file}" "${workspaceFolder}"
```

---

## Integração via Bash Watcher

Também é possível monitorar alterações sem depender do editor.

A ideia é rodar um watcher no terminal que detecta alterações e chama:

```text
~/.config/scripts/track-file-change.sh
```

Esse caminho funciona com qualquer editor:

* IntelliJ
* VSCode
* Kiro
* Vim
* Neovim
* Terminal
* Outros editores

---

## Arquivos Temporários nos Projetos Monitorados

Projetos monitorados podem gerar:

```text
.ai/file_changes.sqlite
docs/change-analysis/
docs/reviews/
```

Recomendação de `.gitignore` nos projetos monitorados:

```gitignore
.ai/
docs/change-analysis/
docs/reviews/*-skill-review.md
```

---

## Segurança

Algumas regras importantes do fluxo:

* o tracking de arquivos não altera código
* as skills de análise e review não devem alterar código
* a skill de testes só pode criar ou editar testes
* a skill de commit nunca deve fazer push
* commits não devem ser feitos diretamente em `main`, `master` ou `develop`
* arquivos grandes, binários ou gerados devem ser ignorados
* dependências novas de teste não devem ser adicionadas sem confirmação
* relatórios temporários devem ser removidos pelas skills responsáveis
* o SQLite deve ser tratado como contexto temporário de sessão

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

Teste o tracking manualmente dentro de um projeto qualquer:

```bash
~/.config/scripts/track-file-change.sh "$(pwd)/README.md" "$(pwd)"
```

Depois confira o SQLite:

```bash
sqlite3 .ai/file_changes.sqlite \
  "SELECT file_path, change_count, last_seen_at FROM changed_files ORDER BY last_seen_at DESC;"
```

---

## Troubleshooting

### O script não executa

Verifique permissão:

```bash
chmod +x .config/scripts/config-kiro-opencode.sh
chmod +x .config/scripts/track-file-change.sh
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

### O SQLite não foi criado

Teste manualmente:

```bash
~/.config/scripts/track-file-change.sh "$(pwd)/README.md" "$(pwd)"
```

Depois verifique:

```bash
ls -la .ai/
```

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
