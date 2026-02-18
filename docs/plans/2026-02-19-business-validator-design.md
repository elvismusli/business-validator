# Business Validator — Design Document

## Overview

Business Validator is a Claude Code plugin that provides a structured pipeline of skills for validating business ideas. It produces comprehensive market analysis reports with Go/No-Go recommendations.

Inspired by [superpowers](https://github.com/obra/superpowers), it follows the same plugin architecture: SKILL.md files with YAML frontmatter, SessionStart hooks, on-demand skill loading, and slash commands.

## Requirements

- **Target users**: Entrepreneurs, product managers, anyone evaluating a business idea
- **Business types**: Universal — SaaS, e-commerce, services, hardware, etc.
- **Output format**: Markdown report + PDF export
- **Interaction model**: Hybrid — interactive intake, then autonomous research and report generation
- **Report sections**: Market research, competitor analysis, financial model, SWOT, risk assessment, Go/No-Go recommendation

## Architecture

### Plugin Structure

```
business-validator/
  .claude-plugin/
    plugin.json                    # Plugin manifest
  hooks/
    hooks.json                     # SessionStart hook registration
    session-start.sh               # Injects meta-skill at startup
  skills/
    using-business-validator/      # Meta-skill (loaded at startup)
      SKILL.md
    idea-intake/                   # 1. Collect business idea info
      SKILL.md
    market-research/               # 2. Research market size & trends
      SKILL.md
    competitor-analysis/           # 3. Analyze competitors
      SKILL.md
    financial-modeling/            # 4. Build financial model
      SKILL.md
    risk-assessment/               # 5. SWOT + risk analysis
      SKILL.md
    report-generation/             # 6. Assemble report + PDF
      SKILL.md
      report-template.md           # Markdown report template
  commands/
    validate-idea.md               # /validate-idea — full pipeline
    market-report.md               # /market-report — market + competitors only
  docs/
    plans/
```

### Skill Pipeline

```
idea-intake (interactive)
    ├── market-research (autonomous) ──────┐
    └── competitor-analysis (autonomous) ──┤
                                           ├── financial-modeling (autonomous + questions)
                                           │        │
                                           └────────┴── risk-assessment (autonomous)
                                                               │
                                                         report-generation
```

### Data Flow

All intermediate results are stored as files:

```
docs/
  business-briefs/
    YYYY-MM-DD-<idea-name>.md              ← idea-intake creates
  reports/
    YYYY-MM-DD-<idea-name>/
      01-market-research.md                ← market-research writes
      02-competitor-analysis.md            ← competitor-analysis writes
      03-financial-model.md                ← financial-modeling writes
      04-risk-assessment.md                ← risk-assessment writes
      REPORT.md                            ← report-generation assembles
      REPORT.pdf                           ← report-generation converts
```

Each skill reads the brief + previous sections and writes its own section.

### Parallelization

- `market-research` and `competitor-analysis` run in parallel (both depend only on the brief)
- `financial-modeling` waits for market data
- `risk-assessment` waits for all previous sections
- Parallel execution uses the Task tool with subagents

## Skill Details

### 1. idea-intake

**Purpose**: Collect all information about the business idea through interactive questions.

**Collected data**:
- Idea name and 1-2 sentence description
- Problem being solved
- Target audience (who, where, willingness to pay)
- Proposed business model (subscription, one-time, freemium, etc.)
- Geographic focus
- Starting budget (order of magnitude)
- Known competitors (if any)

**Process**: Questions asked one at a time via `AskUserQuestion` with multiple-choice options where possible. Output saved as a business brief markdown file.

### 2. market-research

**Purpose**: Research the market using `WebSearch` and `WebFetch`.

**What is researched**:
- TAM / SAM / SOM with sources
- Market trends (growth/decline, key drivers)
- Regulatory environment (if applicable)
- Technology trends in the niche

**Output**: `## Market Research` section with tables and source links.

### 3. competitor-analysis

**Purpose**: Find and analyze 5-10 competitors.

**What is analyzed**:
- Direct and indirect competitors
- Their products, pricing, positioning
- Strengths and weaknesses
- Market share estimates
- Positioning map (table: price vs functionality)

**Output**: `## Competitive Landscape` section with comparison table.

### 4. financial-modeling

**Purpose**: Build a basic financial model.

**What is calculated**:
- Unit economics (CAC, LTV, LTV/CAC ratio)
- Revenue forecast for 12-36 months (3 scenarios: pessimistic, base, optimistic)
- Cost structure
- Break-even point
- Burn rate and runway

**Output**: `## Financial Model` section with scenario tables.

### 5. risk-assessment

**Purpose**: Synthesize data from all previous skills into risk evaluation.

**What is analyzed**:
- SWOT matrix
- Key risks (market, technical, financial, operational)
- Probability and impact of each risk
- Mitigation strategies

**Output**: `## SWOT Analysis` and `## Risk Assessment` sections.

### 6. report-generation

**Purpose**: Assemble all sections into a unified report, add Executive Summary and Go/No-Go recommendation, generate PDF.

**Final report structure**:
1. Executive Summary (1 page)
2. Business Idea Overview
3. Market Research
4. Competitive Landscape
5. Financial Model
6. SWOT Analysis
7. Risk Assessment
8. Go / No-Go Recommendation with justification
9. Next Steps (if Go)
10. Sources

**PDF generation**: Via `pandoc` or `wkhtmltopdf`.

## Commands

- `/validate-idea` — Runs the full pipeline from idea-intake to report-generation
- `/market-report` — Runs only market-research + competitor-analysis for a quick market overview

## Meta-skill: using-business-validator

Loaded at session start via SessionStart hook. Teaches Claude:
- What skills are available and when to invoke them
- That `/validate-idea` triggers the full pipeline
- That individual skills can be invoked separately
- How to find and read business briefs and reports

## Key Design Decisions

1. **File-based data flow** (not in-memory): Each skill writes to disk, making results persistent, inspectable, and resumable after context compaction.
2. **Hybrid interaction**: Interactive intake captures user context that web search alone can't provide. Autonomous research then leverages Claude's tools efficiently.
3. **Parallel research**: Market research and competitor analysis are independent and run simultaneously via subagents.
4. **Progressive output**: Each skill writes its section immediately, so partial results are available even if the pipeline is interrupted.
5. **PDF via pandoc**: Widely available, produces clean output, no custom server needed.
