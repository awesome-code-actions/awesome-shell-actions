#!/bin/bash

stap-hello-world() {
	sudo stap -v -e 'probe vfs.read {printf("read performed\n"); exit()}'
}
