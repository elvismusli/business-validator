---
description: Run the full business validation pipeline — from idea intake to final report with Go/No-Go recommendation
disable-model-invocation: true
---

Invoke the business-validator:brainstorming skill first and follow it exactly. After the user confirms the refined concept, invoke business-validator:idea-intake to collect structured details and generate the run_id. Then run the full pipeline: market-research and competitor-analysis in parallel (passing the run_id to both), then financial-modeling, then risk-assessment, then report-generation. Pass the run_id to every skill. Follow each skill exactly as presented.
