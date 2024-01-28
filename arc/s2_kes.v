
`ifdef BM1
`include "../arc/s2_kes/s2_kes_bm1.v"
`else
`ifdef BM2
`include "../arc/s2_kes/s2_kes_bm2.v"
`else
`ifdef IBM1
`include "../arc/s2_kes/s2_kes_ibm1.v"
`else
`ifdef IBM2
`include "../arc/s2_kes/s2_kes_ibm2.v"
`else
`ifdef RIBM1
`include "../arc/s2_kes/s2_kes_ribm1.v"
`else
`ifdef RIBM2
`include "../arc/s2_kes/s2_kes_ribm2.v"
`else
`ifdef EUCLID
`include "../arc/s2_kes/s2_kes_euclid.v"
`else
`ifdef ME
`include "../arc/s2_kes/s2_kes_me.v"
`else
`ifdef DCME0
`include "../arc/s2_kes/s2_kes_dcme0.v"
`else
`ifdef DCME1
`include "../arc/s2_kes/s2_kes_dcme1.v"
`else
`ifdef DCME2
`include "../arc/s2_kes/s2_kes_dcme2.v"
`else
`include "../arc/s2_kes/s2_kes_dcme2.v"
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
