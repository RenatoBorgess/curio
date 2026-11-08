# 🐦 Curió

**Preset brasileiro para agentes de código** — leva os modelos da [Maritaca AI](https://www.maritaca.ai/) (família Sabiá e S5) para dentro do [OpenCode](https://opencode.ai/) com defaults em português e um caminho aberto para as fontes brasileiras.

> **⚠️ Projeto independente e NÃO OFICIAL.** Não é mantido pela Maritaca AI nem pelo projeto OpenCode, e não vende acesso a nada. "Maritaca", "Sabiá" e "S5" são marcas dos seus respectivos titulares; aparecem aqui apenas como referência técnica. O conteúdo deste repositório é distribuído sob licença MIT.

**Status: v0.1 experimental** — existe, instala e roda; a bateria de testes end-to-end ainda não rodou (veja o Roadmap honesto mais abaixo). Use, quebre, reporte: é assim que fica bom.

---

## Por que ele existe

Configurar um provedor nacional num agente de código hoje exige abrir JSON, descobrir endpoint, caçar nomes de modelo e rezar para o streaming funcionar. O Curió resolve isso com **um comando só**:

```bash
./scripts/setup.sh && opencode
```

O motor continua sendo o OpenCode oficial — **nunca forkeado**. O Curió cuida do assento, do tapete e do manual: preset pronto, prompts em PT-BR, instalação sem atrito e bandeira brasileira na frente.

| É | Não é |
|---|---|
| Configuração versionada + instalador + prompts + docs | Fork ou cópia do OpenCode |
| Caminho fácil para usar Sabiá/S5 nos seus projetos | Substituto da plataforma Maritaca (não hospeda modelo nenhum) |
| Distribuição *bring-your-own-key* (você gera sua chave oficial) | Revenda de créditos/acesso |
| Projeto comunitário e independente | Marca concorrente da Maritaca (pelo contrário) |

## Instalação rápida

Pré-requisitos: **Node.js ≥ 18** e uma **[chave da API da Maritaca](https://plataforma.maritaca.ai/chaves-de-api)** (grátis para começar).

```bash
export MARITACA_API_KEY='sua-chave-aqui'   # gere na plataforma
./scripts/setup.sh                          # instala o OpenCode (se preciso) e aplica o preset
opencode                                     # abre o agente na raiz do seu projeto
```

Opções úteis do instalador:

```bash
./scripts/setup.sh --project ~/projetos/api   # aplica na pasta de um projeto específico
./scripts/setup.sh --skip-install             # se você já tem o OpenCode instalado
./scripts/setup.sh --dry-run                  # mostra o que faria, sem executar
```

### Onde cai a configuração

Por padrão, no config global do usuário: `~/.config/opencode/opencode.jsonc` (respeita `$XDG_CONFIG_HOME`). Com `--project DIR`, vai para `DIR/opencode.jsonc`, fixando o preset por repositório. Na mão, é literalmente copiar `config/opencode.jsonc` para um desses lugares.

## Modelos incluídos

IDs conferidos na [documentação oficial de modelos](https://docs.maritaca.ai/pt/modelos):

| ID no preset | Modelo | Perfil |
|---|---|---|
| `s5-free` | S5 Free | **Default do preset.** Gratuito por tempo limitado; aceita só texto; 1M de contexto |
| `s5` | S5 | O mais inteligente da família; raciocínio ajustável; 1M de contexto |
| `s5-nano` | S5 Nano | Pesos abertos; o melhor custo; 256K de contexto |
| `sabia-4` | Sabiá 4 | Generalista agêntico; foco em contexto brasileiro; 128K |
| `sabia-4-thinking` | Sabiá 4 Thinking | Raciocínio explícito antes da resposta; 1M de contexto |
| `sabiazinho-4` | Sabiazinho 4 | Rápido e barato para escala; ótimo em tarefas jurídicas |

Existem variantes `*-br-sp` (inferência 100% em território nacional, para casos de soberania/residência de dados) — adicione ao bloco `models` quando precisar. O default do preset é `maritaca/s5-free`, para você testar sem gastar créditos. A Maritaca avisa que a oferta gratuita é temporária e pode acabar a qualquer momento; para uso contínuo, troque a linha `"model"` do config por `maritaca/s5` (ou outro modelo da tabela). O CI checa esse default com `python3 scripts/validate_config.py --expect-default maritaca/s5-free config/opencode.jsonc`.

## Estrutura

```
curio/
├── config/opencode.jsonc       ← o coração: preset do provedor
├── scripts/setup.sh           ← instalador amigável
├── scripts/validate_config.py  ← validador local (usado no CI também)
├── prompts/codify-ptbr.md      ← prompt de sistema em PT-BR (cole no seu agente)
├── .github/workflows/ci.yml    ← checagens mínimas automatizadas
└── LICENSE.txt                 ← MIT
```

## Troubleshooting

- **"MARITACA_API_KEY não definida"** — exporte a variável no shell (e adicione ao `~/.bashrc` para persistir) ou cole a chave direto no campo `apiKey` do config.
- **Erro de autenticação** — confira se a chave está ativa na [plataforma](https://plataforma.maritaca.ai/) e se o `baseURL` do preset confere com a documentação atual.
- **Modelo não aparece no seletor** — confirme os IDs vigentes na [doc de modelos](https://docs.maritaca.ai/pt/modelos); versões novas do OpenCode podem mudar detalhes do catálogo.
- **Streaming ou ferramentas irregulares** — esperado na v0.1; abra uma issue descrevendo o teste, a versão do OpenCode e o modelo usado.

## Roadmap honesto

- [x] Preset mínimo + instalador + documentação
- [ ] Testes end-to-end (roteiro D0: chat, streaming, tool calling, contexto longo, erros)
- [ ] Pacote MCP Brasil (legislação, dados públicos) plugável em qualquer agente
- [ ] Identidade visual/mascote oficial do projeto

## Contribuindo & marca

- Contribuições são muito bem-vindas — principalmente correções testadas contra versões recentes do OpenCode. Antes de enviar, rode `python3 scripts/validate_config.py`.
- Preserve os avisos de não-oficialidade em todos os materiais.
- Não use logos nem trate "Maritaca"/"Sabiá" como algo seu — referencie nominalmente.
- Mantenha mudanças pequenas e explicáveis. Fork do motor, somente como último recurso.

## Licença

Código, configurações e textos: **MIT** (ver [LICENSE.txt](LICENSE.txt)). Nomes de terceiros pertencem aos seus respectivos donos. Este projeto não lucra com marca alheia: quer apenas facilitar o encontro entre dev brasileiro e IA brasileira.
