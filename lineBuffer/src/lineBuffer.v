`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Moratuwa, Sri Lanka
// Author: Miyuru Thathsara
// 
// Create Date: 03/11/2021 04:56:05 PM
// Design Name: Line Buffer
// Module Name: lineBuffer
// Project Name: Line Buffer
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module lineBuffer(
    clk,
    resetn,
    dataIn,
    dataValidIn,
    dataOut,
    dataValidOut
    );
    `include "params.vh"
/////////////////////////////////////////////////////////////////////////////////
// Local Parameters
/////////////////////////////////////////////////////////////////////////////////
localparam DATA_OUT_SIZE                                                = KERNEL_SIZE * KERNEL_SIZE * FIXED_POINT_SIZE;
localparam LINE_BUFFER_WIDTH                                            = IMAGE_WIDTH * FIXED_POINT_SIZE;
localparam LINE_BUFFER_LAST_DATA_BEGIN                                  = LINE_BUFFER_WIDTH - FIXED_POINT_SIZE;
localparam NUM_OF_DATA_POINTS                                           = IMAGE_WIDTH * IMAGE_HEIGHT * FIXED_POINT_SIZE;
localparam COLUMN_COUNTER_WIDTH                                         = count2width(IMAGE_WIDTH) + 1'b1;
localparam ROW_COUNTER_WIDTH                                            = count2width(IMAGE_HEIGHT) + 1'b1;
localparam IMAGE_SIZE                                                   = IMAGE_HEIGHT * IMAGE_WIDTH;
localparam KERNEL_ROW_SIZE                                              = KERNEL_SIZE * FIXED_POINT_SIZE;
/////////////////////////////////////////////////////////////////////////////////
// I/O Configuration
/////////////////////////////////////////////////////////////////////////////////
input                                                                   clk;
input                                                                   resetn;
input           [ FIXED_POINT_SIZE - 1 : 0 ]                            dataIn;
input                                                                   dataValidIn;
output reg      [ DATA_OUT_SIZE - 1 : 0 ]                               dataOut;
output reg                                                              dataValidOut;  
/////////////////////////////////////////////////////////////////////////////////
// Wires and Registers
/////////////////////////////////////////////////////////////////////////////////
reg                                                                     reset_a;
reg                                                                     reset_b;
reg             [ LINE_BUFFER_WIDTH - 1 : 0 ]                           line_buffer     [ KERNEL_SIZE - 1 : 0 ];
reg             [ COLUMN_COUNTER_WIDTH - 1 : 0 ]                        column_counter;
reg             [ ROW_COUNTER_WIDTH - 1 : 0 ]                           row_counter;
reg             [ IMAGE_SIZE - 1 : 0 ]                                  pixel_counter;
reg                                                                     pixel_finish_flag;
reg                                                                     data_out_flag_1;
reg                                                                     data_out_flag_2;
wire                                                                    reset_wire;
integer                                                                 i1;
integer                                                                 i2;
integer                                                                 i3;
/////////////////////////////////////////////////////////////////////////////////
// Implementation
/////////////////////////////////////////////////////////////////////////////////

assign reset_wire                                                               = resetn & reset_b;

always@(posedge clk)begin
    reset_a                                                                     <= resetn;
    reset_b                                                                     <= reset_a;
end

always@(posedge clk or negedge reset_wire)begin
    if(~reset_wire)begin
        column_counter                                                          <= { COLUMN_COUNTER_WIDTH { 1'b0 } };
        row_counter                                                             <= { ROW_COUNTER_WIDTH { 1'b0 } };
        pixel_counter                                                           <= { IMAGE_SIZE { 1'b0 } };
        pixel_finish_flag                                                       <= 1'b0;
    end
    else begin
        if( pixel_finish_flag == 1'b1 )begin
            if( column_counter < IMAGE_WIDTH - KERNEL_SIZE )begin
                for( i1 = 0; i1 < KERNEL_SIZE; i1 = i1 + 1'b1 )begin
                    line_buffer[ i1 ]                                           <= line_buffer[ i1 ] << FIXED_POINT_SIZE;
                    if(i1 != 0)begin
                        line_buffer[ i1 ][ FIXED_POINT_SIZE - 1 : 0 ]           <= line_buffer[ i1 - 1 ][ LINE_BUFFER_WIDTH - 1 : LINE_BUFFER_LAST_DATA_BEGIN ];
                    end
                end
                column_counter                                                  <= column_counter + 1'b1;
            end
            else begin
                pixel_finish_flag                                               <= 1'b0;
                row_counter                                                     <= { ROW_COUNTER_WIDTH { 1'b0 } };
                column_counter                                                  <= { COLUMN_COUNTER_WIDTH { 1'b0 } };
            end
        end
        else begin
            if(dataValidIn)begin
                for( i2 = 0; i2 < KERNEL_SIZE; i2 = i2 + 1'b1 )begin
                    line_buffer[ i2 ]                                           <= line_buffer[ i2 ] << FIXED_POINT_SIZE;
                    if(i2 != 0)begin
                        line_buffer[ i2 ][ FIXED_POINT_SIZE - 1 : 0 ]           <= line_buffer[ i2 - 1 ][ LINE_BUFFER_WIDTH - 1 : LINE_BUFFER_LAST_DATA_BEGIN ];
                    end
                    else begin
                        line_buffer[ i2 ][ FIXED_POINT_SIZE - 1 : 0 ]           <= dataIn;
                    end
                end
                if( column_counter < IMAGE_WIDTH - 1'b1 )begin
                    column_counter                                              <= column_counter + 1'b1;
                end
                else begin
                    column_counter                                              <= { COLUMN_COUNTER_WIDTH { 1'b0 } };
                    if( row_counter < IMAGE_HEIGHT - 1'b1 )begin
                        row_counter                                             <= row_counter + 1'b1;
                    end
                    else begin
                        row_counter                                             <= { ROW_COUNTER_WIDTH { 1'b0 } };
                    end
                end
            end
            else begin
                if( column_counter >= IMAGE_WIDTH - 1'b1 )begin
                    if( row_counter >= IMAGE_HEIGHT - 1'b1 )begin
                        pixel_finish_flag                                       <= 1'b1;
                        column_counter                                          <= { COLUMN_COUNTER_WIDTH { 1'b0 } };
                    end
                    else begin
                        pixel_finish_flag                                       <= 1'b0;
                    end
                end
                else begin
                    pixel_finish_flag                                           <= 1'b0;
                end
            end
        end
    end
end

always@(posedge clk or negedge reset_wire)begin
    if(~reset_wire)begin
        data_out_flag_1                                                         <= 1'b0;
    end
    else begin
        if( row_counter >= KERNEL_SIZE )begin
            data_out_flag_1                                                     <= 1'b1;
        end
        else begin
            data_out_flag_1                                                     <= 1'b0;
        end
    end
end 

always@(posedge clk or negedge reset_wire)begin
    if(~reset_wire)begin
        data_out_flag_2                                                         <= 1'b0;        
    end
    else begin
        if( column_counter < IMAGE_WIDTH - KERNEL_SIZE + 1'b1 )begin
            data_out_flag_2                                                     <= 1'b1;
        end
        else begin
            data_out_flag_2                                                     <= 1'b0;
        end
    end
end

always@(posedge clk or negedge reset_wire)begin
    if(~reset_wire)begin
        dataOut                                                                 <= { DATA_OUT_SIZE {1'b0} };
        dataValidOut                                                            <= 1'b0;
    end
    else begin
        if( data_out_flag_1 & data_out_flag_2 )begin
            dataValidOut                                                        <= 1'b1;
            for( i3 = 0; i3 < KERNEL_SIZE; i3 = i3 + 1'b1 )begin
                dataOut[ i3 * KERNEL_ROW_SIZE +: KERNEL_ROW_SIZE ]              <= line_buffer[ i3 ][ KERNEL_ROW_SIZE - 1 : 0 ];
            end
        end
        else begin
            dataValidOut                                                        <= 1'b0;
            dataOut                                                             <= { DATA_OUT_SIZE { 1'b0 } };
        end
    end
end
endmodule
