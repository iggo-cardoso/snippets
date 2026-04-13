# snip.ps1 — adiciona snippets ao repositorio de qualquer lugar
# uso: snip -p "nome-da-pasta"

param(
    [Parameter(Mandatory=$true)]
    [Alias("p")]
    [string]$pasta
)

$REPO      = "C:\IGGO\snip"
$SNIPPETS  = Join-Path $REPO "snippets"

# ── verifica repo ──────────────────────────────────────
if (-not (Test-Path $REPO)) {
    Write-Host "erro: repositorio nao encontrado em $REPO" -ForegroundColor Red
    exit 1
}

# garante que a pasta snippets existe
if (-not (Test-Path $SNIPPETS)) {
    New-Item -ItemType Directory -Path $SNIPPETS -Force | Out-Null
}

function Escreve($msg, $cor="Cyan") {
    Write-Host $msg -ForegroundColor $cor
}

function Pergunta($opcoes, $titulo) {
    Escreve "`n$titulo" "Yellow"
    for ($i = 0; $i -lt $opcoes.Length; $i++) {
        Write-Host "  [$($i+1)] $($opcoes[$i])"
    }
    do {
        $entrada = $Host.UI.ReadLine()
        $num = 0
        $valido = [int]::TryParse($entrada, [ref]$num) -and $num -ge 1 -and $num -le $opcoes.Length
        if (-not $valido) { Escreve "opcao invalida, tente novamente" "Red" }
    } while (-not $valido)
    return $opcoes[$num - 1]
}

function LeInput($label) {
    Escreve "`n$label" "Yellow"
    $valor = $Host.UI.ReadLine()
    $valor = $valor.Trim('"')
    if ($valor.Length -gt 80) {
        # limpa a linha digitada e substitui por mensagem curta
        $linhas = [math]::Ceiling($valor.Length / $Host.UI.RawUI.WindowSize.Width)
        for ($i = 0; $i -lt $linhas; $i++) {
            [Console]::SetCursorPosition(0, [Console]::CursorTop - 1)
            Write-Host (" " * $Host.UI.RawUI.WindowSize.Width) -NoNewline
        }
        [Console]::SetCursorPosition(0, [Console]::CursorTop)
        Escreve "Colado com sucesso" "Green"
    }
    return $valor
}

function PegaClipboard($label) {
    Escreve "`ncopie o $label e pressione Enter:" "Yellow"
    $Host.UI.ReadLine() | Out-Null
    $conteudo = Get-Clipboard -Raw
    if (-not $conteudo) {
        Escreve "clipboard vazio" "Red"
        exit 1
    }
    return $conteudo
}

# ── PASSO 1: pasta ─────────────────────────────────────
$destino_rel = "snippets\$pasta"
$destino_abs = Join-Path $SNIPPETS $pasta

$escolha_pasta = Pergunta @("create", "existing path") "> pasta '$pasta'"

if ($escolha_pasta -eq "create") {
    if (Test-Path $destino_abs) {
        Escreve "pasta ja existe, usando ela" "DarkYellow"
    } else {
        New-Item -ItemType Directory -Path $destino_abs -Force | Out-Null
        Escreve "pasta criada: $destino_rel" "Green"
    }
} else {
    $pastas = Get-ChildItem $SNIPPETS -Recurse -Directory `
        | Where-Object { $_.FullName -notlike "*\.git*" } `
        | ForEach-Object { $_.FullName.Replace("$SNIPPETS\", "") }

    if ($pastas.Count -eq 0) {
        Escreve "nenhuma pasta existente em snippets, criando '$pasta'" "DarkYellow"
        New-Item -ItemType Directory -Path $destino_abs -Force | Out-Null
    } else {
        $escolhida = Pergunta $pastas "> qual pasta dentro de snippets?"
        $destino_rel = "snippets\$escolhida"
        $destino_abs = Join-Path $SNIPPETS $escolhida
    }
}

# ── PASSO 2: readme ────────────────────────────────────
$escolha_readme = Pergunta @("readme", "not") "> readme?"

if ($escolha_readme -eq "readme") {
    $conteudo_readme = PegaClipboard "conteudo do README.md"
    $readme_path = Join-Path $destino_abs "README.md"
    Set-Content -Path $readme_path -Value $conteudo_readme -Encoding UTF8
    Escreve "README.md criado" "Green"
}

# ── PASSO 3: conteudo ──────────────────────────────────
$escolha_tipo = Pergunta @("file", "folder", "snippet") "> o que vai adicionar?"

switch ($escolha_tipo) {

    "file" {
        $caminho = LeInput "caminho do arquivo:"
        if (-not (Test-Path $caminho)) {
            Escreve "arquivo nao encontrado: $caminho" "Red"; exit 1
        }
        $nome = Split-Path $caminho -Leaf
        Copy-Item $caminho (Join-Path $destino_abs $nome) -Force
        Escreve "arquivo copiado: $nome" "Green"
    }

    "folder" {
        $caminho = LeInput "caminho da pasta:"
        if (-not (Test-Path $caminho)) {
            Escreve "pasta nao encontrada: $caminho" "Red"; exit 1
        }
        $nome = Split-Path $caminho -Leaf
        Copy-Item $caminho (Join-Path $destino_abs $nome) -Recurse -Force
        Escreve "pasta copiada: $nome" "Green"
    }

    "snippet" {
        $nome_snip = LeInput "nome do arquivo (ex: debounce.js):"
        $codigo = PegaClipboard "codigo do snippet"
        $snip_path = Join-Path $destino_abs $nome_snip
        Set-Content -Path $snip_path -Value $codigo -Encoding UTF8
        Escreve "snippet salvo: $nome_snip" "Green"
    }
}

# ── PUSH ───────────────────────────────────────────────
Escreve "`nfazendo push..." "Cyan"

Push-Location $REPO

git add .

$commitMsg = "add $destino_rel"
$status = git status --porcelain
if ($status) {
    git commit -m $commitMsg --quiet
    git push --set-upstream origin main --quiet
    Escreve "pronto! disponivel no GitHub" "Green"
} else {
    Escreve "nada novo para commitar" "DarkYellow"
}

Pop-Location