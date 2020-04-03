#
# LKM Sandbox::Makefile
# <https://github.com/tpiekarski/lkm-sandbox>
# ---
# Copyright 2020 Thomas Piekarski <t.piekarski@deloquencia.de>
#
# This file is part of LKM Sandbox.
# 
# LKM Sandbox is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# LKM Sandbox is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with LKM Sandbox. If not, see <https://www.gnu.org/licenses/>.
# 
#

SHELL:=/bin/bash

ccflags-y := -Wall

obj-m += lkm_device.o lkm_mem.o lkm_parameters.o lkm_proc.o lkm_sandbox.o lkm_skeleton.o

all:
	$(MAKE) -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

clean:
	$(MAKE) -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean

test:
	$(info Running all available tests)
	@$(MAKE) test-module name=lkm_device
	@$(MAKE) test-module name=lkm_mem
	@$(MAKE) test-module name=lkm_parameters
	@$(MAKE) test-module name=lkm_proc
	@$(MAKE) test-module name=lkm_sandbox
	@$(MAKE) test-module name=lkm_skeleton
	@$(MAKE) test-device
	@$(MAKE) test-memory
	@$(MAKE) test-parameters
	@$(MAKE) test-proc
	@echo "All test targets have run successfully."

#
# Generic targets for load/dmesg/unload module tests
#

test-module:
	$(info >> Testing module '$(name)' by loading and displaying Kernel Message Ring Buffer...)
	$(info >> Root permissions are needed for clearing buffer with dmesg and loading/unloading with insmod/rmmod)
	
	@test ${name} || (echo "!! Please provide a valid module name to test, like 'make test name=lkm_sandbox'."; exit 1)
	$(eval filename = ${name}.ko)
	@test -f ${filename} || (echo "!! The module ${filename} could not be found. Did you forgot to run make?"; exit 2)
	
	@sudo dmesg --clear
	@sudo insmod ${filename}
	@sudo rmmod ${filename}
	@dmesg

#
# Targets for additional concept-based module tests
#

test-device:
	$(info >> Additional testing module 'lkm_device' by loading, accessing major device number in /proc and creating device)
	$(info >> Root permissions are needed for loading/unloading module with insmod/rmmod and creating device with mknod)

	$(eval module_filename = lkm_device.ko)
	$(eval proc_filename = /proc/lkm_device_major)
	$(eval device_filename = /dev/lkm_device)
	$(eval message = Hello, Linux!)

	@test -f $(module_filename) || (echo "!! The module $(filename) could not be found. Did you forgot to run make?"; exit 2)
	@sudo insmod $(module_filename)
	@test -f ${proc_filename} \
		|| (echo "!! The /proc file containing devices major number could not be found."; exit 3) \
		&& echo ">> Found /proc file for accessing devices major number"
	@sudo mknod $(device_filename) c `cat $(proc_filename)` 0
	@test -c $(device_filename) \
		|| (echo "!! Failed creating device file $(device_filename)."; exit 4) \
		&& echo ">> Successfully created device $(device_filename)."
	@test "\"`head -n 1 $(device_filename)`\"" = "\"$(message)\"" \
		|| (echo "!! The message is not equal to $(message)."; exit 5) \
		&& (echo ">> The message is equal to what was expected.")
	@sudo rm $(device_filename)
	@sudo rmmod $(module_filename)

test-memory:
	$(info >> Testing module 'lkm_mem' by loading and accessing exposed memory and swap information in /proc)
	$(info >> Root permissions are needed for clearing buffer with dmesg and loading/unloading with insmod/rmmod)

	$(eval module_filename = lkm_mem.ko)
	$(eval mem_proc_buffer_file = /proc/lkm/mem/buffer)
	$(eval mem_proc_free_file = /proc/lkm/mem/free)
	$(eval mem_proc_shared_file = /proc/lkm/mem/shared)
	$(eval mem_proc_total_file = /proc/lkm/mem/total)
	$(eval swap_proc_free_file = /proc/lkm/swap/free)
	$(eval swap_proc_total_file = /proc/lkm/swap/total)
	

	@test -f $(module_filename) || (echo "!! The module $(filename) could not be found. Did you forgot to run make?"; exit 1)
	@sudo insmod $(module_filename)

	@test -f $(mem_proc_buffer_file) \
		|| (echo "!! The /proc file $(mem_proc_buffer_file) could not be found."; exit 2) \
		&& echo ">> Found /proc file $(mem_proc_buffer_file)."
	@test `cat $(mem_proc_buffer_file)` -gt 0 \
		|| (echo "!! The free memory read from $(mem_proc_buffer_file) is `cat $(mem_proc_buffer_file)` and less than 0, something can not be right."; exit 3) \
		&& echo ">> The free memory read from $(mem_proc_buffer_file) is `cat $(mem_proc_buffer_file)` and looks okay."
	
	@test -f $(mem_proc_free_file) \
		|| (echo "!! The /proc file $(mem_proc_free_file) could not be found."; exit 2) \
		&& echo ">> Found /proc file $(mem_proc_free_file)."
	@test `cat $(mem_proc_free_file)` -gt 0 \
		|| (echo "!! The free memory read from $(mem_proc_free_file) is `cat $(mem_proc_free_file)` and less than 0, something can not be right."; exit 3) \
		&& echo ">> The free memory read from $(mem_proc_free_file) is `cat $(mem_proc_free_file)` and looks okay."

	@test -f $(mem_proc_shared_file) \
		|| (echo "!! The /proc file $(mem_proc_shared_file) could not be found."; exit 2) \
		&& echo ">> Found /proc file $(mem_proc_shared_file)."
	@test `cat $(mem_proc_shared_file)` -gt 0 \
		|| (echo "!! The free memory read from $(mem_proc_shared_file) is `cat $(mem_proc_shared_file)` and less than 0, something can not be right."; exit 3) \
		&& echo ">> The free memory read from $(mem_proc_shared_file) is `cat $(mem_proc_shared_file)` and looks okay."

	@test -f $(mem_proc_total_file) \
		|| (echo "!! The /proc file $(mem_proc_total_file) could not be found."; exit 2) \
		&& echo ">> Found /proc file $(mem_proc_total_file)."
	@test `cat $(mem_proc_total_file)` -gt 0 \
		|| (echo "!! The total memory read from $(mem_proc_total_file) is `cat $(mem_proc_total_file)` and less than 0, something can not be right."; exit 3) \
		&& echo ">> The total memory read from $(mem_proc_total_file) is `cat $(mem_proc_total_file)` and looks okay."

	@test -f $(swap_proc_free_file) \
		|| (echo "!! The /proc file $(swap_proc_free_file) could not be found."; exit 2) \
		&& echo ">> Found /proc file $(swap_proc_free_file)."

	@test -f $(swap_proc_total_file) \
		|| (echo "!! The /proc file $(swap_proc_total_file) could not be found."; exit 2) \
		&& echo ">> Found /proc file $(swap_proc_total_file)."

	@sudo rmmod $(module_filename)

test-parameters:
	$(eval module = lkm_parameters)
	$(eval number = 22)
	$(eval message = I am a Makefile)

	$(info >> Additional testing module 'lkm_parameters' by loading and checking parameters in /sys filesystem)
	$(info >> Root permissions are needed for clearing buffer with dmesg and loading/unloading with insmod/rmmod)

	$(eval filename = ${module}.ko)
	@test -f ${filename} || (echo "!! The module ${filename} could not be found. Did you forgot to run make?"; exit 2)
	@sudo insmod $(filename) number=$(number) message=\"$(message)\"
	@test "`cat /sys/module/$(module)/parameters/number`" -eq $(number) \
		|| (echo "!! The parameter 'number' is unequal $(number)."; exit 3) \
		&& echo "Passed parameter 'number' is equal to $(number)."
	@test "\"`cat /sys/module/$(module)/parameters/message`\"" = "\"$(message)\"" \
		|| (echo "!! The parameter 'message' is unequal $(message)."; exit 3) \
		&& echo "Passed parameter 'message' is equal to $(message)."
	@sudo rmmod $(filename)

test-proc:
	$(eval proc_module = lkm_proc)
	$(eval proc_file = /proc/$(proc_module))

	$(info >> Additional testing module 'lkm_proc' to access /proc filesystem by loading and cating '$(proc_file)'...)
	$(info >> Root permissions are needed for loading/unloading with insmod/rmmod)
	
	$(eval filename = ${proc_module}.ko)
	@test -f ${filename} || (echo "!! The module ${filename} could not be found. Did you forgot to run make?"; exit 2)
	
	@sudo insmod ${filename}
	@test -f $(proc_file) && echo ">> The file $(proc_file) exists." || (echo "!! The file $(proc_file) does not exists."; exit 3)
	@cat $(proc_file)
	@sudo rmmod ${filename}

#
# Miscellaneous targets
# 

license:
	@echo -e " LKM Sandbox::Make\n\n \
	LKM Sandbox is free software: you can redistribute it and/or modify\n \
	it under the terms of the GNU General Public License as published by\n \
	the Free Software Foundation, either version 3 of the License, or\n \
	(at your option) any later version.\n\n \
	LKM Sandbox is distributed in the hope that it will be useful,\n \
	but WITHOUT ANY WARRANTY; without even the implied warranty of\n \
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n \
	GNU General Public License for more details.\n\n \
	You should have received a copy of the GNU General Public License\n \
	along with LKM Sandbox.  If not, see <https://www.gnu.org/licenses/>.\n"
