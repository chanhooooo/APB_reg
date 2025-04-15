`include "apb_reg.v"
`timescale 1ns/1ps

module apb_regs_tb;

  parameter DW = 32;
  parameter AW = 5;

  reg                  pclk;
  reg                  presetn;
  reg  [AW-1:0]        paddr;
  reg                  psel;
  reg                  penable;
  reg                  pwrite;
  reg  [DW-1:0]        pwdata;
  wire [DW-1:0]        prdata;
  wire                 pready;
  wire                 pslverr;

  apb_regs #(.DW(DW), .AW(AW)) dut (
    .pclk     (pclk),
    .presetn  (presetn),
    .paddr    (paddr),
    .psel     (psel),
    .penable  (penable),
    .pwrite   (pwrite),
    .pready   (pready),
    .pwdata   (pwdata),
    .prdata   (prdata),
    .pslverr  (pslverr)
  );

  // 클럭 생성 (50MHz)
  initial pclk = 0;
  always #10 pclk = ~pclk;

  reg [DW-1:0] rdata;

  // APB 쓰기 task
  task apb_write;
    input [AW-1:0] addr;
    input [DW-1:0] data;
    begin
      @(posedge pclk);
      paddr   = addr;
      pwdata  = data;
      pwrite  = 1;
      psel    = 1;
      penable = 0;
      @(posedge pclk);
      penable = 1;
      @(posedge pclk);
      wait (pready);
      @(posedge pclk);
      psel    = 0;
      penable = 0;
      pwrite  = 0;
    end
  endtask

  // APB 읽기 task
  task apb_read;
    input [AW-1:0] addr;
    begin
      @(posedge pclk);
      paddr   = addr;
      pwrite  = 0;
      psel    = 1;
      penable = 0;
      @(posedge pclk);
      penable = 1;
      @(posedge pclk);
      wait (pready);
      @(posedge pclk);
      rdata = prdata;
      psel  = 0;
      penable = 0;
    end
  endtask

  // 테스트 시나리오
  initial begin
    // 초기화
    paddr   = 0;
    psel    = 0;
    penable = 0;
    pwrite  = 0;
    pwdata  = 0;
    presetn = 0;

    // 파형 출력
    $dumpfile("apb_regs_tb.vcd");
    $dumpvars(0, apb_regs_tb);

    // 리셋
    repeat (2) @(posedge pclk);
    presetn = 1;

    $display("==== APB 테스트 시작 ====");

    // 쓰기
    apb_write(5'h00, 32'hAAAA_1111);
    apb_write(5'h04, 32'hBBBB_2222);
    apb_write(5'h08, 32'hCCCC_3333);
    apb_write(5'h0C, 32'hDDDD_4444);

    #20;

    // 읽기 및 출력
    apb_read(5'h00); $display("Read @0x00 = %h", rdata);
    apb_read(5'h04); $display("Read @0x04 = %h", rdata);
    apb_read(5'h08); $display("Read @0x08 = %h", rdata);
    apb_read(5'h0C); $display("Read @0x0C = %h", rdata);

    #20;
    $display("==== APB 테스트 완료 ====");
    $finish;
  end

endmodule
