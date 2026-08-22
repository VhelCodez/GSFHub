#!/bin/bash
set -e

# 1. Read current TOC interface from GSFHub.toc
CURRENT_TOC=$(grep -i '^## Interface:' GSFHub.toc | awk '{print $3}' | tr -d '\r')
echo "Current Addon TOC Interface: ${CURRENT_TOC}"

# 2. Fetch live build data from wago.tools
BUILDS_JSON=$(curl -s -H "User-Agent: GSFHub-Build-Checker" https://wago.tools/api/builds)

# Query latest wow_anniversary (TBC 2.5.x Anniversary) or wow_classic_era build
LATEST_VERSION=$(echo "${BUILDS_JSON}" | jq -r '(.wow_anniversary // .wow_classic_era)[0].version')
LATEST_DATE=$(echo "${BUILDS_JSON}" | jq -r '(.wow_anniversary // .wow_classic_era)[0].created_at')

echo "Latest Live Blizzard Client: ${LATEST_VERSION} (Released: ${LATEST_DATE})"

if [ -z "${LATEST_VERSION}" ] || [ "${LATEST_VERSION}" = "null" ]; then
  echo "Failed to retrieve live version data. Exiting."
  exit 0
fi

# 3. Calculate expected TOC interface number (e.g. 2.5.6 -> 20506)
IFS='.' read -r MAJOR MINOR PATCH BUILD <<< "${LATEST_VERSION}"
EXPECTED_TOC=$(printf "%d%02d%02d" "${MAJOR}" "${MINOR}" "${PATCH}")
echo "Calculated Expected TOC Interface: ${EXPECTED_TOC}"

# 4. Compare with current TOC
if [ "${EXPECTED_TOC}" -gt "${CURRENT_TOC}" ]; then
  echo "A newer client interface was detected (${EXPECTED_TOC} > ${CURRENT_TOC})!"
  
  ISSUE_TITLE="Blizzard Patch Detected: Client ${LATEST_VERSION} (Interface ${EXPECTED_TOC})"
  
  # Check if issue already exists
  EXISTING_ISSUE=$(gh issue list --search "${ISSUE_TITLE}" --json number --jq '.[0].number' || true)
  
  if [ -z "${EXISTING_ISSUE}" ]; then
    ISSUE_BODY=$(cat <<EOF
### 🎮 New Blizzard Client Build Detected

A new World of Warcraft client version has been published by Blizzard:

- **Live Version:** \`${LATEST_VERSION}\`
- **Calculated Interface TOC:** \`${EXPECTED_TOC}\`
- **Current Addon TOC:** \`${CURRENT_TOC}\`
- **Release Date:** \`${LATEST_DATE}\`

#### 🛠️ Action Items:
1. Update \`## Interface: ${EXPECTED_TOC}\` in \`GSFHub.toc\`.
2. Check for any breaking UI/API changes in this patch.
3. Bump addon patch version (e.g. \`v1.1.1\`) and tag release.
EOF
)

    gh issue create --title "🚨 ${ISSUE_TITLE}" --body "${ISSUE_BODY}"
    echo "Created GitHub Issue for new client interface ${EXPECTED_TOC}."
  else
    echo "Issue already exists (#${EXISTING_ISSUE}). Skipping creation."
  fi
else
  echo "GSFHub TOC (${CURRENT_TOC}) is up to date with live client (${EXPECTED_TOC})."
fi
