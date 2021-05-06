code-list-installed-package() {
    code --list-extensions
}

code-install-package() {
    package=$1
    code --install-extension  $package
}