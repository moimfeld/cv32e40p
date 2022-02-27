# Copyright 2019 Clifford Wolf
# Copyright 2019 Robert Balas
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.

# Author: Robert Balas (balasr@iis.ee.ethz.ch)
#
# Description: Makefile for running the following examples:
#
#              - 'Hello World' (custom), command line 'make custom-vsim-run'
#              - 'Interrupt example' (interrupt), command line 'make interrupt-vsim-run'
#
#			   Floating-Point:
#					RISCV variable must be set to the path of the compiler
#					EXTENSION variable must be set to either 'f' or 'zfinx'
#					PROGRAM_PATH variable must be set or the PROGRAM variable
#						must be set to valid option. Valid programs are:
#						matmul, aha-mont64, crc32, cubic, edn, huffbench, matmult-int,
#						minver, nbody, nettle-aes, nettle-sha256, nsichneu, picojpeg,
#						qrduino, sglib-combined, slre, st, statemate, ud, wikisort
#
#					Example: 'make custom-fp-vsim-run EXTENSION=f PROGRAM=minver'
#
#					Notes:	- If the fpu_ss has not yet been cloned, 'make fpu_ss_deps'
#							  must be run.
#							- If an Embench program is chosen, the repository is
#							  cloned and the programs are built automatically.


MAKE			= make

# vsim configuration
VVERSION		= "10.7b"

VLIB			= vlib-$(VVERSION)
VWORK			= work

VLOG			= vlog-$(VVERSION)
VLOG_FLAGS		= -pedanticerrors -suppress 2577 -suppress 2583 -define CV32E40P_TRACE_EXECUTION
VLOG_LOG		= vloggy

VOPT			= vopt-$(VVERSION)
VOPT_FLAGS		= -debugdb -fsmdebug -pedanticerrors +acc #=mnprft

VSIM			= vsim-$(VVERSION)
VSIM_HOME		= /usr/pack/modelsim-$(VVERSION)-kgf/questasim
VSIM_FLAGS		=  # user defined
ALL_VSIM_FLAGS		= $(VSIM_FLAGS)
VSIM_DEBUG_FLAGS	= -debugdb
VSIM_GUI_FLAGS		= -gui -debugdb
VSIM_SCRIPT		= vsim.tcl

# RTL source files
export RTLSRC_HOME	:= $(shell pwd)/../..
export DESIGN_RTL_DIR	 = $(RTLSRC_HOME)/rtl
CV_CORE_MANIFEST	:= $(RTLSRC_HOME)/cv32e40p_manifest.flist
RTLSRC_TB_PKG		:= include/perturbation_pkg.sv
RTLSRC_TB_TOP		:= tb_top.sv
RTLSRC_TB		:= $(wildcard *.sv))

RTLSRC_CV_X_IF_TB		:=  $(wildcard *.sv) $(wildcard $(RTLSRC_HOME)/rtl/fpu_ss/src/*.sv) $(wildcard $(RTLSRC_HOME)/rtl/fpu_ss/bhv/*.sv)
RTLSRC_CV_X_IF_INCDIR		:=
RTLSRC_COMMON_CELLS_INCDIR	:= $(RTLSRC_HOME)/rtl/fpu_ss/fpnew/src/common_cells/include
RTLSRC_CV_X_IF_PKG		:= $(RTLSRC_HOME)/rtl/fpu_ss/fpnew/src/common_cells/src/cf_math_pkg.sv \
				   $(RTLSRC_HOME)/rtl/fpu_ss/fpnew/src/fpnew_pkg.sv $(wildcard $(RTLSRC_HOME)/rtl/fpu_ss/src/*pkg.sv)\
				   $(RTLSRC_HOME)/rtl/fpu_ss/fpnew/src/fpu_div_sqrt_mvp/hdl/defs_div_sqrt_mvp.sv
RTLSRC_CV_X_IF			:= $(filter-out $(RTLSRC_HOME)/rtl/fpu_ss/fpnew/src/common_cells/src/cf_math_pkg.sv\
				   $(RTLSRC_HOME)/rtl/fpu_ss/fpnew/src/common_cells/src/cb_filter.sv $(RTLSRC_HOME)/rtl/fpu_ss/fpnew/src/common_cells/src/ecc_encode.sv \
				   $(RTLSRC_HOME)/rtl/fpu_ss/fpnew/src/common_cells/src/ecc_decode.sv,\
				   $(wildcard $(RTLSRC_HOME)/rtl/fpu_ss/fpnew/src/common_cells/src/*.sv) $(RTLSRC_HOME)/rtl/fpu_ss/fpnew/src/common_cells/src/deprecated/fifo_v2.sv \
				   $(wildcard $(RTLSRC_HOME)/rtl/fpu_ss/fpnew/src/*.sv) $(wildcard $(RTLSRC_HOME)/rtl/fpu_ss/fpnew/src/fpu_div_sqrt_mvp/hdl/*.sv))

RTLSRC_VLOG_TB_TOP	:= $(basename $(notdir $(RTLSRC_TB_TOP)))
RTLSRC_VOPT_TB_TOP	:= $(addsuffix _vopt, $(RTLSRC_VLOG_TB_TOP))

# riscv toolchain install path and flags
RISCV			?= ~/.riscv
export RISCV_EXE_PREFIX	 = $(RISCV)/bin/riscv32-unknown-elf-

EXTENSION 	?= not_set
PROGRAM 	?= matmul
PROGRAM_PATH 	 =


# assume vsim if no target chosen
.DEFAULT_GOAL := custom-vsim-run

# GCC configuration
CUSTOM_GCC_FLAGS =

all: custom-vsim-run

# vsim testbench compilation and optimization
vlib: .lib-rtl

.lib-rtl:
	$(VLIB) $(VWORK)
	touch .lib-rtl

# rebuild if we change some sourcefile
.build-rtl: .lib-rtl $(CV_CORE_MANIFEST) $(RTLSRC_TB_PKG) $(RTLSRC_TB)
	$(VLOG) -work $(VWORK) $(VLOG_FLAGS) \
	-f $(CV_CORE_MANIFEST) $(RTLSRC_TB_PKG) $(RTLSRC_TB)
	touch .build-rtl

vsim-all: .opt-rtl

.opt-rtl: .build-rtl
	$(VOPT) -work $(VWORK) $(VOPT_FLAGS) $(RTLSRC_VLOG_TB_TOP) -o \
	$(RTLSRC_VOPT_TB_TOP)
	touch .opt-rtl

vsim-all-pulp: .opt-rtl-pulp

.opt-rtl-pulp: .build-rtl
	$(VOPT) -work $(VWORK) $(VOPT_FLAGS) -g PULP_XPULP=1 $(RTLSRC_VLOG_TB_TOP) -o \
	$(RTLSRC_VOPT_TB_TOP)
	touch .opt-rtl-pulp

# check if fpu_ss is already clones
check_fpu_ss_deps:
	@if [ ! -d ../../rtl/fpu_ss ]; then echo Please run \'make fpu_ss_deps\' first to clone the required fpu_ss repos; exit 1; fi

# clone fpu_ss, checkout correct commit and apply a patch
fpu_ss_deps:
	if [ ! -d ../../rtl/fpu_ss ];then git clone https://github.com/moimfeld/fpu_ss $(RTLSRC_HOME)/rtl/fpu_ss --recurse-submodules;\
	fi

# check and set environment variables
.PHONY: check_variables
check_variables:
ifndef RISCV
	$(error RISCV variable not set. (set it to the path of your compiler))
endif
ifeq ($(EXTENSION),f)
  BUILD_DEFINE := FPU_SS_TRACER
  PULP_ZFINX   := 0
  export MARCH := rv32imfc
  export MABI  := ilp32f
else ifeq ($(EXTENSION),zfinx)
  BUILD_DEFINE := PULP_ZFINX_DEF+FPU_SS_TRACER
  PULP_ZFINX   := 1
  export MARCH := rv32imczfinx
  export MABI  := ilp32
else
	$(error EXTENSION variable not valid. (set it to 'f' or 'zfinx'))
endif
ifeq ($(PROGRAM),matmul)
  PROGRAM_PATH := custom_fp/matmulNxN.c custom_fp/main.c
else ifneq (,$(filter $(PROGRAM),aha-mont64 crc32 cubic edn huffbench matmult-int minver nbody nettle-aes nettle-sha256 nsichneu picojpeg qrduino sglib-combined slre st statemate ud wikisort))
  PROGRAM_PATH := embench-iot/bd/src/$(PROGRAM)/$(PROGRAM)
else ifndef PROGRAM_PATH
	$(error PROGRAM_PATH variable not set. Either set the variable directly or choose a valid program. Valid programs are: matmul, aha-mont64, crc32, cubic, edn, huffbench, matmult-int, minver, nbody, nettle-aes, nettle-sha256, nsichneu, picojpeg, qrduino, sglib-combined, slre, st, statemate, ud, wikisort)
endif

# clone embench and build programs
.PHONY: check_embench
check_embench:
ifneq (,$(filter $(PROGRAM),aha-mont64 crc32 cubic edn huffbench matmult-int minver nbody nettle-aes nettle-sha256 nsichneu picojpeg qrduino sglib-combined slre st statemate ud wikisort))
	if [ ! -d embench-iot ]; then git clone https://github.com/embench/embench-iot;\
		cd embench-iot;\
		git checkout b2cb4ba;\
		python3 ../../scripts/embench/change_patch.py;\
		git apply ../../scripts/embench/tmp.patch;\
		./../../scripts/embench/build.sh;\
		cd -;\
		cp -v $(PROGRAM_PATH) custom_fp/fp_program.elf;\
	fi
	if [ ! -d embench-iot/bd ]; then cd embench-iot;\
		python3 ../../scripts/embench/change_patch.py;\
		git checkout config/riscv32/* src/*;\
		git checkout b2cb4ba;\
		git apply ../../scripts/embench/tmp.patch;\
		./../../scripts/embench/build.sh;\
		cd -;\
		cp -v $(PROGRAM_PATH) custom_fp/fp_program.elf;\
	fi
endif

embench_clean:
	rm embench-iot/bd -r


vsim-all-fp: check_fpu_ss_deps .opt-fp-rtl

# rebuild if we change some sourcefile
.build-fp-rtl: .lib-rtl $(RTLSRC_CV_X_IF_PKG) $(RTLSRC_CV_X_IF) $(CV_CORE_MANIFEST) $(RTLSRC_TB_PKG) $(RTLSRC_CV_X_IF_TB)
	$(VLOG) -work $(VWORK) +define+$(BUILD_DEFINE) +incdir+$(RTLSRC_CV_X_IF_INCDIR)+$(RTLSRC_COMMON_CELLS_INCDIR) $(VLOG_FLAGS) \
	 $(RTLSRC_CV_X_IF_PKG) $(RTLSRC_CV_X_IF) -f $(CV_CORE_MANIFEST) $(RTLSRC_TB_PKG) $(RTLSRC_CV_X_IF_TB)
	touch .build-fp-rtl

# rebuild cv_x_if
.opt-fp-rtl: .build-fp-rtl
	$(VOPT) -work $(VWORK) $(VOPT_FLAGS) -g FPU=1 -g PULP_ZFINX=$(PULP_ZFINX) $(RTLSRC_VLOG_TB_TOP) -o \
	$(RTLSRC_VOPT_TB_TOP)
	touch .opt-fp-rtl

# run tb and exit
.PHONY: vsim-run
vsim-run: ALL_VSIM_FLAGS += -c
vsim-run: vsim-all
	$(VSIM) -work $(VWORK) $(ALL_VSIM_FLAGS) \
	$(RTLSRC_VOPT_TB_TOP) -do 'source $(VSIM_SCRIPT); exit -f'

# run tb and drop into interactive shell
.PHONY: vsim-run-sh
vsim-run-sh: ALL_VSIM_FLAGS += -c
vsim-run-sh: vsim-all
	$(VSIM) -work $(VWORK) $(ALL_VSIM_FLAGS) \
	$(RTLSRC_VOPT_TB_TOP) -do $(VSIM_SCRIPT)

# run tb with simulator gui
.PHONY: vsim-run-gui
vsim-run-gui: ALL_VSIM_FLAGS += $(VSIM_GUI_FLAGS)
vsim-run-gui: vsim-all
	$(VSIM) -work $(VWORK) $(ALL_VSIM_FLAGS) \
	$(RTLSRC_VOPT_TB_TOP) -do $(VSIM_SCRIPT)

.PHONY: tb-clean
tb-clean:
	if [ -d $(VWORK) ]; then rm -r $(VWORK); fi
	rm -f transcript vsim.wlf vsim.dbg trace_core*.log \
	.build-rtl .build-fp-rtl .opt-rtl .opt-fp-rtl .lib-rtl *.vcd objdump

# run tb and exit
.PHONY: vsim-run-pulp
vsim-run-pulp: ALL_VSIM_FLAGS += -c
vsim-run-pulp: vsim-all-pulp
	$(VSIM) -work $(VWORK) $(ALL_VSIM_FLAGS) -GPULP_XPULP=1 \
	$(RTLSRC_VOPT_TB_TOP) -do 'source $(VSIM_SCRIPT); exit -f'


# run tb with simulator gui
.PHONY: vsim-run-gui-pulp
vsim-run-gui-pulp: ALL_VSIM_FLAGS += $(VSIM_GUI_FLAGS)
vsim-run-gui-pulp: vsim-all-pulp
	$(VSIM) -work $(VWORK) $(ALL_VSIM_FLAGS) -GPULP_XPULP=1 \
	$(RTLSRC_VOPT_TB_TOP) -do $(VSIM_SCRIPT)

# run tb
.PHONY: vsim-fp-run
vsim-fp-run: ALL_VSIM_FLAGS += -c
vsim-fp-run: vsim-all-fp
	$(VSIM) -work $(VWORK) $(ALL_VSIM_FLAGS) -GFPU=1 \
	$(RTLSRC_VOPT_TB_TOP) -do $(VSIM_SCRIPT)

# run tb with simulator gui
.PHONY: vsim-fp-run-gui
vsim-fp-run-gui: ALL_VSIM_FLAGS += $(VSIM_GUI_FLAGS)
vsim-fp-run-gui: vsim-all-fp
	$(VSIM) -work $(VWORK) $(ALL_VSIM_FLAGS) -GFPU=1 \
	$(RTLSRC_VOPT_TB_TOP) -do $(VSIM_SCRIPT)

# rules to generate hex (loadable by simulators) from elf
%.hex: %.elf
	$(RISCV_EXE_PREFIX)objcopy -O verilog $< $@

%.dis: %.elf
	$(RISCV_EXE_PREFIX)objdump -S $^ > $@

%.dump: %.elf
	$(RISCV_EXE_PREFIX)objdump -xD $^ > $@


# Running custom programs:
# This is an example for running a Hello World in the testbench
# We link with our custom crt0.s and syscalls.c against newlib so that we can
# use the c standard library
custom/hello_world.elf: custom/hello_world.c
	$(RISCV_EXE_PREFIX)gcc -march=rv32imc -o $@ -w -Os -g -nostdlib \
		$(CUSTOM_GCC_FLAGS) \
		-T custom/link.ld \
		-static \
		custom/crt0.S \
		$^ mem_stall/mem_stall.c custom/syscalls.c custom/vectors.S \
		-I $(RISCV)/riscv32-corev-elf/include \
		-I mem_stall \
		-L $(RISCV)/riscv32-corev-elf/lib \
		-lc -lm -lgcc
custom-clean:
	rm -rf custom/hello_world.elf custom/hello_world.hex custom/hello_world.dis custom/hello_world.dump

.PHONY: custom-vsim-run
custom-vsim-run: vsim-all custom/hello_world.hex
custom-vsim-run: ALL_VSIM_FLAGS += "+firmware=custom/hello_world.hex"
custom-vsim-run: vsim-run

.PHONY: custom-vsim-run-gui
custom-vsim-run-gui: vsim-all custom/hello_world.hex
custom-vsim-run-gui: ALL_VSIM_FLAGS += "+firmware=custom/hello_world.hex"
custom-vsim-run-gui: vsim-run-gui

custom_fp/fp_program.elf: $(PROGRAM_PATH)
	$(RISCV_EXE_PREFIX)gcc -march=$(MARCH) -mabi=$(MABI) -o $@ -w -g -nostdlib \
		$(CUSTOM_GCC_FLAGS) \
		-T custom/link.ld \
		-static \
		custom/crt0.S \
		$^  custom/syscalls.c custom/vectors.S \
		-I $(RISCV)/riscv32-unknown-elf/include \
		-lc -lm -lgcc

custom-fp-clean:
	rm -rf custom_fp/fp_program.elf custom_fp/fp_program.hex custom_fp/fp_program.dis custom_fp/fp_program.dump

.PHONY: custom-fp-vsim-run
custom-fp-vsim-run: check_variables check_embench vsim-all-fp custom_fp/fp_program.hex custom_fp/fp_program.dis custom_fp/fp_program.dump
custom-fp-vsim-run: ALL_VSIM_FLAGS += "+firmware=custom_fp/fp_program.hex"
custom-fp-vsim-run: vsim-fp-run

.PHONY: custom-fp-vsim-run-gui
custom-fp-vsim-run-gui: check_variables check_embench vsim-all-fp custom_fp/fp_program.hex custom_fp/fp_program.dis custom_fp/fp_program.dump
custom-fp-vsim-run-gui: ALL_VSIM_FLAGS += "+firmware=custom_fp/fp_program.hex"
custom-fp-vsim-run-gui: vsim-fp-run-gui


# compile and run interrupt
interrupt/interrupt.elf: interrupt/interrupt.c
	$(RISCV_EXE_PREFIX)gcc -march=rv32imc -o $@ -w -Os -g -nostdlib \
		${CUSTOM_GCC_FLAGS} \
		-T custom/link.ld  \
		-static \
		custom/crt0.S \
		$^ mem_stall/mem_stall.c custom/syscalls.c interrupt/vectors.S \
		-I $(RISCV)/riscv32-unknown-elf/include \
		-I mem_stall/ \
		-L $(RISCV)/riscv32-unknown-elf/lib \
		-lc -lm -lgcc
interrupt-clean:
	rm -rf interrupt/interrupt.elf interrupt/interrupt.hex

.PHONY: interrupt-vsim-run
interrupt-vsim-run: vsim-all interrupt/interrupt.hex
interrupt-vsim-run: ALL_VSIM_FLAGS += "+firmware=interrupt/interrupt.hex"
interrupt-vsim-run: vsim-run

.PHONY: interrupt-vsim-run-gui

interrupt-vsim-run-gui: vsim-all interrupt/interrupt.hex
interrupt-vsim-run-gui: ALL_VSIM_FLAGS += "+firmware=interrupt/interrupt.hex"
interrupt-vsim-run-gui: vsim-run-gui

# Compile and run HW-loops test
# Until the compiler will correctly handle HW-loops, manually insert them (no jumps/branch in the body)
# Compile with "rv32imxpulpv2" with "-mnohwloop" or "-O0" to avoid the compiler inserting other hw-loops
# Do not use RVC, as the instructions should be aligned and not compressed
hwlp_test/hwlp_test.elf: hwlp_test/hwlp_test.c
	$(RISCV_EXE_PREFIX)gcc -march=rv32imxpulpv2 -mnohwloop -o $@ -w -O0 -g -nostdlib \
		$(CUSTOM_GCC_FLAGS) \
		-T custom/link.ld \
		-static \
		custom/crt0.S \
		$^ mem_stall/mem_stall.c custom/syscalls.c custom/vectors.S \
		-I $(RISCV)/riscv32-unknown-elf/include \
		-I mem_stall \
		-L $(RISCV)/riscv32-unknown-elf/lib \
		-lc -lm -lgcc
hwlp-clean:
	rm -rf hwlp_test/hwlp_test.elf hwlp_test/hwlp_test.hex

.PHONY: hwlp-vsim-run
hwlp-vsim-run: vsim-all-pulp hwlp_test/hwlp_test.hex
hwlp-vsim-run: ALL_VSIM_FLAGS += "+firmware=hwlp_test/hwlp_test.hex"
hwlp-vsim-run: vsim-run-pulp

.PHONY: hwlp-vsim-run-gui
hwlp-vsim-run-gui: vsim-all-pulp hwlp_test/hwlp_test.hex
hwlp-vsim-run-gui: ALL_VSIM_FLAGS += "+firmware=hwlp_test/hwlp_test.hex"
hwlp-vsim-run-gui: vsim-run-gui-pulp

# general targets
.PHONY: clean
clean: tb-clean custom-clean interrupt-clean hwlp-clean custom-fp-clean embench_clean

