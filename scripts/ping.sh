#!/bin/bash

# ✅ FIXED: read from environment variable (NOT GitHub syntax)
PROJECTS="$PROJECTS_CONFIG"

SUCCESS=0
FAIL=0

SUMMARY="SUPABASE KEEP-ALIVE SUMMARY
=================================="

TELEGRAM="🚀 Supabase Keep-Alive Report

"

while read -r project; do

  NAME=$(echo "$project" | jq -r '.name')
  URL=$(echo "$project" | jq -r '.url')
  KEY=$(echo "$project" | jq -r '.apikey')
  TABLE=$(echo "$project" | jq -r '.table')

  echo "Pinging $NAME..."

  if curl -s --fail \
    "$URL/rest/v1/$TABLE?select=id&limit=1" \
    -H "apikey: $KEY" \
    -H "Authorization: Bearer $KEY"
  then
    echo "✅ $NAME PING SUCCESSFUL"
    SUMMARY+="
✅ $NAME"
    TELEGRAM+="✅ $NAME PING SUCCESSFUL
"
    ((SUCCESS++))
  else
    echo "❌ $NAME PING FAILED"
    SUMMARY+="
❌ $NAME"
    TELEGRAM+="❌ $NAME PING FAILED
"
    ((FAIL++))
  fi

done < <(echo "$PROJECTS" | jq -c '.[]')

TOTAL=$((SUCCESS + FAIL))

SUMMARY+="

----------------------------------
Total Projects : $TOTAL
Successful      : $SUCCESS
Failed          : $FAIL
=================================="

TELEGRAM+="
📊 Summary:
Success: $SUCCESS | Failed: $FAIL"

# ✅ GitHub Outputs (correct format)
{
  echo "summary<<EOF"
  echo -e "$SUMMARY"
  echo "EOF"
} >> "$GITHUB_OUTPUT"

{
  echo "telegram_message<<EOF"
  echo -e "$TELEGRAM"
  echo "EOF"
} >> "$GITHUB_OUTPUT"