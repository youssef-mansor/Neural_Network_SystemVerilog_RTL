module cocotb_iverilog_dump();
initial begin
    $dumpfile("sim_build/NN.fst");
    $dumpvars(0, NN);
end
endmodule
