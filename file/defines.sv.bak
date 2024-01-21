
`define D #0.2//ns // unblocking delay
`define WIDTH 64 // data with
`define N 198 // size of FEC block
`define K 194 // size of data + syncbit
`define T 2   // error correction ability
`define M 12  // number of symbols in a block, 128b(16B) per symbol
`define PERIOD 2

`define UNBLOCKING_DELAY #0.2 // ns, unblocking delay
`define DATA_WIDTH 64 // data width
`define FEC_BLOCK_SIZE 198 // size of FEC block
`define DATA_SYNC_SIZE 194 // size of data + sync bit
`define ERROR_CORRECTION_ABILITY 2 // error correction ability
`define SYMBOLS_IN_BLOCK 12 // number of symbols in a block, 128b (16B) per symbol
`define CLOCK_PERIOD 2 // clock period

`define B *8-1

`define BM1
`define BM2
`define IBM1
`define IBM2
`define RIBM1
`define RIBM2

`define EUCLID
`define ME
`define DCME0
`define DCME2

`ifdef BM1
`define S2_KES s2_kes_bm1
`else
`ifdef BM2
`define S2_KES s2_kes_bm2
`else
`ifdef IBM1
`define S2_KES s2_kes_ibm1
`else
`ifdef IBM2
`define S2_KES s2_kes_ibm2
`else
`ifdef RIBM1
`define S2_KES s2_kes_ribm1
`else
`ifdef RIBM2
`define S2_KES s2_kes_ribm2
`else
`ifdef EUCLID
`define S2_KES s2_kes_euclid
`else
`ifdef ME
`define S2_KES s2_kes_me
`else
`ifdef DCME0
`define S2_KES s2_kes_dcme0
`else
`ifdef DCME1
`define S2_KES s2_kes_dcme1
`else
`ifdef DCME2
`define S2_KES s2_kes_dcme2
`else
`define S2_KES s2_kes_dcme2
`endif //DCME2
`endif //DCME1
`endif //DCME0
`endif //ME
`endif //EUCLID
`endif //RIBM2
`endif //RIBM1
`endif //IBM2
`endif //IBM1
`endif //BM2
`endif //BM1

`ifdef RIBM1
`define S3_CSEE s3_cseeh
`else
`ifdef RIBM2
`define S3_CSEE s3_cseeh
`else
`define S3_CSEE s3_csee
`endif //RIBM2
`endif //RIBM1