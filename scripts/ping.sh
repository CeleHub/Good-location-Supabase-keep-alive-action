#!/bin/bash

PROJECTS='${{ secrets.PROJECTS_CONFIG }}'

SUCCESS=0
FAIL=0

SUMMARY="SUPABASE KEEP-ALIVE SUMMARY\n==================================\n"

TELEGRAM="🚀 Supabase Keep-Alive Report\n\n"

echo "$PROJECTS" | jq -c '.[]' | while read project; do

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
    SUMMARY+="\n✅ $NAME"
    TELEGRAM+="✅ $NAME PING SUCCESSFUL\n"
    ((SUCCESS++))
  else
    echo "❌ $NAME PING FAILED"
    SUMMARY+="\n❌ $NAME"
    TELEGRAM+="❌ $NAME PING FAILED\n"
    ((FAIL++))
  fi

done

TOTAL=$((SUCCESS + FAIL))

SUMMARY+="\n\n----------------------------------"
SUMMARY+="\nTotal Projects : $TOTAL"
SUMMARY+="\nSuccessful      : $SUCCESS"
SUMMARY+="\nFailed          : $FAIL"
SUMMARY+="\n=================================="

TELEGRAM+="\n📊 Summary:\nSuccess: $SUCCESS | Failed: $FAIL"

echo "summary<<EOF" >> $GITHUB_OUTPUT
echo -e "$SUMMARY" >> $GITHUB_OUTPUT
echo "EOF" >> $GITHUB_OUTPUT

echo "telegram_message<<EOF" >> $GITHUB_OUTPUT
echo -e "$TELEGRAM" >> $GITHUB_OUTPUT
echo "EOF" >> $GITHUB_OUTPUT