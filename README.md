# snip

Ferramenta de linha de comando para PowerShell que salva arquivos, pastas e trechos de código diretamente neste repositório, de qualquer projeto ou pasta em que você estiver trabalhando.

```
snip -p "nome-da-pasta"
```

---

## Estrutura

```
C:\IGGO\snip\
├── snip.ps1          ← script global
└── snippets\
    ├── scroll-behavior\
    ├── debounce\
    └── ...
```

> O repositório se chama `snippets` no GitHub mas **deve ser clonado com destino forçado** `C:\IGGO\snip` — sem isso a estrutura quebra.

---

## Instalação

### Pré-requisitos

- Windows com PowerShell 5+
- Git instalado globalmente
- Credenciais do GitHub configuradas

### 1. Configurar identidade do git (qualquer pasta, uma vez por máquina)

```powershell
git config --global user.name "Seu Nome"
git config --global user.email "seu@email.com"
```

### 2. Clonar com destino forçado (qualquer pasta)

```powershell
git clone https://github.com/iggo-cardoso/snippets.git C:\IGGO\snip
```

### 3. Liberar execução de scripts (PowerShell como administrador, qualquer pasta)

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

### 4. Desbloquear o script (qualquer pasta)

```powershell
Unblock-File -Path "C:\IGGO\snip\snip.ps1"
```

### 5. Registrar o alias global (qualquer pasta)

```powershell
New-Item -Path $PROFILE -ItemType File -Force
Add-Content -Path $PROFILE -Value 'function snip { & "C:\IGGO\snip\snip.ps1" @args }'
. $PROFILE
```

### 6. Primeiro push — somente na primeira máquina, com repo vazio (dentro de C:\IGGO\snip)

```powershell
cd C:\IGGO\snip
git add .
git commit -m "init"
git push -u origin main
```

### 7. Testar

```powershell
snip -p "meu-primeiro-snippet"
```

---

## Como usar

```powershell
snip -p "nome-da-pasta"
```

Funciona de qualquer pasta ou projeto. O fluxo interativo pergunta:

| Etapa | Opções |
|---|---|
| Pasta | `create` — cria nova · `existing path` — usa existente |
| README | `readme` — cria README.md · `not` — pula |
| Conteúdo | `file` — copia arquivo · `folder` — copia pasta · `snippet` — cola código no terminal |

Ao final, o push para o GitHub é feito automaticamente.

---

## Nova máquina

Repetir os passos 1 a 5. O passo 6 (primeiro push) **não é necessário** — o repositório já tem histórico.

```powershell
git clone https://github.com/iggo-cardoso/snippets.git C:\IGGO\snip
```

---

## Problemas comuns

| Erro | Solução |
|---|---|
| `snip` não reconhecido | Rodar `. $PROFILE` ou abrir novo terminal |
| arquivo não assinado | Rodar `Unblock-File` + `Set-ExecutionPolicy` (passos 3 e 4) |
| `snippets/` sem commit | `Remove-Item -Recurse -Force C:\IGGO\snip\snippets\.git` |
| `no upstream branch` | Fazer o primeiro push manual: `git push -u origin main` (passo 6) |
| pastas no lugar errado | Clonar novamente com destino forçado |

---

*IGGO STUDIOS*
