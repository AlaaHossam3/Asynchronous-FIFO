module FIFO(FIFO_if.DUT FIFOif);
parameter FIFO_WIDTH = 16;
parameter FIFO_DEPTH = 8;
 
localparam max_fifo_addr = $clog2(FIFO_DEPTH);

reg [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0];

reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count;

always @(posedge FIFOif.clk or negedge FIFOif.rst_n) begin
	if (!FIFOif.rst_n) begin
		wr_ptr <= 0;
		FIFOif.wr_ack <= 0;
		FIFOif.overflow <= 0;
	end
	else if (FIFOif.wr_en && count < FIFO_DEPTH) begin
		mem[wr_ptr] <= FIFOif.data_in;
		FIFOif.wr_ack <= 1;
		wr_ptr <= wr_ptr + 1;
		FIFOif.overflow <= 0;
	end
	else begin 
		FIFOif.wr_ack <= 0; 
		if (FIFOif.wr_en)
			FIFOif.overflow <= 1;
		else
			FIFOif.overflow <= 0;
	end
end

always @(posedge FIFOif.clk or negedge FIFOif.rst_n) begin
	if (!FIFOif.rst_n) begin
		rd_ptr <= 0;
		FIFOif.underflow <= 0;
		FIFOif.data_out <= 0;
	end
	else if (FIFOif.rd_en && count != 0) begin
		FIFOif.data_out <= mem[rd_ptr];
		rd_ptr <= rd_ptr + 1;
		FIFOif.underflow <= 0;
	end
	else begin
		if (FIFOif.rd_en) begin
			FIFOif.underflow <= 1;
		end
		else
			FIFOif.underflow <= 0;
	end
end

always @(posedge FIFOif.clk or negedge FIFOif.rst_n) begin
	if (!FIFOif.rst_n) begin
		count <= 0;
	end
	else begin
		if	( (FIFOif.wr_en && !FIFOif.rd_en) && !FIFOif.full) 
			count <= count + 1;
		else if ( (!FIFOif.wr_en && FIFOif.rd_en) && !FIFOif.empty)
			count <= count - 1;
		else if ( (FIFOif.wr_en && FIFOif.rd_en) && FIFOif.full)
			count <= count - 1;
		else if ( (FIFOif.wr_en && FIFOif.rd_en) && count == 0)
			count <= count + 1;
	end
end

assign FIFOif.full = (count == FIFO_DEPTH)? 1: 0;
assign FIFOif.empty = (count == 0)? 1: 0;
assign FIFOif.almostfull = (count == FIFO_DEPTH-1)? 1: 0; 
assign FIFOif.almostempty = (count == 1)? 1: 0;

always_comb begin
	if (!FIFOif.rst_n) begin 
		RST_assert: assert final (rd_ptr == 0 && wr_ptr == 0 && count == 0 && FIFOif.empty == 1);
	    RST_cover:  cover  final (rd_ptr == 0 && wr_ptr == 0 && count == 0 && FIFOif.empty == 1);
	end
end

 property WR_ACK_property;
        @(posedge FIFOif.clk) disable iff (!FIFOif.rst_n) 
		(FIFOif.wr_en && !FIFOif.full |=> FIFOif.wr_ack);
    endproperty

    property OVERFLOW_property;
        @(posedge FIFOif.clk) disable iff (!FIFOif.rst_n) 
		(FIFOif.wr_en && FIFOif.full |=> FIFOif.overflow);
    endproperty

    property UNDERFLOW_property;
        @(posedge FIFOif.clk) disable iff (!FIFOif.rst_n) 
		(FIFOif.rd_en && FIFOif.empty |=> FIFOif.underflow);
    endproperty

    property EMPTY_property;
        @(posedge FIFOif.clk) disable iff (!FIFOif.rst_n) 
		(!count |-> FIFOif.empty);
    endproperty

    property FULL_property;
        @(posedge FIFOif.clk) disable iff (!FIFOif.rst_n) 
		(count == FIFOif.FIFO_DEPTH |-> FIFOif.full);
    endproperty

    property ALMOSTFULL_property;
        @(posedge FIFOif.clk) disable iff (!FIFOif.rst_n) 
		(count == FIFOif.FIFO_DEPTH-1 |-> FIFOif.almostfull);
    endproperty

    property ALMOSTEMPTY_property;
        @(posedge FIFOif.clk) disable iff (!FIFOif.rst_n) 
		(count == 1 |-> FIFOif.almostempty);
    endproperty
    
    property WRITE_PTR_property;
        @(posedge FIFOif.clk) disable iff (!FIFOif.rst_n) 
		((FIFOif.wr_en && !FIFOif.full && wr_ptr == FIFOif.FIFO_DEPTH-1) |=> (wr_ptr == 0));
    endproperty
    
    property READ_PTR_property;
        @(posedge FIFOif.clk) disable iff (!FIFOif.rst_n) 
		((FIFOif.rd_en && !FIFOif.empty && rd_ptr == FIFOif.FIFO_DEPTH-1) |=> (rd_ptr == 0));
    endproperty

    property PTR_property;
        @(posedge FIFOif.clk) disable iff (!FIFOif.rst_n) 
		(wr_ptr < FIFOif.FIFO_DEPTH && rd_ptr < FIFOif.FIFO_DEPTH);
    endproperty

    property COUNT_property;
        @(posedge FIFOif.clk) disable iff (!FIFOif.rst_n) 
		(count <= FIFOif.FIFO_DEPTH);
    endproperty

    assert 	property (WR_ACK_property);
    cover 	property (WR_ACK_property);

    assert 	property (OVERFLOW_property);
    cover 	property (OVERFLOW_property);

    assert 	property (UNDERFLOW_property);
    cover 	property (UNDERFLOW_property);

    assert 	property (EMPTY_property);
    cover 	property (EMPTY_property);
    
	assert 	property (FULL_property);
	cover 	property (FULL_property);
    
	assert 	property (ALMOSTFULL_property);
	cover 	property (ALMOSTFULL_property);
    
	assert 	property (ALMOSTEMPTY_property);
	cover 	property (ALMOSTEMPTY_property);
	
    assert 	property (WRITE_PTR_property);
    cover 	property (WRITE_PTR_property);
    
	assert 	property (READ_PTR_property);
	cover 	property (READ_PTR_property);
    
	assert 	property (PTR_property);
	cover 	property (PTR_property);
    
	assert 	property (COUNT_property);
	cover 	property (COUNT_property);

endmodule