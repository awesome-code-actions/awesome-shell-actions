#!/bin/bash

function zellij-ls() {
  zellij ls
}

function zellij-attach() {
  zellij a $(zellij ls | fzf)
}

function zellij-new() {
  zellij -s $1
}
