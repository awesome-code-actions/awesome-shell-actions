#!/bin/bash

function zotero-list-vh-note() (
  sqlite3 -json "file:///$HOME/Zotero/zotero.sqlite?immutable=1" "SELECT annote.text,annote.color,json_extract(annote.position,'$.value') as pos,json_extract(cache.data,'$.links.enclosure.title') as title from itemAnnotations as annote left join items on annote.parentItemID = items.itemID left join syncCache as cache on items.key = cache.key   where annote.color in ('#e56eee','#f19837')" | jq .
)

