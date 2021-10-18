#!/bin/bash
note-search-snippet(){
	# @alias
	# @shortcut 
    vim $(rg '@snippet' $NS_HOME |fzf|sed 's/:/ /g'|sed 's/#//g'|awk '{print $1}' )
}
