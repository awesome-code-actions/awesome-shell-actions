logseq-sync() {
	cd $LOGSEQ_PATH
	git pull origin master
	cd -
}

logseq-push() {
	cd $LOGSEQ_PATH
	git push origin master
	cd -
}