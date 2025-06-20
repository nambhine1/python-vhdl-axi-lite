
# python-vhdl-axi-lite

**Auto-generate AXI Lite VHDL slave interfaces with customizable register count. Includes OSVVM testbench and Tcl-based regression using GHDL (LLVM backend).**

---

##  Overview

This project simplifies the development of AXI Lite slave peripherals by generating VHDL code automatically based on the number of registers you specify. It also includes an OSVVM-based testbench and a Tcl regression script for functional verification using **GHDL with the LLVM backend**.

---

##  Features

- Auto-generate AXI Lite slave VHDL code for any number of registers
- Modular VHDL source code (`*.vhd`)
- OSVVM testbench for validating AXI behavior
- Regression simulation with **GHDL (LLVM backend)** via Tcl

---

##  Project Structure

```
python-vhdl-axi-lite/
│
├── script/
│   ├── generate_axi_slave.py        # Python script for VHDL code generation
│   └── regression_axi4_python.tcl   # Tcl script for GHDL regression test
│
├── src/
│   └── *.vhd                         # Generated and supporting VHDL source files
│
├── tb/
│   └── *.vhd                         # Testbench files using OSVVM
│
├── README.md
└── .gitignore
```

---

##  Quick Start

### 1. Generate AXI Lite VHDL

```bash
cd script
python generate_axi_slave.py
```

You will be prompted to enter:

- ✅ The number of AXI Lite registers

The script automatically generates VHDL files and saves them to the `src/` directory.

---

### 2. Run Simulation (OSVVM + GHDL)

Run the regression test using the Tcl shell:

```bash
cd script
tclsh regression_axi4_python.tcl
```

This command will:

- Compile all VHDL files (`src/*.vhd` and `tb/*.vhd`) with GHDL (LLVM backend)
- Run OSVVM test sequences
- Display pass/fail results

> ✅ Ensure GHDL is installed and compiled with the LLVM backend.  
> Run `ghdl --version` to verify.

---

##  Requirements

- Python 3.6 or higher
- GHDL compiled with LLVM backend
- Tcl shell
- OSVVM (OSVVM packages should be accessible during simulation)

---

##  Contributing

Issues, feature requests, and pull requests are welcome!  
Please [open an issue](https://github.com/nambhine1/python-vhdl-axi-lite/issues) to report bugs or suggest improvements.

---
