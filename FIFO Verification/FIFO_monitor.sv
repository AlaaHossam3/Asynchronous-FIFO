import FIFO_transaction_pkg::*;
import FIFO_scoreboard_pkg::*;
import FIFO_coverage_pkg::*;
import shared_pkg::*;

module FIFO_monitor(FIFO_if.MONITOR FIFOif);
    
    FIFO_transaction transac;
    FIFO_scoreboard  score;
    FIFO_coverage    cov;

    initial begin
        transac = new;
        score   = new;
        cov     = new;
    
        forever begin
            wait(trigger.triggered);
            
            @(negedge FIFOif.clk);
            transac.data_in     = FIFOif.data_in; 
            transac.rst_n       = FIFOif.rst_n; 
            transac.wr_en       = FIFOif.wr_en; 
            transac.rd_en       = FIFOif.rd_en; 
            transac.data_out    = FIFOif.data_out; 
            transac.wr_ack      = FIFOif.wr_ack; 
            transac.data_out    = FIFOif.data_out; 
            transac.overflow    = FIFOif.overflow; 
            transac.full        = FIFOif.full; 
            transac.empty       = FIFOif.empty; 
            transac.almostfull  = FIFOif.almostfull; 
            transac.almostempty = FIFOif.almostempty; 
            transac.underflow   = FIFOif.underflow; 
            fork 
                begin
                    cov.sample_data(transac);
                end
                begin
                    score.check_data(transac);
                end
            join
            if(test_finished) begin
                $display("error_count = %0d, correct_count = %0d", 
                         error_count, correct_count);
                $stop;
            end
        end
    end
endmodule