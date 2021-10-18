#!/bin/zsh

random() {
    local size=$1
    echo ${RANDOM:0:$size}
}

node_s() {
    # 读取字符串作为node脚本并执行
    local code=$1
    echo $code ~/
    echo $code
}

rust_s() {

}

python3_s() {

}
