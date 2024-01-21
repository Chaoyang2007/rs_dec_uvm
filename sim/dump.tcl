call {$fsdbDumpfile ("twave.fsdb")};
call {$fsdbDumpvars (0, "top")};

run 600000ns
exit
