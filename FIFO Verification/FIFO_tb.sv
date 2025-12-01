import shared_pkg::*;
import FIFO_transaction_pkg::*;
module FIFO_tb(FIFO_if.TEST FIFOif);
    
    FIFO_transaction trans;
    initial begin
        trans = new();

        FIFOif.rst_n = 0;
        -> trigger;

        @(negedge FIFOif.clk);
        FIFOif.data_in = 0;
        FIFOif.wr_en   = 0;
        FIFOif.rd_en   = 1;
        FIFOif.rst_n   = 1;

        repeat(100000) begin
            assert(trans.randomize());
            FIFOif.data_in = trans.data_in;
            FIFOif.wr_en   = trans.wr_en;
            FIFOif.rd_en   = trans.rd_en;
            FIFOif.rst_n   = trans.rst_n;
            -> trigger;
            @(negedge FIFOif.clk);
        end
        test_finished = 1;
        -> trigger;
    end
endmodule