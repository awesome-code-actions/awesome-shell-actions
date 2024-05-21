#!/bin/bash
SQL_BASE="$HOME/.sql"

function sql-eval() {
  mkdir -p $SQL_BASE
  sqlite3 $SQL_BASE/$(cat $SQL_BASE/.current).db "$@"
  return
}

function sql-list() {
  ls $SQL_BASE | grep db
  return
}

function sql-show-table() {
  local table=$(sql-list-table | fzf)
  sql-eval "PRAGMA table_info($table);"
  return
}

function sql-init-meta() {
  sql-eval "CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT);"
}

function sql-list-table() {
  sql-eval "SELECT name FROM sqlite_master WHERE type='table';"
}

function sql-create() {
  sqlite3 $SQL_BASE/$1.db "PRAGMA user_version;"
  return
}

function sql-use() {
  local db=$(sql-list | fzf)
  echo "$db"
  echo "$db" >$SQL_BASE/.current
  return
}
