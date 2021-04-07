`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Moratuwa, Sri Lanka
// Author: Miyuru Thathsara
// 
// Create Date: 03/31/2021 08:26:57 AM
// Design Name: Testbench for Line Buffer
// Module Name: linebuffer_tb
// Project Name: linebuffer
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module linebuffer_tb();

//////////////////////////////////////////////////////////////////////////////////
// Parameters
//////////////////////////////////////////////////////////////////////////////////
`include "../src/params.vh"
//////////////////////////////////////////////////////////////////////////////////
// Local parameters
//////////////////////////////////////////////////////////////////////////////////
localparam DATA_OUT_SIZE                                                = KERNEL_SIZE * KERNEL_SIZE * FIXED_POINT_SIZE;
localparam NUM_OF_ACTIVATIONS                                           = IMAGE_WIDTH * IMAGE_HEIGHT;
//////////////////////////////////////////////////////////////////////////////////
// I/O Configurations
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Wires and Registers
//////////////////////////////////////////////////////////////////////////////////
reg                                                                         clk;
reg                                                                         resetn;
reg         [ FIXED_POINT_SIZE - 1 : 0 ]                                    dataIn;
reg                                                                         dataValidIn;
wire        [ DATA_OUT_SIZE - 1 : 0 ]                                       dataOut;
wire                                                                        dataValidOut;
reg signed  [ FIXED_POINT_SIZE - 1 : 0 ]                                    image[ NUM_OF_ACTIVATIONS - 1 : 0 ];
integer                                                                     i;
//////////////////////////////////////////////////////////////////////////////////
// Implementation
//////////////////////////////////////////////////////////////////////////////////

lineBuffer
#(
  .FIXED_POINT_SIZE(FIXED_POINT_SIZE),
  .FIXED_POINT_FRACTION_SIZE(FIXED_POINT_FRACTION_SIZE),
  .KERNEL_SIZE(KERNEL_SIZE),
  .IMAGE_WIDTH(IMAGE_WIDTH),
  .IMAGE_HEIGHT(IMAGE_HEIGHT)  
)
lineBuffer(
    .clk(clk),
    .resetn(resetn),
    .dataIn(dataIn),
    .dataValidIn(dataValidIn),
    .dataOut(dataOut),
    .dataValidOut(dataValidOut)
    );

always #5 clk = ~clk;

initial $readmemb("../../../../sim/Image_Binary_1.txt", image);

initial begin
    #0;
    clk                                                 = 1'b0;
    resetn                                              = 1'b0;
    dataValidIn                                         = 1'b0;
    dataIn                                              = 1'b0;
    #10;
    resetn                                              = 1'b1;
    #10;
    resetn                                              = 1'b0;
    #10;
    resetn                                              = 1'b1;

    for( i = 0; i < NUM_OF_ACTIVATIONS; i = i + 1'b1)begin
        @(posedge clk);
        dataValidIn                                     = 1'b1;
        dataIn                                          = image[i];
    end
    @(posedge clk);
    dataValidIn                                         = 1'b0;
end
endmodule
