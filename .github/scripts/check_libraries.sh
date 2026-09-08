#!/bin/bash
set -e

echo "============================================="
echo "   Checking Upstream WoW Community Libraries "
echo "============================================="

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

ROOT_DIR="$(pwd)"
LIBS_DIR="${ROOT_DIR}/Libs"

# 1. Clone Ace3
echo "[1/4] Cloning latest Ace3 suite..."
git clone --depth 1 https://github.com/WoWUIDev/Ace3.git "${TEMP_DIR}/Ace3"

# 2. Clone LibDeflate
echo "[2/4] Cloning latest LibDeflate..."
git clone --depth 1 https://github.com/safeteeWow/LibDeflate.git "${TEMP_DIR}/LibDeflate"

# 3. Clone LibDataBroker-1.1
echo "[3/4] Cloning latest LibDataBroker-1.1..."
git clone --depth 1 https://github.com/tekkub/libdatabroker-1-1.git "${TEMP_DIR}/LibDataBroker"

# 4. Fetch LibDBIcon-1.0
echo "[4/4] Fetching latest LibDBIcon-1.0..."
curl -s -f -L "https://raw.githubusercontent.com/Questie/Questie/master/Libs/LibDBIcon-1.0/LibDBIcon-1.0.lua" -o "${TEMP_DIR}/LibDBIcon-1.0.lua"

# Synchronize files
echo "Comparing and staging upstream files..."
cp "${TEMP_DIR}/Ace3/LibStub/LibStub.lua" "${LIBS_DIR}/LibStub/LibStub.lua"
cp -r "${TEMP_DIR}/Ace3/CallbackHandler-1.0/"* "${LIBS_DIR}/CallbackHandler-1.0/"

for mod in AceAddon-3.0 AceEvent-3.0 AceTimer-3.0 AceComm-3.0 AceSerializer-3.0 AceConsole-3.0; do
  cp -r "${TEMP_DIR}/Ace3/${mod}/"* "${LIBS_DIR}/${mod}/"
done

cp "${TEMP_DIR}/LibDeflate/LibDeflate.lua" "${LIBS_DIR}/LibDeflate/LibDeflate.lua"
cp "${TEMP_DIR}/LibDataBroker/LibDataBroker-1.1.lua" "${LIBS_DIR}/LibDataBroker-1.1/LibDataBroker-1.1.lua"
cp "${TEMP_DIR}/LibDBIcon-1.0.lua" "${LIBS_DIR}/LibDBIcon-1.0/LibDBIcon-1.0.lua"

# Check git diff in Libs
DIFF_STAT=$(git diff --stat "${LIBS_DIR}" || true)

if [ -n "${DIFF_STAT}" ]; then
  echo "New upstream library changes detected!"
  echo "${DIFF_STAT}"

  ISSUE_TITLE="Upstream Library Updates Detected (Ace3 / LibDeflate / DataBroker)"

  if command -v gh >/dev/null 2>&1; then
    EXISTING_ISSUE=$(gh issue list --search "${ISSUE_TITLE}" --json number --jq '.[0].number' || true)

    if [ -z "${EXISTING_ISSUE}" ]; then
      ISSUE_BODY=$(cat <<EOF
### 📦 Upstream Library Updates Detected

New versions or bugfixes are available for embedded community libraries:

\`\`\`
${DIFF_STAT}
\`\`\`

#### 🛠️ Action Items:
1. Run \`./scripts/update-libs.ps1\` locally to review library diffs.
2. Run \`verify_addon.ps1\` to ensure bracket balance and syntax compliance.
3. Test locally in the WoW Classic client.
4. Commit and bump version patch if needed.
EOF
)
      gh issue create --title "🔔 ${ISSUE_TITLE}" --body "${ISSUE_BODY}" --label "enhancement"
      echo "Created GitHub Issue for upstream library updates."
    else
      echo "Issue already exists (#${EXISTING_ISSUE}). Skipping creation."
    fi
  fi
else
  echo "All embedded community libraries are 100% up to date with upstream!"
fi
