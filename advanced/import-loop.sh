#!/bin/bash
set -e

ERRORS=/tmp/import_errors.txt
LOGFILE=/import/import-log.txt

# ----- log on/off flag -----
SAVE_LOG=$(echo "${SAVE_LOG:-}" | tr '[:upper:]' '[:lower:]')
ENABLE_LOG=0
[ "$SAVE_LOG" = "true" ] && ENABLE_LOG=1
# ---------------------------

: > "$ERRORS"

if [ "$ENABLE_LOG" -eq 1 ]; then
  : > "$LOGFILE"
  exec > >(tee -a "$LOGFILE") 2>&1
fi

TOTAL=0
INDEX=1

for f in /import/workflows/*.json; do
  TOTAL=$((TOTAL+1))
  WF=$(basename "$f")

  # ---------- PRE-CHECK: add name / active ----------
  BASENAME="${WF%.json}"
  node - <<'NODE' "$f" "$BASENAME"
    const fs   = require('fs');
    const file = process.argv[2];
    const defName = process.argv[3];

    try {
      const data = JSON.parse(fs.readFileSync(file, 'utf8'));
      let modified = false;

      if (!('name' in data))   { data.name   = defName; modified = true; }
      if (!('active' in data)) { data.active = false;   modified = true; }

      if (modified) {
        fs.writeFileSync(file, JSON.stringify(data, null, 2));
      }
    } catch (err) {
      console.error(`Skipping ${file}: ${err.message}`);
      process.exit(1);
    }
NODE
  # --------------------------------------------------

  echo "► ${INDEX} - Importing ${WF}"
  if n8n import:workflow --input="$f"; then
    echo "  ✓ Imported successfully"
  else
    echo "  ✗ Failed: ${WF}" | tee -a "$ERRORS"
  fi

  echo
  INDEX=$((INDEX+1))
done

FAILS=$(wc -l < "$ERRORS" | tr -d ' ')

printf '\n'
echo "========================================================"
printf '\n'
echo "Failed workflows: ${FAILS} out of ${TOTAL}"
cat "$ERRORS"
printf '\n'
