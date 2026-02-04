

module BoundaryScanRegister_input
(
  din,
  dout,
  sin,
  sout,
  clock,
  reset,
  testing,
  shift
);

  input din;
  output dout;
  input sin;
  output sout;
  input clock;input reset;input testing;input shift;
  reg store;

  always @(posedge clock or posedge reset) begin
    if(reset) begin
      store <= 1'b0;
    end else begin
      store <= (shift)? sin : dout;
    end
  end

  assign sout = store;
  assign dout = (testing)? store : din;

endmodule



module BoundaryScanRegister_output
(
  din,
  dout,
  sin,
  sout,
  clock,
  reset,
  testing,
  shift
);

  input din;
  output dout;
  input sin;
  output sout;
  input clock;input reset;input testing;input shift;
  reg store;

  always @(posedge clock or posedge reset) begin
    if(reset) begin
      store <= 1'b0;
    end else begin
      store <= (shift)? sin : dout;
    end
  end

  assign sout = store;
  assign dout = din;

endmodule



module \counter.original 
(
  clk,
  rst,
  Q,
  sin,
  shift,
  sout,
  tck,
  test
);

  input sin;
  output sout;
  input shift;
  input tck;
  input test;
  wire __clk_source__;
  wire __chain_0__;
  assign __chain_0__ = sin;
  wire _00_;
  wire _01_;
  (* force_downto = 32'd1 *)
  (* src = "counter.v:6.6-6.11|/build/bin/../share/yosys/techmap.v:270.23-270.24" *)
  wire [3:0] _02_;
  (* force_downto = 32'd1 *)
  (* src = "counter.v:6.6-6.11|/build/bin/../share/yosys/techmap.v:270.26-270.27" *)
  wire [3:0] _03_;
  wire _04_;
  wire _05_;
  wire _06_;
  wire _07_;
  (* src = "counter.v:1.55-1.56" *)
  output [3:0] Q;
  (* src = "counter.v:1.22-1.25" *)
  input clk;
  (* src = "counter.v:1.33-1.36" *)
  input rst;
  assign _02_[0] = ~Q[0];
  assign _03_[1] = Q[1] ^ Q[0];
  assign _00_ = ~(Q[1] & Q[0]);
  assign _03_[2] = ~(_00_ ^ Q[2]);
  assign _01_ = Q[2] & ~_00_;
  assign _03_[3] = _01_ ^ Q[3];
  (* src = "counter.v:2.1-7.4" *)

  DFFPOSX1
  _14_
  (
    .CLK(__clk_source__),
    .D((shift)? __chain_0__ : _04_),
    .Q(Q[0])
  );

  (* src = "counter.v:2.1-7.4" *)

  DFFPOSX1
  _15_
  (
    .CLK(__clk_source__),
    .D((shift)? Q[0] : _05_),
    .Q(Q[1])
  );

  (* src = "counter.v:2.1-7.4" *)

  DFFPOSX1
  _16_
  (
    .CLK(__clk_source__),
    .D((shift)? Q[1] : _06_),
    .Q(Q[2])
  );

  (* src = "counter.v:2.1-7.4" *)

  DFFPOSX1
  _17_
  (
    .CLK(__clk_source__),
    .D((shift)? Q[2] : _07_),
    .Q(Q[3])
  );

  assign _04_ = (rst)? 1'h0 : _02_[0];
  assign _05_ = (rst)? 1'h0 : _03_[1];
  assign _06_ = (rst)? 1'h0 : _03_[2];
  assign _07_ = (rst)? 1'h0 : _03_[3];
  assign _02_[3:1] = Q[3:1];
  assign _03_[0] = _02_[0];
  assign sout = Q[3];
  assign __clk_source__ = (test)? tck : clk;

endmodule



module counter
(
  clk,
  rst,
  Q,
  sin,
  shift,
  sout,
  tck,
  test
);

  input sin;
  output sout;
  input rst;
  input shift;
  input tck;
  input test;
  input clk;
  wire __chain_0__;
  assign __chain_0__ = sin;
  wire __chain_1__;
  output [3:0] Q;
  wire [3:0] Q_din;
  wire __chain_2__;

  BoundaryScanRegister_output
  __BoundaryScanRegister_output__0__
  (
    .din(Q_din[0]),
    .dout(Q[0]),
    .sin(__chain_1__),
    .sout(__chain_2__),
    .clock(tck),
    .reset(rst),
    .testing(test),
    .shift(shift)
  );

  wire __chain_3__;

  BoundaryScanRegister_output
  __BoundaryScanRegister_output__1__
  (
    .din(Q_din[1]),
    .dout(Q[1]),
    .sin(__chain_2__),
    .sout(__chain_3__),
    .clock(tck),
    .reset(rst),
    .testing(test),
    .shift(shift)
  );

  wire __chain_4__;

  BoundaryScanRegister_output
  __BoundaryScanRegister_output__2__
  (
    .din(Q_din[2]),
    .dout(Q[2]),
    .sin(__chain_3__),
    .sout(__chain_4__),
    .clock(tck),
    .reset(rst),
    .testing(test),
    .shift(shift)
  );

  wire __chain_5__;

  BoundaryScanRegister_output
  __BoundaryScanRegister_output__3__
  (
    .din(Q_din[3]),
    .dout(Q[3]),
    .sin(__chain_4__),
    .sout(__chain_5__),
    .clock(tck),
    .reset(rst),
    .testing(test),
    .shift(shift)
  );


  \counter.original 
  __uuf__
  (
    .clk(clk),
    .rst(rst),
    .shift(shift),
    .tck(tck),
    .test(test),
    .sin(__chain_0__),
    .sout(__chain_1__),
    .Q(Q_din)
  );

  assign sout = __chain_5__;

endmodule


