vlib work
vlog -f src_files.list +cover -covercells
vsim -voptargs=+acc work.FIFO_top -cover 
add wave /FIFO_top/RST_assert 
add wave /FIFO_top/dut/RST_assert 
add wave /FIFO_top/dut/assert__WR_ACK_property 
add wave /FIFO_top/dut/assert__OVERFLOW_property 
add wave /FIFO_top/dut/assert__UNDERFLOW_property 
add wave /FIFO_top/dut/assert__EMPTY_property 
add wave /FIFO_top/dut/assert__FULL_property 
add wave /FIFO_top/dut/assert__ALMOSTFULL_property 
add wave /FIFO_top/dut/assert__ALMOSTEMPTY_property 
add wave /FIFO_top/dut/assert__WRITE_PTR_property 
add wave /FIFO_top/dut/assert__READ_PTR_property 
add wave /FIFO_top/dut/assert__PTR_property 
add wave /FIFO_top/dut/assert__COUNT_property 
add wave -position insertpoint  \
sim:/FIFO_top/FIFOif/almostempty \
sim:/FIFO_top/FIFOif/almostfull \
sim:/FIFO_top/FIFOif/clk \
sim:/FIFO_top/FIFOif/data_in \
sim:/FIFO_top/FIFOif/data_out \
sim:/FIFO_top/FIFOif/empty \
sim:/FIFO_top/FIFOif/FIFO_DEPTH \
sim:/FIFO_top/FIFOif/FIFO_WIDTH \
sim:/FIFO_top/FIFOif/full \
sim:/FIFO_top/FIFOif/overflow \
sim:/FIFO_top/FIFOif/rd_en \
sim:/FIFO_top/FIFOif/rst_n \
sim:/FIFO_top/FIFOif/underflow \
sim:/FIFO_top/FIFOif/wr_ack \
sim:/FIFO_top/FIFOif/wr_en
coverage save top.ucdb -onexit -du work.FIFO
run -all