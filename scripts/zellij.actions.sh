#!/bin/bash

function zel-ls() {
  zellij ls
}

function zel-attach() {
  zellij a $(zellij ls -n -s | fzf)
}

function zel-new() {
  zellij -s $1
}
