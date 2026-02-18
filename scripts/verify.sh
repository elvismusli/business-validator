#!/usr/bin/env bash
# Verify business-validator plugin integrity
set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
errors=0

echo "=== Business Validator Plugin Verification ==="
echo ""

# 1. Check plugin.json is valid JSON
echo -n "Checking .claude-plugin/plugin.json ... "
if python3 -m json.tool "$PLUGIN_ROOT/.claude-plugin/plugin.json" > /dev/null 2>&1; then
    echo "OK"
else
    echo "FAIL (invalid JSON)"
    errors=$((errors + 1))
fi

# 2. Check hooks.json is valid JSON
echo -n "Checking hooks/hooks.json ... "
if python3 -m json.tool "$PLUGIN_ROOT/hooks/hooks.json" > /dev/null 2>&1; then
    echo "OK"
else
    echo "FAIL (invalid JSON)"
    errors=$((errors + 1))
fi

# 3. Check session-start.sh is executable
echo -n "Checking hooks/session-start.sh is executable ... "
if [ -x "$PLUGIN_ROOT/hooks/session-start.sh" ]; then
    echo "OK"
else
    echo "FAIL (not executable)"
    errors=$((errors + 1))
fi

# 4. Check all SKILL.md files exist
skills=(
    "using-business-validator"
    "idea-intake"
    "market-research"
    "competitor-analysis"
    "financial-modeling"
    "risk-assessment"
    "report-generation"
)

for skill in "${skills[@]}"; do
    echo -n "Checking skills/$skill/SKILL.md ... "
    if [ -f "$PLUGIN_ROOT/skills/$skill/SKILL.md" ]; then
        echo "OK"
    else
        echo "FAIL (missing)"
        errors=$((errors + 1))
    fi
done

# 5. Check report template exists
echo -n "Checking skills/report-generation/report-template.md ... "
if [ -f "$PLUGIN_ROOT/skills/report-generation/report-template.md" ]; then
    echo "OK"
else
    echo "FAIL (missing)"
    errors=$((errors + 1))
fi

# 6. Check commands exist
for cmd in validate-idea market-report; do
    echo -n "Checking commands/$cmd.md ... "
    if [ -f "$PLUGIN_ROOT/commands/$cmd.md" ]; then
        echo "OK"
    else
        echo "FAIL (missing)"
        errors=$((errors + 1))
    fi
done

# 7. Dry-run session-start hook
echo -n "Dry-running session-start.sh ... "
hook_output=$(cd "$PLUGIN_ROOT" && bash hooks/session-start.sh 2>&1)
if echo "$hook_output" | python3 -m json.tool > /dev/null 2>&1; then
    echo "OK (valid JSON)"
else
    echo "FAIL (invalid output)"
    echo "  Output: $hook_output"
    errors=$((errors + 1))
fi

echo ""
if [ "$errors" -eq 0 ]; then
    echo "All checks passed."
    exit 0
else
    echo "FAILED: $errors error(s) found."
    exit 1
fi
