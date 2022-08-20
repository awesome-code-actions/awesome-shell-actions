#!/usr/bin/env bash

function code-list-installed-package() {
    code --list-extensions
}

function code-install-package() {
    package=$1
    code --install-extension $package
}
