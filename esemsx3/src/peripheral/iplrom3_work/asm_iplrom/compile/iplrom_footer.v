// Tip: a default value of 0xFF is better processed by the compiler.
        default:    ff_dbi <= 8'hff;
        endcase
    end

    assign dbi = ff_dbi;
endmodule
