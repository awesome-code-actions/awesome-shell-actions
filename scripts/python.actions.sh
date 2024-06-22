#!/bin/bash

function py-allow-break-package() (
  sudo rm /usr/lib/python3.*/EXTERNALLY-MANAGED
)

function pip-list-installed() (
  pip list --format=columns
)