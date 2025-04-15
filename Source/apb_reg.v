`timescale 1ns/1ps

module apb_regs #(
    parameter DW = 32,
    parameter AW = 5
)(
    input                  pclk,
    input                  presetn,
    
    input      [AW-1:0]    paddr,
    input                  psel,
    input                  penable,
    input                  pwrite,
    output                 pready,
    input      [DW-1:0]    pwdata,
    output reg    [DW-1:0]    prdata,
    output                 pslverr



    //user ports
);

    reg [DW-1:0] slv_reg0;
    reg [DW-1:0] slv_reg1;
    reg [DW-1:0] slv_reg2;
    reg [DW-1:0] slv_reg3;

    wire apb_write = psel & penable & pwrite;
    wire apb_read  = psel & ~pwrite;

    assign pready = 1'b1; 
    assign pslverr = 1'b0;

    always @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            slv_reg0 <= 32'b0;
            slv_reg1 <= 32'b0;
            slv_reg2 <= 32'b0;
            slv_reg3 <= 32'b0;
        end else if (apb_write) begin
            case (paddr)
                5'h00: slv_reg0 <= pwdata;
                5'h04: slv_reg1 <= pwdata;
                5'h08: slv_reg2 <= pwdata;
                5'h0C: slv_reg3 <= pwdata;
                default: begin
						  slv_reg0 <= slv_reg0;
	                      slv_reg1 <= slv_reg1;
	                      slv_reg2 <= slv_reg2;
	                      slv_reg3 <= slv_reg3;
				end
            endcase
        end
    end

    // Register read logic
always @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
        prdata <= {DW{1'b0}};
    end else if (apb_read) begin
        case (paddr)
            5'h00: prdata <= slv_reg0;
            5'h04: prdata <= slv_reg1;
            5'h08: prdata <= slv_reg2;
            5'h0C: prdata <= slv_reg3;
            default: prdata <= {DW{1'b0}};
        endcase
    end
end

endmodule