#!/usr/bin/bash

bash run.sh BM1  1250
bash run.sh BM2  1250
bash run.sh IBM1  1250
bash run.sh IBM2  1250
bash run.sh RIBM1  1250
bash run.sh RIBM2  1250
bash run.sh EUCLID  1250
bash run.sh ME  1250
bash run.sh DCME0  1250
bash run.sh DCME1  1250
bash run.sh DCME2  1250

grep "UVM_ERROR :" rs*.log > error.rpt
