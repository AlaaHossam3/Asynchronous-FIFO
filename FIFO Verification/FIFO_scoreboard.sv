package FIFO_scoreboard_pkg;
import FIFO_transaction_pkg::*;
import shared_pkg::*;


    class FIFO_scoreboard;
        parameter FIFO_WIDTH = 16;
        parameter FIFO_DEPTH = 8;

        localparam max_fifo_addr = $clog2(FIFO_DEPTH);

        reg   [FIFO_WIDTH-1:0] data_in_mem[FIFO_DEPTH-1:0];
        logic [FIFO_WIDTH-1:0] data_out_ref;

        logic wr_ack_ref, overflow_ref;
        logic full_ref, empty_ref, almostfull_ref, almostempty_ref, underflow_ref;

        reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
        reg [max_fifo_addr:0]   count;
        
        function void check_data(FIFO_transaction FIFO_trans);

            reference_model(FIFO_trans);
            if( FIFO_trans.data_out !== data_out_ref) begin
                error_count++;
                $display("ERROR, output Data_Out in not correct.");
            end
            else 
                correct_count++;

            if(FIFO_trans.full != full_ref) begin
                error_count++;
                $display("ERROR, output Full in not correct.");
            end
            else 
                correct_count++;
            
            if(FIFO_trans.empty != empty_ref) begin
                error_count++;
                $display("ERROR, output Empty in not correct.");
            end
            else 
                correct_count++;
            
            if(FIFO_trans.almostfull != almostfull_ref) begin
                error_count++;
                $display("ERROR, output Almostfull in not correct.");
            end
            else 
                correct_count++;
            
            if(FIFO_trans.almostempty != almostempty_ref) begin
                error_count++;
                $display("ERROR, output Almostempty in not correct.");
            end
            else 
                correct_count++;
            
            if(FIFO_trans.underflow != underflow_ref) begin
                error_count++;
                $display("ERROR, output Underflow in not correct. at time = %0d", $time);
            end
            else 
                correct_count++;
            
            if(FIFO_trans.overflow != overflow_ref) begin
                error_count++;
                $display("ERROR, output Overflow in not correct.");
            end
            else 
                correct_count++;
            
            if(FIFO_trans.wr_ack != wr_ack_ref) begin
                error_count++;
                $display("ERROR, output Wr_Ack in not correct.");
            end
            else 
                correct_count++;
        endfunction

        function void reference_model(FIFO_transaction FIFO_trans);
            if (!FIFO_trans.rst_n) begin
                wr_ptr       = 0;
                wr_ack_ref   = 0;
                overflow_ref = 0;
            end
            else if (FIFO_trans.wr_en && count < FIFO_DEPTH) begin
                wr_ptr              = wr_ptr + 1;
                wr_ack_ref          = 1;
                overflow_ref        = 0;
                data_in_mem[wr_ptr] = FIFO_trans.data_in;
            end
            else begin
                wr_ack_ref = 0;
                if (full_ref && FIFO_trans.wr_en)
                    overflow_ref = 1;
                else
                    overflow_ref = 0;
            end

            if (!FIFO_trans.rst_n) begin
                rd_ptr        = 0;
                underflow_ref = 0;
                data_out_ref  = 0;
            end
            else if (FIFO_trans.rd_en && !empty_ref) begin
                data_out_ref  = data_in_mem[rd_ptr];
                rd_ptr        = rd_ptr + 1;
                underflow_ref = 0;
            end
            else begin
                if (FIFO_trans.rd_en && empty_ref)
                    underflow_ref = 1;
                else
                    underflow_ref = 0;
            end

            if (!FIFO_trans.rst_n) begin
                count = 0;
            end
            else begin
                if (({FIFO_trans.wr_en, FIFO_trans.rd_en} == 2'b10) && !full_ref)
                    count = count + 1;
                else if (({FIFO_trans.wr_en, FIFO_trans.rd_en} == 2'b01) && !empty_ref)
                    count = count - 1;
                else if (({FIFO_trans.wr_en, FIFO_trans.rd_en} == 2'b11) && full_ref)
                    count = count - 1;
                else if (({FIFO_trans.wr_en, FIFO_trans.rd_en} == 2'b11) && empty_ref)
                    count = count + 1;
            end
            
            full_ref        = (count == FIFO_DEPTH)? 1: 0;
            empty_ref       = (count == 0)? 1: 0;
            almostfull_ref  = (count == FIFO_DEPTH-1)? 1: 0;
            almostempty_ref = (count == 1)? 1: 0;    
        endfunction
    endclass
    
endpackage