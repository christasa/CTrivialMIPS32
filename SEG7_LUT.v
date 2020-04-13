module SEG7_LUT (   oSEG1,iDIG   );
input   wire[3:0]   iDIG;
output  wire[7:0]   oSEG1;
reg     [7:0]   oSEG;

always @(iDIG)
begin
    case(iDIG)
        4'h0 : oSEG[7:0] <= 8'b00000011;  // 0
        4'h1 : oSEG[7:0] <= 8'b10011111;  // 1
        4'h2 : oSEG[7:0] <= 8'b00100101;  // 2
        4'h3 : oSEG[7:0] <= 8'b00001101;  // 3
        4'h4 : oSEG[7:0] <= 8'b10011001;  // 4
        4'h5 : oSEG[7:0] <= 8'b01001001;  // 5
        4'h6 : oSEG[7:0] <= 8'b01000001;  // 6
        4'h7 : oSEG[7:0] <= 8'b00011111;  // 7
        4'h8 : oSEG[7:0] <= 8'b00000001;  // 8
        4'h9 : oSEG[7:0] <= 8'b00001001;  // 9
        4'hA : oSEG[7:0] <= 8'b00010001;       // A
        4'hB : oSEG[7:0] <= 8'b11000001;       // B
        4'hC : oSEG[7:0] <= 8'b01100011;       // C
        4'hD : oSEG[7:0] <= 8'b10000101;   // D
        4'hE : oSEG[7:0] <= 8'b01100001;       // E
        4'hF : oSEG[7:0] <= 8'b01110001;       // F
        default : oSEG[7:0] <= 8'b11111110;
     endcase
end

assign oSEG1 = {~oSEG,1'b0};

endmodule
