#!/bin/sh
set -e

# Check if import should run based on environment variables
# If RUN_IMPORT_ON_STARTUP is set and is false, skip import
if [ "${RUN_IMPORT_ON_STARTUP:-}" != "" ] && [ "${RUN_IMPORT_ON_STARTUP}" = "false" ]; then
    echo "RUN_IMPORT_ON_STARTUP is false. Skipping import."
    exit 0
fi

echo "Starting import process..."

ERROR_DIR=/import/workflows/with_error
mkdir -p "$ERROR_DIR"

ERRORS=/tmp/import_errors.txt
LOGFILE="$ERROR_DIR/import-log.txt"  
: >"$ERRORS"  : >"$LOGFILE"

log_error() {                        
  printf '%s\n' "$1" | tee -a "$ERRORS" >>"$LOGFILE"
}

##############################################################################
# 1. Credentials
##############################################################################
if ls /import/credentials/*.json >/dev/null 2>&1; then
  echo "=== Importing credentials ===" | tee -a "$LOGFILE"
  if output=$(n8n import:credentials --separate --input=/import/credentials 2>&1)
  then
    printf '%s\n' "$output" | tee -a "$LOGFILE"
    echo "✓ Credentials imported successfully" | tee -a "$LOGFILE"
  else
    printf '%s\n' "$output" | tee -a "$LOGFILE"
    log_error "✗ Error importing credentials"
  fi
  echo | tee -a "$LOGFILE"
else
  echo "No credential files found — skipping" | tee -a "$LOGFILE"
  echo | tee -a "$LOGFILE"
fi

##############################################################################
# 2. Workflows
##############################################################################
TOTAL=0
INDEX=1

for f in /import/workflows/*.json; do
  [ -e "$f" ] || break
  TOTAL=$((TOTAL+1))
  WF=$(basename "$f")
  BASENAME=${WF%.json}

  # ---------- Pre-patch & JSON validation ----------
  if node - "$f" "$BASENAME" <<'NODE'
    const fs   = require('fs');
    const file = process.argv[2];
    const def  = process.argv[3];

    let data;
    try { data = JSON.parse(fs.readFileSync(file,'utf8')); }
    catch { process.exit(1); }

    let changed = false;
    if (!('name'   in data)) { data.name   = def;  changed = true; }
    if (!('active' in data)) { data.active = false; changed = true; }

    if (Array.isArray(data.tags)) {
      data.tags.forEach(t=>{
        if (typeof t.name==='string'&&t.name.length>24){
          t.name=t.name.slice(0,24); changed=true;
        }
      });
    }
    if (changed) fs.writeFileSync(file, JSON.stringify(data,null,2));
NODE
  then
    : # ok
  else
    log_error "✗ Invalid JSON: ${WF}  → moved to with_error"
    mv "$f" "$ERROR_DIR/"
    INDEX=$((INDEX+1))
    continue
  fi
  # -----------------------------------------------

  echo "► ${INDEX} - Importing ${WF}" | tee -a "$LOGFILE"
  if output=$(n8n import:workflow --input="$f" 2>&1)
  then
    printf '%s\n' "$output" | tee -a "$LOGFILE"
    echo "  ✓ Imported successfully" | tee -a "$LOGFILE"
  else
    printf '%s\n' "$output" | tee -a "$LOGFILE"
    log_error "✗ Failed on import: ${WF}  → moved to with_error"
    mv "$f" "$ERROR_DIR/"
  fi
  echo | tee -a "$LOGFILE"
  INDEX=$((INDEX+1))
done

##############################################################################
# 3. Summary
##############################################################################
FAILS=$(wc -l <"$ERRORS" | tr -d ' ')
printf '\n========================================================\n\n' | tee -a "$LOGFILE"
echo "Failed workflows: $FAILS out of $TOTAL" | tee -a "$LOGFILE"
cat "$ERRORS" | tee -a "$LOGFILE"
printf '\n' | tee -a "$LOGFILE"

EXIT_ON_FAIL=$(printf '%s' "${EXIT_ON_FAIL:-false}" | tr '[:upper:]' '[:lower:]')
if [ "$EXIT_ON_FAIL" = "true" ] && [ "$FAILS" -gt 0 ]; then
  exit 1
fi
