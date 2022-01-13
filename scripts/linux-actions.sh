#!/bin/bash

openfile-get-limit() {
	echo "current"
	ulimit -n
	echo "all"
	ulimit -aH
}

openfile-set-limit() {
	local lm=$1
	ulimit -n $lm
}


edit-which() {
	local w=$1
	vim $(which $w)
}