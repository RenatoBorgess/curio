#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────
# CURIÓ 🐦 — Instalador/configurador do preset comunitário (NÃO OFICIAL)
# para agentes de código: coloca o OpenCode apontando para os modelos
# da Maritaca AI (Sabiá e S5).
#
# Uso:
#   ./scripts/setup.sh                 # instala (se preciso) e aplica config global
#   ./scripts/setup.sh --project DIR   # aplica config na pasta do projeto
#   ./scripts/setup.sh --skip-install  # pula a instalação do OpenCode
#   ./scripts/setup.sh --dry-run       # mostra o que faria, sem executar
#   ./scripts/setup.sh --help
# ──────────────────────────────────────────────────────────────────
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_SRC="$REPO_DIR/config/opencode.jsonc"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
GLOBAL_CONFIG_DIR="$XDG_CONFIG_HOME/opencode"
GLOBAL_CONFIG_FILE="$GLOBAL_CONFIG_DIR/opencode.jsonc"

PROJECT_DIR=""
SKIP_INSTALL=0
DRY_RUN=0

usage() {
  cat <<'USAGE'
Curió 🐦 — preset comunitário (não oficial) para o OpenCode

Uso: scripts/setup.sh [opções]

Opções:
  --project DIR    Copia o preset para DIR/opencode.jsonc (config por projeto)
                   em vez do diretório de config global do usuário.
  --skip-install   Não tenta instalar o OpenCode via npm (assume que já existe).
  --dry-run        Mostra as ações planejadas sem executá-las.
  -h, --help       Esta mensagem.

Ambiente:
  MARITACA_API_KEY   Sua chave da API da Maritaca.
                     Gere em: https://plataforma.maritaca.ai/chaves-de-api

Exemplos:
  export MARITACA_API_KEY='...'
  ./scripts/setup.sh
  opencode
USAGE
}

info()  { printf '\n\033[1;36m▸ %s\033[0m\n' "$*"; }
ok()    { printf '\033[1;32m✔ %s\033[0m\n' "$*"; }
warn()  { printf '\033[1;33m⚠ %s\033[0m\n' "$*"; }
die()   { printf '\033[1;31m✘ %s\033[0m\n' "$*"; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)      PROJECT_DIR="${2:?informe o diretório do projeto}"; shift 2 ;;
    --skip-install) SKIP_INSTALL=1; shift ;;
    --dry-run)      DRY_RUN=1; shift ;;
    -h|--help)      usage; exit 0 ;;
    *)              die "Opção desconhecida: $1 (veja --help)" ;;
  esac
done

[[ -f "$CONFIG_SRC" ]] || die "Arquivo de origem não encontrado: $CONFIG_SRC"

info "Curió v0.1 — preset comunitário (não oficial) · $(basename "$REPO_DIR")"

# ── 1) Dependências ───────────────────────────────────────────────
command -v node >/dev/null 2>&1 || die "Node.js não encontrado. Instale em https://nodejs.org antes de continuar."

if command -v opencode >/dev/null 2>&1; then
  ok "OpenCode já instalado ($(opencode --version 2>/dev/null || echo 'versão desconhecida'))."
elif [[ "$SKIP_INSTALL" -eq 1 ]]; then
  warn "Instalação pulada (--skip-install). Certifique-se de ter o OpenCode disponível: https://opencode.ai/docs"
else
  info "OpenCode não encontrado — instalando via npm (pacote 'opencode-ai@latest')…"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "  (dry-run) npm install -g opencode-ai@latest"
  else
    npm install -g opencode-ai@latest \
      || die "Falha ao instalar o OpenCode via npm. Instale manualmente: https://opencode.ai/docs"
    ok "OpenCode instalado."
  fi
fi

# ── 2) Destino da configuração ────────────────────────────────────
if [[ -n "$PROJECT_DIR" ]]; then
  DEST_DIR="$PROJECT_DIR"
  DEST_FILE="$PROJECT_DIR/opencode.jsonc"
  mkdir_help="criará o diretório do projeto, se necessário"
else
  DEST_DIR="$GLOBAL_CONFIG_DIR"
  DEST_FILE="$GLOBAL_CONFIG_FILE"
  mkdir_help="criará $GLOBAL_CONFIG_DIR, se necessário"
fi

info "Aplicando preset em: $DEST_FILE ($mkdir_help)"

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "  (dry-run) mkdir -p \"$DEST_DIR\""
  if [[ -f "$DEST_FILE" ]]; then
    echo "  (dry-run) cp \"$DEST_FILE\" \"$DEST_FILE.bak.<timestamp>\""
  fi
  echo "  (dry-run) cp \"$CONFIG_SRC\" \"$DEST_FILE\""
else
  mkdir -p "$DEST_DIR"
  if [[ -f "$DEST_FILE" ]]; then
    BACKUP="$DEST_FILE.bak.$(date +%Y%m%d%H%M%S)"
    cp "$DEST_FILE" "$BACKUP"
    ok "Configuração existente salva como: $BACKUP"
  fi
  cp "$CONFIG_SRC" "$DEST_FILE"
  ok "Preset aplicado."
fi

# ── 3) Chave da API ───────────────────────────────────────────────
if [[ -z "${MARITACA_API_KEY:-}" ]]; then
  warn "MARITACA_API_KEY não está definida no seu ambiente."
  cat <<'KEYMSG'
  Para gerar uma chave (grátis para começar):
    https://plataforma.maritaca.ai/chaves-de-api

  Depois, exporte-a no seu shell (permanente: adicionar ao ~/.bashrc):
    export MARITACA_API_KEY='sua-chave-aqui'
KEYMSG
else
  ok "MARITACA_API_KEY detectada."
fi

# ── 4) Próximos passos ────────────────────────────────────────────
info "Próximos passos"
cat <<'NEXT'
  1. Rode o OpenCode na raiz do seu projeto:

       opencode

  2. Confira se os modelos aparecem no seletor (/models).
     O default configurado pelo preset é: maritaca/s5-free
     (gratuito por tempo limitado; para uso contínuo, troque por maritaca/s5).

  3. Faça um teste leve: peça algo curto, tipo
     "explique este arquivo em 3 linhas".

  Problemas? Veja o Troubleshooting do README do Curió e abra uma issue.
NEXT

ok "Setup concluído. Bom trabalho! 🐦"
