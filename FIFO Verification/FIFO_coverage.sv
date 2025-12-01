package FIFO_coverage_pkg;
import FIFO_transaction_pkg::*;

    class FIFO_coverage;

        FIFO_transaction F_cvg_txn = new();

        covergroup cvr_gp;
            WR_EN_cp:       coverpoint F_cvg_txn.wr_en;
            RD_EN_cp:       coverpoint F_cvg_txn.rd_en;
            FULL_cp:        coverpoint F_cvg_txn.full;
            EMPTY_cp:       coverpoint F_cvg_txn.empty;
            WR_ACK_cp:      coverpoint F_cvg_txn.wr_ack;
            OVERFLOW_cp:    coverpoint F_cvg_txn.overflow;
            ALMOSTFULL_cp:  coverpoint F_cvg_txn.almostfull;
            ALMOSTEMPTY_cp: coverpoint F_cvg_txn.almostempty;
            UNDERFLOW_cp:   coverpoint F_cvg_txn.underflow;

            EMPTY_cross:        cross WR_EN_cp, RD_EN_cp, EMPTY_cp;
            ALMOSTFULL_cross:   cross WR_EN_cp, RD_EN_cp, ALMOSTFULL_cp;
            ALMOSTEMPTY_cross:  cross WR_EN_cp, RD_EN_cp, ALMOSTEMPTY_cp;
            FULL_cross:         cross WR_EN_cp, RD_EN_cp, FULL_cp{
                ignore_bins rd_en_full = binsof(RD_EN_cp) intersect{1} && binsof(FULL_cp) intersect{1};
                }
            WR_ACK_cross:       cross WR_EN_cp, RD_EN_cp, WR_ACK_cp{
                ignore_bins wr_en_ack = binsof(WR_EN_cp) intersect{0} && binsof(WR_ACK_cp) intersect{1};
                }
            OVERFLOW_cross:     cross WR_EN_cp, RD_EN_cp, OVERFLOW_cp{
                ignore_bins wr_en_of = binsof(WR_EN_cp) intersect{0} && binsof(OVERFLOW_cp) intersect{1};
                }
            UNDERFLOW_cross:    cross WR_EN_cp, RD_EN_cp, UNDERFLOW_cp{
                ignore_bins rd_en_uf = binsof(RD_EN_cp) intersect{0} && binsof(UNDERFLOW_cp) intersect{1};
                }
        endgroup

        function new();
            cvr_gp = new();
        endfunction

        function void sample_data(FIFO_transaction F_txn);
            F_cvg_txn = F_txn;
            cvr_gp.sample();
        endfunction

    endclass
endpackage