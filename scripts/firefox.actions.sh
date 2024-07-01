#!/bin/bash
function ff-find-profile-folder() {
  fd -a release ~/.mozilla/firefox/ | head -n1
}

function ff-init-csss() {
  local css=$(
    cat <<EOF
/* 隐藏tabbar*/
#TabsToolbar { visibility: collapse !important; } /* the most important port */


/* 隐藏导航栏*/
#nav-bar {
	position: fixed !important;
	left: 10%;
	right: 10%;
	z-index: 1;
	transition: top 0.3s cubic-bezier(0.270, 0.910, 0.435, 1.280), opacity 0.1s ease !important;
	border-top: none !important;
	border-radius: 10px !important;
	border: 1px solid var(--tab-selected-bgcolor) !important;
	opacity: 0;
    pointer-events: none; /*隐藏状态的导航栏不能被点击*/
}

#navigator-toolbox {
	border-bottom: none !important;
}

#navigator-toolbox:is(:focus-within, :has([open])) {
	#nav-bar {
		top: 30%;
		opacity: 1;
        border: 1px solid black !important;
        pointer-events: auto;
	}
}

#navigator-toolbox:not(:focus-within, :has([open])) #nav-bar {
	transition-delay: 0.2s !important;
}

EOF
  )
  local profile_folder=$(ff-find-profile-folder)
  mkdir -p $profile_folder/chrome
  echo "$css" >$profile_folder/chrome/userChrome.css
}
