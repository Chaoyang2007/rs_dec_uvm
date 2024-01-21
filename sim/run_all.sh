#!/usr/bin/bash

bash run.sh BM1

bash run.sh BM2

bash run.sh IBM1

bash run.sh IBM2

bash run.sh RIBM1

bash run.sh RIBM2

bash run.sh EUCLID

bash run.sh ME

bash run.sh DCME0

bash run.sh DCME2

grep "UVM_ERROR :" rs*.log > error.rpt