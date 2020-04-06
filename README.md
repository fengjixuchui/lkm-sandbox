Linux Kernel Module (LKM) Sandbox
---
[![Build Status](https://travis-ci.org/tpiekarski/lkm-sandbox.svg?branch=master)](https://travis-ci.org/tpiekarski/lkm-sandbox)

## [Overview](#overview)
[Modules](#modules) / [Building](#building) / [Testing](#testing) / [Make](#make) / [License](#license) / [Notes](#notes) / [Books](#books) / [Links](#links)

The Linux Kernel Module (LKM) Sandbox is a collection of different modules to learn, test and experiment with
the development of Linux Kernel Modules. The purpose of this repository is also to practice development within
the Linux Kernel and study miscellaneous concepts before moving on to submit the very first patch to the kernel.

Most of the modules illustrate one concept and shows how to use the Kernel API. A few of the modules combine more
than one concept to present concepts working together. For example the module *[lkm_device](lkm_device.c)* is 
accessing a character device and storing its major number in /proc and the module *[lkm_mem](lkm_mem.c)* is 
exposing memory/swap information by files in /proc. 

I hope it can be valuable for other developers which try to approach the Linux Kernel.

## [Modules](#modules)
#|Module|Source|Description
---|---|---|---
1|LKM Device|[lkm_device.c](lkm_device.c)|Module showing how to operate with character devices and storing device information in /proc
2|LKM Memory|[lkm_mem.c](lkm_mem.c)|Module exposing memory and swap information to /proc
3|LKM Parameters|[lkm_parameters.c](lkm_parameters.c)|Module for passing parameters from user- to kernelspace
4|LKM Proc|[lkm_proc.c](lkm_proc.c)|Module accessing /proc filesystem using sequential I/O
5|LKM Process|[lkm_process.c](lkm_process.c)|Accessing and printing current process information
6|LKM Sandbox|[lkm_sandbox.c](lkm_sandbox.c)|Sandbox module for different experiments
7|LKM Skeleton|[lkm_skeleton.c](lkm_skeleton.c)|Skeleton module for faster scaffolding of new modules

## [Building](#building) 
```
make clean && make
```

## [Testing](#testing)
To run all available tests, including basic loading/unloading and all additional concept tests..
```
make test
```

Testing by loading, unloading and outputting Kernel Ring Buffer (sudo will ask for root permissions).
```
make test-module name=<module-name>
```

Additional tests for the sandbox device including loading module, gathering major device number from /proc,
creating device and comparing the final message either run the Makefile target with ```make test-device```
or run the following commands. 

For creating character device the major number is needed and can be obtained by catting the file /proc/lkm_device_major. 
This major number is written to the Kernel Ring Buffer as well. It is possible to provide this major number using the 
module parameter param_major_num and load this module like ```sudo insmod lkm_device.ko param_major_num=241``` 
(At this moment this static allocation seems not to work reliable. The registration of the sandbox device fails sometimes. 
It was tried with a major of -16 when registration fails and the operation is not permitted like that - the reason is unknown.)
```
sudo insmod lkm_device.ko
dmesg | grep "Registered sandbox device"
sudo mknod /dev/lkm_device c $(cat /proc/lkm_device_major) 0
test -c /dev/lkm_device && cat /dev/lkm_device || echo "Device /dev/lkm_device" not found."
sudo rmmod lkm_device 
```

Additional tests for sandbox access to /proc including loading module, testing if file inside /proc exists and outputting that file. 
Either run the Makefile target *test-proc* with ```make test-proc``` or the following few commands:
```
sudo insmod lkm_proc.ko
test -f /proc/lkm_proc && cat /proc/lkm_proc || echo "File /proc/lkm_proc not found."
sudo rmmod lkm_proc
```

For additional tests for passing parameters to module lkm_parameters run the Makefile target
test-parameter with ```make test-parameters```. This will load/unload the module and compare
the parameters number and message passed when loading the module with the values read in the
/sys filesystem (/sys/module/lkm_parameters/parameters/*). Or run the following commands.
```
sudo insmod lkm_parameters.ko number=33 message=\"Some message...\"
cat /sys/module/lkm_parameters/parameters/number
cat /sys/module/lkm_parameters/parameters/message
sudo rmmod lkm_parameters
```

## [Make](#make)
![Screenshots of make](images/screenshots.gif?raw=true "Screenshots of make")

## [License](#license)
LKM Sandbox is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 of the License, or
(at your option) any later version.

LKM Sandbox is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with LKM Sandbox. If not, see [<https://www.gnu.org/licenses/>](https://www.gnu.org/licenses/). 

## [Notes](#notes)
"A Linux kernel module is a piece of compiled binary code that is inserted directly into 
the Linux kernel, running at ring 0, the lowest and least protected ring of execution in 
the x86–64 processor."

"Traditional application development paradigms can be largely discarded. Other than loading 
and unloading of your module, you’ll be writing code that responds to system events rather 
than operates in a sequential pattern."

*"With kernel development, you’re writing APIs, not applications themselves."*

## [Books](#books)
- [Linux Device Drivers](https://lwn.net/Kernel/LDD3/) by Jonathan Corbet, Alessandro Rubini, and Greg Kroah-Hartman, 3rd edition, 2009
- [Linux Kernel in a Nutshell](http://shop.oreilly.com/product/9780596100797.do) By Greg Kroah-Hartman, 1st edition, 2006

## [Links](#links)
- Developers Area, [Kernel Module Parameters](https://devarea.com/linux-kernel-development-kernel-module-parameters/) by [Liran B.H](https://devarea.com/author/liran/)
- GNU, [Licenses HowTo](https://www.gnu.org/licenses/gpl-howto.en.html)
- Kernelnewbies, [Sequential Files HowTo](https://kernelnewbies.org/Documents/SeqFileHowTo)
- Medium, [Writing simple Linux Kernel Module](https://blog.sourcerer.io/writing-a-simple-linux-kernel-module-d9dc3762c234) by [Robert W. Oliver II](https://blog.sourcerer.io/@rwoliver2)
- Pointer-Overloading, [Creating entry in proc...](http://pointer-overloading.blogspot.com/2013/09/linux-creating-entry-in-proc-file.html) by eniac
- Stackoverflow, [Is there a C function like sprintf in the Linux kernel?](https://stackoverflow.com/questions/12264291/is-there-a-c-function-like-sprintf-in-the-linux-kernel)
- Stackoverflow, [sprintf function's buffer overflow?](https://stackoverflow.com/questions/4282281/sprintf-functions-buffer-overflow)
- Superuser, [Variables in GNU Make...](https://superuser.com/questions/790560/variables-in-gnu-make-recipes-is-that-possible)
- Visual Studio Code, [Snippets](https://code.visualstudio.com/docs/editor/userdefinedsnippets)
