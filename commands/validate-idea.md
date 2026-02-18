---
description: Run the full business validation pipeline — from idea intake to final report with Go/No-Go recommendation
disable-model-invocation: true
---

Invoke the business-validator:idea-intake skill and follow it exactly. After the business brief is saved and the run_id is generated, run the full pipeline: market-research and competitor-analysis in parallel (passing the run_id to both), then financial-modeling, then risk-assessment, then report-generation. Pass the run_id to every skill. Follow each skill exactly as presented.
