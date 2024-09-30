#!/bin/bash
function deepl-trans() (
    local data=$(cat <<EOF
{
    "text": "$1",
    "source_lang": "EN",
    "target_lang": "ZH"
}
EOF
)
  curl -X POST 'https://deeplx.missuo.ru/translate?key=B8OsbPRmX3VjXSyeAKBUkw_UyL-RCNITQMD_Wa0zWwM=' \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer B8OsbPRmX3VjXSyeAKBUkw_UyL-RCNITQMD_Wa0zWwM=" \
    -d "$data"
)
