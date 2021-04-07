/////////////////////////////////////////////////////////////////////////////////////
// Parameters 
/////////////////////////////////////////////////////////////////////////////////////
parameter FIXED_POINT_SIZE                                              = 16;
parameter DATA_WIDTH                                                    = 8;
parameter FIXED_POINT_FRACTION_SIZE                                     = 8;
parameter KERNEL_SIZE                                                   = 5;
parameter IMAGE_WIDTH                                                   = 32;
parameter IMAGE_HEIGHT                                                  = 32;
/////////////////////////////////////////////////////////////////////////////////////
// Util Functions
/////////////////////////////////////////////////////////////////////////////////////
function integer count2width(input integer value);
    if (value <= 1) begin
	   	count2width = 1;
    end
    else begin
        value = value - 1;
        for (count2width = 0; value > 0; count2width = count2width + 1) begin
            value = value >> 1;
        end
    end
endfunction