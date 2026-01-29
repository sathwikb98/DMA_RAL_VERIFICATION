# DMA_RAL_VERIFICATION
<img width="1164" height="522" alt="DMA_RAL_ARCHITECTURE drawio" src="https://github.com/user-attachments/assets/e68f3893-6a41-4ee5-8468-29a088cf34c5" />
DMA registers are verified here with UVM_RAL model

===========================================================================================
# ----------RUN_COMMANDS:---------------
vlog -sv +acc top.sv
-> vsim -c -voptargs=+acc top +UVM_VERBOSITY=UVM_MEDIUM +UVM_TESTNAME=intr_01_test
-> vsim -c -voptargs=+acc top +UVM_VERBOSITY=UVM_LOW +UVM_TESTNAME=ctrl_01_test

===========================================================================================
 # SEQUENCE AND TEST'S WRITTEN FOR EACH REGISTER
 ----------dma_test_base-------------
 ├── intr_01_test    → intr_01_reset_write_read_seq // --OK--
 ├── intr_03_test    → intr_03_mask_seq // --OK--
 ├── ctrl_01_test    → ctrl_01_start_dma_seq // --OK--
 ├── ioa_01_test     → ioa_01_rw_seq // --OK--
 ├── mem_01_test     → mem_01_rw_seq // --OK--
 ├── sta_01_test     → status_01_busy_seq // --OK--
 ├── tran_01_test    → transfer_01_ro_seq // --OK--
 ├── ext_01_test     → ext_01_rw_seq // --OK--
 ├── desc_01_test    → desc_01_rw_seq // --OK--
 ├── err_sta_01_test → err_01_w1c_seq 
 ├── cfg_01_test     → cfg_01_priority_seq // --OK--
