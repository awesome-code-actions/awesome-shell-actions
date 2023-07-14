#!/bin/bash

function fio-benchmark() {
  fio -filename=./test.file -direct=1 -iodepth 1 -thread -rw=write -ioengine=psync -bs=16k -size=2G -numjobs=10 -runtime=60 -group_reporting -name=test_w
}
