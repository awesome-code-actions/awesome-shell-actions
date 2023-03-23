#!/bin/python3
from threading import Thread, Event
import subprocess
from time import sleep
import sys


def parse(key):
    if len(key.split("/")) == 2:
        [ns, name] = key.split("/")
        return ns, name, ""
    [ns, name, container] = key.split("/")
    return ns, name, container


class Tail(Thread):
    def __init__(self, key, file):
        Thread.__init__(self)
        self.key = key
        self.file = file
        self.stop_event = Event()
    pass

    def stop(self):
        self.p.kill()
        self.stop_event.set()
        self.join()
        pass

    def run(self):
        ns, name, container = parse(self.key)
        while True:
            if self.stop_event.is_set():
                break
            container_cmd = ""
            if container != "":
                container_cmd = f"-c {container}"

            cmd = f"kubectl logs -f -n {ns} {name} {container_cmd} --tail=1000  > {self.file}"
            print("start tail ", cmd)
            p = subprocess.Popen(cmd, shell=True, stderr=sys.stderr)
            self.p = p
            p.wait()
            print("sth wrong")
            sleep(1)
            pass
        pass


class TailManager:
    def __init__(self):
        self.jobs = {}
        self.works = {}
        pass

    def list(self):
        return list(self.jobs.values())
        pass

    def stop(self, keys):
        for key in keys:
            del self.jobs[key]
            self.works[key].stop()
            del self.works[key]
        pass

    def add(self, keys):
        for key in keys:
            file = key.replace("/", "_")
            t = Tail(key, f"./{file}.log")
            self.works[key] = t
            t.start()
            self.jobs[key] = {"key": key, "file": t.file}
            pass
        pass


def kubect_list_pod_container(ns, name):
    ret, err = onshot_cmd(
        f"kubectl get pods -n {ns} {name} -o jsonpath='{{.spec.containers[*].name}}'")
    if err != None:
        print(err)
        return []
    return ret.splitlines()


def kubect_list_pod(cmd):
    ret, err = onshot_cmd(cmd)
    if err != None:
        print("err", cmd, err)
        return [], None
    return ret.splitlines(), None


def list_key(cmd):
    pods, err = kubect_list_pod(cmd)
    keys = []
    for p in pods:
        ns, name, *oth = p.split()
        for c in kubect_list_pod_container(ns, name):
            keys.append(f"{ns}/{name}/{c}")
    pass
    return keys


def _gen_actions(left, right):
    # 为了从right变成left 我们需要add和remove什么
    lset = set(left)
    rset = set(right)
    return list(lset.difference(rset)), list(rset.difference(lset))
    pass


def gen_action(keys, jobs):
    # ret1 add
    # ret2 rm
    jobkeys = []
    for j in jobs:
        jobkeys.append(j["key"])
    if len(keys) == 0:
        return [], jobkeys
    if len(jobkeys) == 0:
        return keys, []
    return _gen_actions(keys, jobkeys)
    pass


def onshot_cmd(cmdstr):
    result = subprocess.run(cmdstr, capture_output=True, shell=True)
    if result.returncode:
        return str(result.stdout, encoding="utf8"), str(result.stderr, encoding="utf8")
    return str(result.stdout, encoding="utf8"), None
    pass


def run(podcmd):
    t = TailManager()
    while True:
        want_keys = list_key(podcmd)
        exist_keys = t.list()
        add_keys, rm_keys = gen_action(want_keys, exist_keys)
        if len(add_keys) != 0 or len(rm_keys) != 0:
            print("add", add_keys, "rm", rm_keys)
        t.stop(rm_keys)
        t.add(add_keys)
        sleep(1)
    pass

print(list_key(sys.argv[1]))
run(sys.argv[1])
