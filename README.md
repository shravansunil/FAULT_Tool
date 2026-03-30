# FAULT Tool — Scan Insertion & ATPG with Open-Source Tool-Flows

A demonstration of the **Fault** toolchain for Automatic Test Pattern Generation (ATPG), scan insertion, and scan chain testing, using a simple counter design as the target circuit.

---

## Table of Contents

- [Overview](#overview)
- [Running Fault — Three Methods](#running-fault--three-methods)
- [Dependencies (Manual Install)](#dependencies-manual-install)
- [Step-by-Step Walkthrough](#step-by-step-walkthrough)
  - [1. Pull the Docker Image](#1-pull-the-docker-image)
  - [2. Verify Environment](#2-verify-environment)
  - [3. Create the Design File](#3-create-the-design-file)
  - [4. Prepare Library Files](#4-prepare-library-files)
  - [5. Launch the Container](#5-launch-the-container)
  - [6. Synthesize the Design](#6-synthesize-the-design)
  - [7. Scan Insertion](#7-scan-insertion)
  - [8. Cut the Scan Chain](#8-cut-the-scan-chain)
  - [9. Run ATPG](#9-run-atpg)
- [Output Files Explained](#output-files-explained)

---

## Overview

This repo demonstrates the **Fault** open-source toolchain, which covers:

- Gate-level **synthesis** using Yosys
- **Scan insertion** — replacing regular flip-flops with scan flip-flops
- **Scan chain cutting** — converting feedback paths into primary I/O for analysis
- **ATPG** — generating test vectors and measuring fault coverage

The design under test is a simple 4-bit counter.

---

## Running Fault — Three Methods

| Method | Description |
|--------|-------------|
| **Docker** *(used here)* | Pull and run the pre-built container image — simplest setup |
| **Nix** | Use the declarative Nix utility bundled inside the OpenLane project |
| **Manual Install** | Install Fault and build all dependencies yourself |

---

## Dependencies (Manual Install)

> Only relevant if you are **not** using Docker or Nix.

- **Python** — used in parts of the tool's build process
- **Icarus Verilog** — open-source Verilog simulation and compilation
- **Yosys** — open-source RTL synthesis suite

---

## Step-by-Step Walkthrough

### 1. Pull the Docker Image

```bash
docker pull ghcr.io/aucohl/fault:latest
```

---

### 2. Verify Environment

```bash
docker run -ti --rm ghcr.io/aucohl/fault:latest fault --version
```

---

### 3. Create the Design File

Create `counter.v` in your working directory:

```verilog
module counter(input clk, input rst, output reg [3:0] Q);
  always @(posedge clk) begin
    if (rst)
      Q <= 0;
    else
      Q <= Q + 1;
  end
endmodule
```

---

### 4. Prepare Library Files

Ensure the following standard cell library files are present in your working directory:

- `osu035_stdcells.v`
- `osu035_stdcells.lib`

---

### 5. Launch the Container

This opens an interactive shell inside the container and maps your current folder so all files persist on your host machine:

```bash
docker run -it -v "$(pwd)":/work -w /work ghcr.io/aucohl/fault:latest bash
```

---

### 6. Synthesize the Design

Run the following Yosys commands to synthesize `counter.v` and produce a gate-level netlist mapped to the OSU035 standard cell library:

```tcl
read_verilog counter.v
read_liberty -lib osu035_stdcells.lib
synth -top counter
dfflibmap -liberty osu035_stdcells.lib
abc -liberty osu035_stdcells.lib
proc; opt; flatten;
opt_clean -purge
write_verilog -noattr counter_trial.v
```

> **Output:** `counter_trial.v` — the synthesized gate-level netlist.

---

### 7. Scan Insertion

Replace all regular flip-flops with scan flip-flops and introduce a new `sout` port for scan mode:

```bash
fault scan counter_trial.v -o counter_scan1.v
```

> **Output:** `counter_scan1.v` — the scan-inserted netlist.

---

### 8. Cut the Scan Chain

Remove all feedback paths, converting the circuit into a set of primary inputs and outputs that can be analysed during ATPG:

```bash
fault cut counter_scan1.v --clock clk -o counter_scan_cut.v
```

> **Output:** `counter_scan_cut.v` — the scan-cut netlist, ready for ATPG.

---

### 9. Run ATPG

Generate test vectors and measure fault coverage:

```bash
fault \
  --cellModel osu035_stdcells.v \
  --clock clk \
  -o patterns.tv.json \
  --output-covered coverage.yml \
  counter_scan_cut.v
```

> **Outputs:** `patterns.tv.json` and `coverage.yml`

---

## Output Files Explained

### `coverage.yml`

Lists every netlist node where **Stuck-At-0 (sa0)** and **Stuck-At-1 (sa1)** faults were successfully detected, along with the overall fault coverage percentage.

> Fault coverage achieved in this run: **88.88%**

---

### `patterns.tv.json`

A machine-readable file containing the complete set of test vectors — stimulus inputs and their corresponding expected ("golden") outputs — used for scan-based testing.

---

### `parser.out`

Lists the formal grammar rules used by the tool to parse the Verilog netlist. Useful for debugging netlist compatibility issues.

---

## Flow Summary

```
counter.v
    │
    ▼  Yosys synthesis
counter_trial.v  (gate-level netlist)
    │
    ▼  fault scan
counter_scan1.v  (scan flip-flops inserted)
    │
    ▼  fault cut
counter_scan_cut.v  (feedback paths removed)
    │
    ▼  fault ATPG
patterns.tv.json + coverage.yml
```
