#!/bin/env python3
import sys
dataf = open(sys.argv[1], 'r')
lines = dataf.readlines()

# string:[floatStr]
m = {}
total = 0.0
for line in lines:
    [moneyStr, group] = line.strip().split("\t")
    if group not in m:
        m[group] = []
    money = float(moneyStr)
    m[group].append(money)
    total += money
for group, moneys in m.items():
    groupSum = sum(moneys)
    print("{},{:.2f},{:.2f}%".format(group, groupSum, groupSum/total*100))
