module HA(input A, B,
           output S, C_Out); 
  assign S = A^B; 
  assign C_Out = A&B; 
endmodule 

module FA(input A, B, C,
           output S, C_Out); 
  assign S = A^B^C; 
  assign C_Out = (A&B) | (B&C) | (A&C); 
endmodule 

module Base_Adder_Carry(input [4:0] A,B,
                        input C,
                        output [4:0] S, 
                        output C_Out); 
  wire w1, w2, w3, w4;
  FA FA1(A[0], B[0], C, S[0], w1); 
  FA FA2(A[1], B[1], w1, S[1], w2); 
  FA FA3(A[2], B[2], w2, S[2], w3); 
  FA FA4(A[3], B[3], w3, S[3], w4); 
  FA FA5(A[4], B[4], w4, S[4], C_Out); 
endmodule 
//module Base_Adder_Carry(
//  input [4:0] A, B,
//  input C_in,
//  output [4:0] S,
//  output C_Out
//);
//  wire [4:0] G, P;
//  wire [5:0] C;  
//  assign G = A & B;
//  assign P = A ^ B;  
//  assign C[0] = C_in;
//  assign C[1] = G[0]|(P[0]&C_in);
//  assign C[2] = G[1]|(P[1]&G[0])|(P[1]&P[0]&C_in);
//  assign C[3] = G[2]|(P[2]&G[1])|(P[2]&P[1]&G[0])|(P[2]&P[1]&P[0]&C_in);
//  assign C[4] = G[3]|(P[3]&G[2])|(P[3]&P[2]&G[1])|(P[3]&P[2]&P[1]&G[0])|(P[3]&P[2]&P[1]&P[0]&C_in);
//  assign C[5] = G[4]|(P[4]&G[3])|(P[4]&P[3]&G[2])|(P[4]&P[3]&P[2]&G[1])|(P[4]&P[3]&P[2]&P[1]&G[0])|(P[4]&P[3]&P[2]&P[1]&P[0]&C_in);
//  assign S = P^C[4:0];
//  assign C_Out = C[5];
//endmodule
module adder (
	input  signed [24:0] A,
	input  signed [24:0] B,
	output signed [24:0] sum,
	output               overflow
);

// assign sum = A+B;
// assign overflow = (A[24] & B[24] & ~sum[24]) | (~A[24] & ~B[24] & sum[24]);
wire C1, C2, C3, C4, C5; 
  wire [4:0] S1_0,S1_1, S2_0, S2_1, S3_0, S3_1, S4_0, S4_1, S4_3, S4_4; 
  wire [8:0] M4_0, M4_1; 
  wire C1_0, C1_1, C2_0, C2_1, C3_0, C3_1, C4_0, C4_1, C4_3, C4_4;  
  
  //<-------------------  Stage 1 -------------------------->\\
  Base_Adder_Carry BA1(A[4:0], B[4:0],1'b0, sum[4:0], C1); 
  
  //<-------------------  Stage 2 -------------------------->\\ 
  Base_Adder_Carry BAC1_0(A[9:5], B[9:5], 1'b0, S1_0, C1_0); 
  Base_Adder_Carry BAC1_1(A[9:5], B[9:5], 1'b1, S1_1, C1_1);
  //MUX logic for carry select and sum select 
  assign {sum[9:5], C2} = C1? {S1_1, C1_1}:{S1_0, C1_0}; 
  
  //<-------------------  Stage 3 -------------------------->\\ 
  Base_Adder_Carry BAC2_0(A[14:10], B[14:10], 1'b0, S2_0, C2_0); 
  Base_Adder_Carry BAC2_1(A[14:10], B[14:10], 1'b1, S2_1, C2_1);
  //MUX logic for carry select and sum select 
  assign {sum[14:10], C3} = C2? {S2_1, C2_1}:{S2_0, C2_0}; 
  
  //<-------------------  Partial Stage 4 -------------------------->\\ 
  Base_Adder_Carry BAC3_0(A[19:15], B[19:15], 1'b0, S3_0, C3_0); 
  Base_Adder_Carry BAC3_1(A[19:15], B[19:15], 1'b1, S3_1, C3_1);
  //MUX logic for carry select and sum select 
  assign {sum[19:15], C4} = C3? {S3_1, C3_1}:{S3_0, C3_0};
  //assign C4_temp = C4; 
  //<-------------------  Partial Stage 5 -------------------------->\\ 
  Base_Adder_Carry BAC4_0(A[24:20], B[24:20], 1'b0, S4_0, C4_0); 
  Base_Adder_Carry BAC4_1(A[24:20], B[24:20], 1'b1, S4_1, C4_1);
  //MUX logic for carry select and sum select 
  assign {sum[24:20], C5} = C4? {S4_1, C4_1}:{S4_0, C4_0};
  assign overflow = (A[24]&B[24]&(~sum[24]))|((~A[24])&(~B[24])&sum[24]);
//  assign {S4_3, C4_3} = C3_0? {S4_1, C4_1}: {S4_0, C4_0};  
//  assign {S4_4, C4_4} = C3_1? {S4_1, C4_1}: {S4_0, C4_0};    
//  //<---------- FINAL STAGE MUX ---------->>\\
//  assign M4_0 = {S4_3, S3_0};
//  assign M4_1 = {S4_4, S3_1};
//  assign {sum[24:15], overflow} = C3? {M4_1, C4_4}:{M4_0, C4_3}; 
endmodule