This repo contains a demonstration of the Fault tool chain, which is a practical open source tool chain for automatic test pattern generation (ATPG), scan insertion and scan chain testing.

We have chosen a simple counter design for the demonstration. 

The Fault tool can be run in three methods
	1. Inside a docker container getting the docker image. 
	2. Using Nix, a declarative utility tool that comes inside the OpenLane project. 
	3. Installing Fault alone and then building the required dependencies on our own. 
		Though I used the first method, for the purpose of understanding the toolchain I am listing out		the dependencies that would be required if we were doing it on our own.  
		Python - A part of the tools build uses Python
		Icarus Verilog 
		Yosys - Synthesis tool 

Exact set of commands to run. 

Getting Fault 
	
	docker pull ghcr.io/aucohl/fault:latest

Verify environment setup

	docker run -ti --rm ghcr.io/aucohl/fault:latest fault --version

Create a file counter.v in working directory

	module counter(input clk, input rst, output reg [3:0] Q);
	always @(posedge clk) begin
	if (rst)
	Q<=0;
	else
	Q <= Q + 1;
	end
	endmodule

Make sure the lib files are present. osu035_stdlib.v and osu035_stdlib.lib 

Open the terminal and run the commands in sequence:
	
	This will open the container,  drop into a bash shell, and map your current folder so  files remain 
	  docker run -it -v "$(pwd)":/work -w /work ghcr.io/aucohl/fault:latest bash

	This will do the synthesis and generate the gate-level netlist mapping to the osu035 standard cell 	library.
    read_verilog counter.v \
  	read_liberty -lib osu035_stdcells.lib \
  	synth -top counter \
  	dfflibmap -liberty osu035_stdcells.lib \
  	abc -liberty osu035_stdcells.lib  \
  	proc; opt; flatten;  \
  	opt_clean -purge \                  
  	write_verilog -noattr counter_trial.v 

	This will take the netlist and generate a scan inserted netlist named counter_scan1.v. It replaces all 	regular ff with scan ff and also initiates new outputs sout for the scan modes
    fault cut counter_scan1.v -o counter_scan_cut.v

	This command will cut the scan chain removing all feedback paths converting the circuit into a set of 	primary inputs and outputs which can be analysed for atpg testing. 
    fault cut counter_scan1.v --clock clk -o counter_scan_cut.v

	This command will run the ATPG test and generate a patterns.tv.json file which is the test vector 	inputs and a coverage.yml file which will tell the fault coverage percentage 
    fault --cellModel osu035_stdcells.v --clock clk -o patterns.tv.json --output-covered coverage.yml counter_scan_cut.v
