#!/usr/bin/env bash
# SessionStart hook for business-validator plugin

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

SKILL_FILE="${PLUGIN_ROOT}/skills/using-business-validator/SKILL.md"

# Fail-fast if meta-skill file cannot be read
if [ ! -f "$SKILL_FILE" ]; then
    cat <<EREOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "status": "degraded",
    "additionalContext": "ERROR: business-validator meta-skill not found at ${SKILL_FILE}. Plugin may be corrupted."
  }
}
EREOF
    exit 1
fi

using_bv_content=$(cat "$SKILL_FILE") || {
    cat <<EREOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "status": "degraded",
    "additionalContext": "ERROR: Failed to read business-validator meta-skill."
  }
}
EREOF
    exit 1
}

# Escape string for JSON embedding
escape_for_json() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}

using_bv_escaped=$(escape_for_json "$using_bv_content")

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "<EXTREMELY_IMPORTANT>\nYou have business-validator skills.\n\n**Below is the full content of your 'business-validator:using-business-validator' skill - your introduction to business validation skills. For all other skills, use the 'Skill' tool:**\n\n${using_bv_escaped}\n</EXTREMELY_IMPORTANT>"
  }
}
EOF

exit 0
