module counter(input clk, input rst, output reg [3:0] Q);
always @(posedge clk) begin
if (rst)
Q<=0;
else
Q <= Q + 1;
end
endmodule
