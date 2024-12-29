# Makefile

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# Specify Verilog source files
VERILOG_SOURCES += ../rtl/NN.sv

# Specify include directories
VERILOG_INCLUDE_DIRS += ../rtl

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = NN

# MODULE is the basename of the Python test file
MODULE = NN_cocotb

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

