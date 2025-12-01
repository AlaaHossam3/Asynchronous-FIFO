module FIFO_top();
bit clk;

initial begin
    clk = 0;
    forever 
        #1 clk = ~clk;
end

FIFO_if      FIFOif  (clk);
FIFO         dut     (FIFOif);
FIFO_tb      test    (FIFOif);
FIFO_monitor monitor (FIFOif);

always_comb begin
        if(!FIFOif.rst_n) begin
            RST_assert: assert final (
                FIFOif.data_out    == 0 && 
                FIFOif.full        == 0 &&
                FIFOif.almostfull  == 0 &&
                FIFOif.empty       == 1 &&
                FIFOif.almostempty == 0 &&
                FIFOif.overflow    == 0 && 
                FIFOif.underflow   == 0 && 
                FIFOif.wr_ack      == 0);

            RST_cover: cover final (
                FIFOif.data_out    == 0 && 
                FIFOif.full        == 0 &&
                FIFOif.almostfull  == 0 &&
                FIFOif.empty       == 1 &&
                FIFOif.almostempty == 0 &&
                FIFOif.overflow    == 0 && 
                FIFOif.underflow   == 0 && 
                FIFOif.wr_ack      == 0 );
        end
    end
endmodule