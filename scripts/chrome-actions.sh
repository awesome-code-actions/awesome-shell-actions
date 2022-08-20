#!/bin/bash

function chrome-kill-me() {
    ps -aux |grep chrome| awk '{print $2}' |xargs -I{} kill -9 {}  
}
