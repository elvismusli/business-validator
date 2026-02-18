# Business Validator

**AI-powered business idea validation pipeline for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).**

One slash command. Six autonomous research agents. A full Go/No-Go report with market sizing, competitor analysis, financial modeling, and risk assessment — delivered in minutes, not weeks.

## What It Does

Business Validator is a Claude Code plugin that takes your raw business idea and runs it through a structured validation pipeline:

```
/validate-idea
    |
    v
 Idea Intake (interactive)
    |
    +---> Market Research ----+
    |     (TAM/SAM/SOM,       |
    |      trends, growth)    |
    |                         |
    +---> Competitor Analysis -+---> Financial Modeling ---> Risk Assessment
          (5-10 competitors,   |    (unit economics,       (SWOT matrix,
           positioning map)    |     3 scenarios,           risk scoring,
                               |     break-even)            mitigation)
                               |
                               +---> Report Generation
                                     (executive summary,
                                      Go/No-Go score,
                                      PDF export)
```

**Output:** A comprehensive Markdown + PDF report with a weighted Go/No-Go recommendation.

## Quick Start

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed
- `pandoc` for PDF export (optional): `brew install pandoc`

### Install

```bash
claude plugins add /path/to/business-validator
```

### Use

```
/validate-idea
```

Answer 7 quick questions about your idea. Claude handles the rest autonomously — researching markets, analyzing competitors, building financial models, assessing risks, and assembling your report.

For a quick market overview without the full pipeline:

```
/market-report
```

## What's in the Report

| Section | What You Get |
|---------|-------------|
| **Executive Summary** | One-page overview with key findings and verdict |
| **Market Research** | TAM/SAM/SOM with sources, growth trends, regulatory landscape |
| **Competitive Landscape** | 5-10 competitors analyzed, comparison tables, positioning map, market gaps |
| **Financial Model** | Unit economics (CAC, LTV, margins), 3-scenario revenue forecast, break-even analysis |
| **SWOT Analysis** | Strengths, weaknesses, opportunities, threats matrix |
| **Risk Assessment** | Scored risk matrix with probability, impact, and mitigation strategies |
| **Go/No-Go Recommendation** | Weighted score across 5 dimensions with clear verdict and justification |

### Go/No-Go Scoring Framework

| Dimension | Weight |
|-----------|--------|
| Market Size & Growth | 25% |
| Competitive Position | 20% |
| Financial Viability | 25% |
| Risk Profile | 15% |
| Founder Readiness | 15% |

- **4.0+** — GO: Strong opportunity
- **3.0–3.9** — CONDITIONAL GO: Proceed with caution
- **2.0–2.9** — NO-GO: Significant issues to resolve
- **< 2.0** — NO-GO: Fundamental viability concerns

## Architecture

Built as a modular skill pipeline following the [Superpowers](https://github.com/obra/superpowers) plugin architecture:

```
business-validator/
  .claude-plugin/plugin.json        # Plugin manifest
  hooks/
    hooks.json                      # SessionStart hook registration
    session-start.sh                # Injects meta-skill at startup
  skills/
    using-business-validator/       # Meta-skill (loaded automatically)
    idea-intake/                    # Interactive business idea collection
    market-research/                # Autonomous market research via web
    competitor-analysis/            # Autonomous competitor discovery
    financial-modeling/             # Financial model with scenarios
    risk-assessment/                # SWOT + risk scoring
    report-generation/              # Final report assembly + PDF
  commands/
    validate-idea.md                # /validate-idea slash command
    market-report.md                # /market-report slash command
  scripts/
    verify.sh                       # Plugin integrity verification
```

### Key Design Decisions

- **File-based data flow** — Each skill writes its section to disk. Results are persistent, inspectable, and survive context compaction.
- **Parallel research** — Market research and competitor analysis run simultaneously via subagents.
- **Run ID isolation** — Each validation session gets a unique `YYYY-MM-DD-<slug>` identifier. No ambiguity, no file conflicts.
- **Hybrid interaction** — Interactive intake captures context that web search alone can't provide. Autonomous research then leverages Claude's tools efficiently.

## Works With

- Any business type: SaaS, e-commerce, marketplaces, services, hardware, consumer apps
- Any geography
- Any stage: napkin sketch to pivot decision

## Verification

Run the integrity check to verify all plugin files are present and valid:

```bash
bash scripts/verify.sh
```

## License

MIT
