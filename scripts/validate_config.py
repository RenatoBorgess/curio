#!/usr/bin/env python3
"""Validador do preset Curió — faz parse de arquivos JSONC (JSON com comentários)
e checa as chaves estruturais mínimas esperadas.

Uso:
    python3 scripts/validate_config.py            # valida o config padrão
    python3 scripts/validate_config.py arquivo ...  # valida arquivos específicos
    python3 scripts/validate_config.py --expect-default maritaca/s5-free config/opencode.jsonc
                                                  # também exige um modelo default (usado no CI)
"""
import json
import sys
from pathlib import Path


def strip_comments(text: str) -> str:
    """Remove comentários // e /* */ de um JSONC, preservando strings."""
    result = []
    i, n = 0, len(text)
    in_string = False
    escaped = False
    while i < n:
        c = text[i]
        if in_string:
            result.append(c)
            if escaped:
                escaped = False
            elif c == "\\":
                escaped = True
            elif c == '"':
                in_string = False
            i += 1
            continue
        if c == '"':
            in_string = True
            result.append(c)
            i += 1
            continue
        if c == "/" and i + 1 < n:
            nxt = text[i + 1]
            if nxt == "/":
                while i < n and text[i] != "\n":
                    i += 1
                continue
            if nxt == "*":
                i += 2
                while i + 1 < n and not (text[i] == "*" and text[i + 1] == "/"):
                    i += 1
                i += 2
                continue
        result.append(c)
        i += 1
    return "".join(result)


def validate(path: Path, expected_default: "str | None" = None) -> bool:
    raw = path.read_text(encoding="utf-8")
    try:
        data = json.loads(strip_comments(raw))
    except json.JSONDecodeError as exc:
        print(f"FALHA  {path}: {exc}")
        return False

    problems = []
    if "provider" not in data or "maritaca" not in data.get("provider", {}):
        problems.append("bloco provider.maritaca ausente")
    if "model" not in data:
        problems.append("campo 'model' (default) ausente")
    options = data.get("provider", {}).get("maritaca", {}).get("options", {})
    if "baseURL" not in options:
        problems.append("provider.maritaca.options.baseURL ausente")

    models = data.get("provider", {}).get("maritaca", {}).get("models", {})
    default = data.get("model")
    if isinstance(default, str):
        provider_id, _, model_id = default.partition("/")
        if provider_id == "maritaca" and model_id not in models:
            problems.append(f"modelo default '{default}' não está no bloco models")
    if expected_default and default != expected_default:
        problems.append(f"modelo default é '{default}', esperado '{expected_default}'")

    if problems:
        print(f"FALHA  {path}: " + "; ".join(problems))
        return False

    print(f"OK     {path} · default {default} · provedor maritaca com {len(models)} modelo(s): {', '.join(models)}")
    return True


def main() -> None:
    args = sys.argv[1:]
    expected_default = None
    if "--expect-default" in args:
        i = args.index("--expect-default")
        if i + 1 >= len(args):
            print("FALHA  --expect-default precisa de um valor (ex.: maritaca/s5-free)")
            sys.exit(2)
        expected_default = args[i + 1]
        del args[i:i + 2]
    paths = [Path(p) for p in args] or [Path("config/opencode.jsonc")]
    failed = False
    for p in paths:
        if not p.exists():
            print(f"FALHA  {p}: arquivo não encontrado")
            failed = True
            continue
        if not validate(p, expected_default):
            failed = True
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
