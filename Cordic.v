`timescale 1ns / 1ps
module top(input clk,reset,input [31:0]BFP,output[31:0]BFPo);
wire [22:0]mantissa;
wire [29:0]M,x,y;
parameter N = 8'd3;
assign mantissa  = BFP[22:0];
assign M = {3'b001,mantissa,4'b0000};

assign x = M + 30'b001000000000000000000000000000;
assign y = M - 30'b001000000000000000000000000000;

wire[35:0]N1;
wire [35:0]x_LV;
wire [29:0] xo1,yo1,zo1;

assign x_LV = {1'b0,N,27'b000000000000000000000000000};

wire [4:0]i;
//wire [4:0]i1;

wrapper_ghv_LV inst(clk, reset, x,y,x_LV,N1,xo1,yo1,zo1,i);



wire[29:0] xo_ghr1,yo_ghr1,zo_ghr1;



wire [29:0]Z_ghr;
//wire reset1;
wire [4:0]ghri;
wrapper inst1(clk,  Z_ghr,xo_ghr1,yo_ghr1,zo_ghr1,i,ghri);

//assign reset1 = (i<25);

wire [7:0]Exponent;
wire [7:0]Exp;
reg [56:0]mul1;
reg [35:0]mul2;
//wire[29:0]zo;
reg [29:0]logM;

wire [29:0]Mroot;

wire [29:0]Mult;
wire [29:0]Mresult;
wire [7:0] Eresult;

wire [27:0] N2;

assign N2 = N1[27:0];

wire [7:0]EI;
wire [29:0]EF;

assign reset1 = (i<25);
assign Exponent = BFP[30:23];
assign Exp = Exponent - 8'd127;
assign EI = mul2[34:27];
assign EF = {3'b000,mul2[26:0]};

assign Mult =mul1[56:27];
assign Z_ghr = (i>=25)? (EF + Mult):0;


//always @(posedge clk) //2clk cycle delay
always@(*) //1clk cyle delay
begin
     if((~reset)&&(i<25))
            begin
            
            mul1 = 0;
            mul2 = 0;
            logM = 0;
            
            end
    else
      
            begin
            logM = zo1<<<1;
            mul1 = N2*logM;
            mul2 = N2*Exp; 
            end
       
end

//wire [29:0]Mresult1;
assign Mroot = (ghri>=25) ?     (xo_ghr1 + yo_ghr1) : 0;

assign Mresult = (Mroot>=(30'b010000000000000000000000000000)) ? (Mroot>>1) : (Mroot);
assign Eresult  = (Mroot>=(30'b010000000000000000000000000000)) ? (EI+8'd128) : (EI+8'd127);
    
//assign Mresult1 =    Mresult-30'b010000000000000000000000000000;
assign BFPo = {1'b0,Eresult,Mresult[26:4]};
endmodule
 
module wrapper_ghv_LV (
    input wire clk,
    input wire reset,
        
    input wire signed[29:0] initial_inputx,initial_inputy,
    input [35:0]x,output[35:0]result,
    output wire signed [29:0] final_outputx,final_outputy,final_outputz,output [4:0]i
    
);
   // reg signed [29:0] current_inputx,current_inputy,current_inputz;
    wire signed [29:0] module_outputx,module_outputy,module_outputz;
   
   
    parameter max =25;
    

    // Instantiate the module
    ghv u1 (clk,reset,
        initial_inputx,initial_inputy,
        //current_inputx,current_inputy,current_inputz,
        module_outputx,module_outputy,module_outputz,i
        
    );
     cordicdiv  u2(clk, reset,  x, result);

       
    

   assign final_outputx = module_outputx;
    assign final_outputy = module_outputy;
    assign final_outputz = module_outputz;

endmodule



module ghv (input clk,
    input reset,
    //input [4:0]i,
    input wire signed [29:0] x_in,
    input wire signed  [29:0] y_in,
    //input wire signed [29:0] z_in,
    output reg signed [29:0] x_out,
    output reg signed [29:0] y_out,
    output reg signed [29:0] z_out,
    output reg  [4:0] i
);
    
     // Iteration index (4 bits to cover range 0-15)
    parameter max =25;
  reg [1:0] j,k;
    //reg signed [29:0] xi_next, yi_next, zi_next;

     reg signed [29:0] zi_adjusted;
     reg signed [29:0] tanh_inverse_2_neg_i;
        


      always @(posedge clk or posedge reset)
        begin
        
            if(reset)
            begin
                x_out <= x_in;
                y_out <= y_in;
                z_out <= 0;
               // zi_adjusted <= tanh_inverse_2_neg_i;

                i<=1;
                k<=0;
                j<=0;
            end
            else
            begin
                    if(i<max)
                    begin
                        if(((i==4)&&(j!=1))||((i==13)&&(k!=2)))
                            begin
                            
                               

                               x_out <= (y_out[29]==0) ? x_out - (y_out >>> i) : x_out + (y_out >>> i);
                               y_out <= (y_out[29]==0) ? y_out - (x_out >>> i) : y_out + (x_out >>> i);
                               z_out <= (y_out[29]==0) ? (z_out + zi_adjusted) :(z_out - zi_adjusted);
                               j<=j+1;
                               k<=k+1;
                            end
                        else
                            begin
                            
                             
                              i<=i+1;
                             x_out <= (y_out[29]==0) ? x_out - (y_out >>> i) : x_out + (y_out >>> i);
                               y_out <= (y_out[29]==0) ? y_out - (x_out >>> i) : y_out + (x_out >>> i);
                               z_out <= (y_out[29]==0) ? (z_out + zi_adjusted) :(z_out - zi_adjusted);
                              
                            end
                      end
                      else
                      begin
                          i<= (i==27)? i :i+1;
                          x_out<=x_out;
                          y_out<=y_out;
                          z_out<=z_out;
                      end
            end
                    
        end














    


always@(*)
begin
                                     

        case (i)
			    5'd1: tanh_inverse_2_neg_i = 30'b000110010101110000000010000000;    
			    5'd2: tanh_inverse_2_neg_i = 30'b000010111100101010011100000000;  
			    5'd3: tanh_inverse_2_neg_i = 30'b000001011100110100010110000000;   
			    5'd4: tanh_inverse_2_neg_i = 30'b000000101110001110100000000000;    
			    5'd5: tanh_inverse_2_neg_i = 30'b000000010111000101110100000000;    
			    5'd6: tanh_inverse_2_neg_i = 30'b000000001011100010101110000000;    
			    5'd7: tanh_inverse_2_neg_i = 30'b000000000101110001010110000000;     
			    5'd8: tanh_inverse_2_neg_i = 30'b000000000010111000101010000000;     
			    5'd9: tanh_inverse_2_neg_i = 30'b000000000001011100010110000000;     
			    5'd10: tanh_inverse_2_neg_i= 30'b000000000000101110001010000000;    
			    5'd11: tanh_inverse_2_neg_i= 30'b000000000000010111000110000000;     
			    5'd12: tanh_inverse_2_neg_i = 30'b000000000000001011100010000000;     
			    5'd13: tanh_inverse_2_neg_i = 30'b000000000000000101110010000000;
			    5'd14: tanh_inverse_2_neg_i = 30'b000000000000000010111000000000;
			    5'd15: tanh_inverse_2_neg_i = 30'b000000000000000001011100000000;
			    5'd16: tanh_inverse_2_neg_i = 30'b000000000000000000101110000000;
			    5'd17: tanh_inverse_2_neg_i = 30'b000000000000000000011000000000;
			    5'd18: tanh_inverse_2_neg_i = 30'b000000000000000000001100000000;
			    5'd19: tanh_inverse_2_neg_i = 30'b000000000000000000000110000000;
			    5'd20: tanh_inverse_2_neg_i = 30'b000000000000000000000010000000;
			    5'd21: tanh_inverse_2_neg_i = 30'b000000000000000000000010000000;
			    5'd22: tanh_inverse_2_neg_i = 30'b000000000000000000000001000000;
			    5'd23: tanh_inverse_2_neg_i = 30'b000000000000000000000000100000;
			    5'd24: tanh_inverse_2_neg_i = 30'b000000000000000000000000010000;
                            default: tanh_inverse_2_neg_i = 30'b0;
        endcase
            zi_adjusted = tanh_inverse_2_neg_i;
    end



   


      
      


endmodule


module cordicdiv(CLK, EN,  x, out);
   

    input wire CLK;
    input wire EN;
    input wire signed [35:0] x;
    output reg signed [35:0] out;

    parameter MAX_ITERATION = 25;
    reg signed [35:0] y_;
    reg signed [35:0] z_;
    reg [4:0] i,w;
    reg [1:0]j,k;
    always @(posedge CLK)
    begin
        if (EN) //  Like Reset
            begin
                out <= 36'b0;
                z_ <= 36'b0;
                y_ <= 36'b000000001000000000000000000000000000;
                i <= 5'b00001;
                j <= 2'b00;
                k <= 2'b00;
                w <= 5'b00000;
            end
            else
                begin
                            if (i < MAX_ITERATION )
                            begin
                                if(((i==4)&&(j!=1))||((i==13)&&(k!=2)))
                                    begin
                                    y_ <= y_[35] ? y_ + (x >>> i) : y_ - (x >>> i);
                                    z_ <= y_[35] ? z_ - (36'b000000001000000000000000000000000000 >> i) : z_ + (36'b000000001000000000000000000000000000 >> i);
                                    w <= w+1;    
                                    j<=j+1;
                                    k<=k+1;
                                    end
                                else
                                    begin
                                     y_ <= y_[35] ? y_ + (x >>> i) : y_ - (x >>> i);
                                     z_ <= y_[35] ? z_ - (36'b000000001000000000000000000000000000 >> i) : z_ + (36'b000000001000000000000000000000000000 >> i);
                                    w <= w+1;    
                        
                                    i <= i + 1;
                                    end
                            end
                
               end  
               out <= z_; 
    end
endmodule




module wrapper (
    input wire clk,
    input wire  [29:0]initial_inputz,
    output wire  [29:0] final_outputx,final_outputy,final_outputz,input wire [4:0] i1,output [4:0]ghri
);
    wire [29:0] module_outputx,module_outputy,module_outputz;
    
    
    
    // Instantiate the module
    ghr u1 (
       clk,initial_inputz,
        //current_inputx,current_inputy,current_inputz,
        module_outputx,module_outputy,module_outputz,i1,ghri
        
    );

  
    

    assign final_outputx = module_outputx;
    assign final_outputy = module_outputy;
    assign final_outputz = module_outputz;

endmodule







module ghr (
    input clk,
    //input reset,
    //input [4:0]i,
    //input wire  [29:0] x_in,
    //input wire signed  [29:0] y_in,
    input wire  [29:0] z_in,
    output reg  [29:0] x_out,
    output reg  [29:0] y_out,
    output reg  [29:0] z_out,
    input  [4:0] i1,
    output    reg [4:0]i

);
    
     // Iteration index (4 bits to cover range 0-15)

   
     reg  [29:0] zi_adjusted;
     reg  [29:0] tanh_inverse_2_neg_i;
     reg [1:0] j,k;
     parameter max =25;

   



      always @(posedge clk)
        begin
        
            if((i1<27))
            begin
                x_out <= 30'b001001101010001111010000000000;
                y_out <= 30'b0;
                //z_out <= 30'b000010110001011100100010000000;
                z_out <= z_in;

                
                i<=1;
                k<=0;
                j<=0;
            end
            else
            begin
                    if(i<max )
                    begin
                        if(((i==4)&&(j!=1))||((i==13)&&(k!=2)))
                            begin
                            
                               

                               x_out <= (z_out[29]==0) ? x_out + (y_out >>> i) : x_out - (y_out >>> i);
                               y_out <= (z_out[29]==0) ? y_out + (x_out >>> i) : y_out - (x_out >>> i);
                               z_out <= (z_out[29]==0) ? (z_out - zi_adjusted) :(z_out + zi_adjusted);
                               j<=j+1;
                               k<=k+1;
                            end
                        else
                            begin
                            
                             //zi_adjusted <= tanh_inverse_2_neg_i;
                               i<=i+1;
                             x_out <= (z_out[29]==0) ? x_out + (y_out >>> i) : x_out - (y_out >>> i);
                               y_out <= (z_out[29]==0) ? y_out + (x_out >>> i) : y_out - (x_out >>> i);
                               z_out <= (z_out[29]==0) ? (z_out - zi_adjusted) :(z_out + zi_adjusted);
                              
                              
                            end
                      end
                      else
                      begin
                          i<=i;
                          x_out<=x_out;
                          y_out<=y_out;
                          z_out<=z_out;
                      end
            end
        end






always@(*)
begin
                                     

        case (i)
			    5'd1: tanh_inverse_2_neg_i = 30'b000110010101110000000010000000;   
			    5'd2: tanh_inverse_2_neg_i = 30'b000010111100101010011100000000;  
			    5'd3: tanh_inverse_2_neg_i = 30'b000001011100110100010110000000;   
			    5'd4: tanh_inverse_2_neg_i = 30'b000000101110001110100000000000;    
			    5'd5: tanh_inverse_2_neg_i = 30'b000000010111000101110100000000;    
			    5'd6: tanh_inverse_2_neg_i = 30'b000000001011100010101110000000;    
			    5'd7: tanh_inverse_2_neg_i = 30'b000000000101110001010110000000;     
			    5'd8: tanh_inverse_2_neg_i = 30'b000000000010111000101010000000;     
			    5'd9: tanh_inverse_2_neg_i = 30'b000000000001011100010110000000;     
			    5'd10: tanh_inverse_2_neg_i= 30'b000000000000101110001010000000;    
			    5'd11: tanh_inverse_2_neg_i= 30'b000000000000010111000110000000;     
			    5'd12: tanh_inverse_2_neg_i =30'b000000000000001011100010000000;    
			    5'd13: tanh_inverse_2_neg_i =30'b000000000000000101110010000000;
			    5'd14: tanh_inverse_2_neg_i =30'b000000000000000010111000000000;
			    5'd15: tanh_inverse_2_neg_i =30'b000000000000000001011100000000;
			    5'd16: tanh_inverse_2_neg_i =30'b000000000000000000101110000000;
			    5'd17: tanh_inverse_2_neg_i =30'b000000000000000000011000000000;
			    5'd18: tanh_inverse_2_neg_i =30'b000000000000000000001100000000;
			    5'd19: tanh_inverse_2_neg_i =30'b000000000000000000000110000000;
			    5'd20: tanh_inverse_2_neg_i =30'b000000000000000000000010000000;
			    5'd21: tanh_inverse_2_neg_i =30'b000000000000000000000001000000;
			    5'd22: tanh_inverse_2_neg_i =30'b000000000000000000000000100000;
			    5'd23: tanh_inverse_2_neg_i =30'b000000000000000000000000010000;
			    5'd24: tanh_inverse_2_neg_i =30'b000000000000000000000000001000;
                            default: tanh_inverse_2_neg_i = 30'b0;
        endcase
            zi_adjusted = tanh_inverse_2_neg_i;
    end


   
      
      


endmodule

