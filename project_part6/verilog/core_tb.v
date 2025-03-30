// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
`timescale 1ns/1ps

module core_tb;

parameter bw = 4;
parameter psum_bw = 16;
parameter len_kij = 9;
parameter len_onij = 16;
parameter col = 8;
parameter row = 8;
parameter len_nij = 36;

reg clk = 0;
reg reset = 1;

wire [53:0] inst_q; 

reg [1:0]  inst_w_q = 0; 
reg [bw*row-1:0] D_xmem_q = 0;
reg CEN_xmem = 1;
reg WEN_xmem = 1;
reg [10:0] A_xmem = 0;
reg CEN_xmem_q = 1;
reg WEN_xmem_q = 1;
reg [10:0] A_xmem_q = 0;
reg CEN_pmem = 1;
reg WEN_pmem = 1;
reg [10:0] A_pmem = 0;
reg CEN_pmem_q = 1;
reg WEN_pmem_q = 1;
reg [10:0] A_pmem_q = 0;
reg ofifo_rd_q = 0;
reg ififo_wr_q = 0;
reg ififo_rd_q = 0;
reg l0_rd_q = 0;
reg l0_wr_q = 0;
reg execute_q = 0;
reg load_q = 0;
reg acc_q = 0;
reg acc = 0;
reg relu_q = 0;
reg relu = 0;



reg sfp_reset = 0;
reg sfp_reset_q = 0;
reg sfp_sel = 0;
reg sfp_sel_q = 0;
reg chip_sel = 0;
reg chip_sel_q = 0;


reg CEN_pmem2 = 1;
reg WEN_pmem2 = 1;
reg [10:0] A_pmem2 = 0;
reg CEN_pmem_q2 = 1;
reg WEN_pmem_q2 = 1;
reg [10:0] A_pmem_q2 = 0;

reg out_en = 0;
reg out_en_q = 0;

reg sram_reset = 0;
reg sram_reset_q = 0;

reg [1:0]  inst_w; 
reg [bw*row-1:0] D_xmem;
reg [psum_bw*col-1:0] answer;


reg ofifo_rd;
reg ififo_wr;
reg ififo_rd;
reg l0_rd;
reg l0_wr;
reg execute;
reg load;
reg [8*30:1] stringvar;
reg [8*30:1] w_file_name;
wire ofifo_valid;
wire [col*psum_bw-1:0] result;

integer x_file, x_scan_file ; // file_handler
integer w_file, w_scan_file ; // file_handler

integer final_add_file, final_add_scan_file;

integer acc_file, acc_scan_file ; // file_handler
integer out_file, out_scan_file ; // file_handler
integer captured_data; 
integer t, i, j, k, kij;
integer error;

assign inst_q[53] = sram_reset_q;
assign inst_q[52] = out_en_q;
assign inst_q[49:39] = A_pmem_q2;
assign inst_q[51] = CEN_pmem_q2;
assign inst_q[50] = WEN_pmem_q2;
assign inst_q[38] = chip_sel_q;
assign inst_q[37] = sfp_sel_q;
assign inst_q[36] = sfp_reset_q;


assign inst_q[34] = relu_q;
assign inst_q[33] = acc_q;
assign inst_q[32] = CEN_pmem_q;
assign inst_q[31] = WEN_pmem_q;
assign inst_q[30:20] = A_pmem_q;
assign inst_q[19]   = CEN_xmem_q;
assign inst_q[18]   = WEN_xmem_q;
assign inst_q[17:7] = A_xmem_q;
assign inst_q[6]   = ofifo_rd_q;
assign inst_q[5]   = ififo_wr_q;
assign inst_q[4]   = ififo_rd_q;
assign inst_q[3]   = l0_rd_q;
assign inst_q[2]   = l0_wr_q;
assign inst_q[1]   = execute_q; 
assign inst_q[0]   = load_q; 


core  #(.bw(bw), .col(col), .row(row)) core_instance (
	.clk(clk), 
	.inst(inst_q),
	//.ofifo_valid(ofifo_valid),
        .D_xmem(D_xmem_q), 
   //     .sfp_out(sfp_out), 
	.reset(reset),
	.result(result)); 


initial begin 

  inst_w   = 0; 
  D_xmem   = 0;
  CEN_xmem = 1;
  WEN_xmem = 1;
  A_xmem   = 0;
  ofifo_rd = 0;
  ififo_wr = 0;
  ififo_rd = 0;
  l0_rd    = 0;
  l0_wr    = 0;
  execute  = 0;
  load     = 0;
  chip_sel = 0;
  sfp_sel  = 0;
  out_en   = 0;
  

  $dumpfile("core_tb.vcd");
  $dumpvars(0,core_tb);

  x_file = $fopen("activation_tile0.txt", "r");
  // Following three lines are to remove the first three comment lines of the file
  x_scan_file = $fscanf(x_file,"%s", captured_data);
  x_scan_file = $fscanf(x_file,"%s", captured_data);
  x_scan_file = $fscanf(x_file,"%s", captured_data);
  
  acc_file = $fopen("accumulation_while_execution_add.txt", "r");
  
  

  //////// Reset /////////
  #0.5 clk = 1'b0;   reset = 1;  sfp_reset = 1;  sram_reset = 1;
  #0.5 clk = 1'b1; 

  for (i=0; i<10 ; i=i+1) begin
    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;   reset = 0;  sfp_reset = 0;  sram_reset = 0;
  #0.5 clk = 1'b1; 

  #0.5 clk = 1'b0;   
  #0.5 clk = 1'b1;   
  /////////////////////////

  /////// Activation data writing to memory ///////
  for (t=0; t<len_nij; t=t+1) begin  
    #0.5 clk = 1'b0;  x_scan_file = $fscanf(x_file,"%32b", D_xmem); WEN_xmem = 0; CEN_xmem = 0; if (t>0) A_xmem = A_xmem + 1;
    #0.5 clk = 1'b1;   
  end

  #0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0;
  #0.5 clk = 1'b1; 

  $fclose(x_file);
  /////////////////////////////////////////////////


  for (kij=0; kij<9; kij=kij+1) begin  // kij loop

    case(kij)
     0: w_file_name = "weight_kij0.txt";
     1: w_file_name = "weight_kij1.txt";
     2: w_file_name = "weight_kij2.txt";
     3: w_file_name = "weight_kij3.txt";
     4: w_file_name = "weight_kij4.txt";
     5: w_file_name = "weight_kij5.txt";
     6: w_file_name = "weight_kij6.txt";
     7: w_file_name = "weight_kij7.txt";
     8: w_file_name = "weight_kij8.txt";
    endcase
    

    w_file = $fopen(w_file_name, "r");
    // Following three lines are to remove the first three comment lines of the file
    w_scan_file = $fscanf(w_file,"%s", captured_data);
    w_scan_file = $fscanf(w_file,"%s", captured_data);
    w_scan_file = $fscanf(w_file,"%s", captured_data);

    #0.5 clk = 1'b0;   reset = 1;
    #0.5 clk = 1'b1; 

    for (i=0; i<10 ; i=i+1) begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;  
    end

    #0.5 clk = 1'b0;   reset = 0;
    #0.5 clk = 1'b1; 

    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   





    /////// Kernel data writing to memory ///////

    A_xmem = 11'b10000000000;

    for (t=0; t<col; t=t+1) begin  
      #0.5 clk = 1'b0;  w_scan_file = $fscanf(w_file,"%32b", D_xmem); WEN_xmem = 0; CEN_xmem = 0; if (t>0) A_xmem = A_xmem + 1; 
      #0.5 clk = 1'b1;  
    end

    #0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 11'b10000000000;
    #0.5 clk = 1'b1; 
    /////////////////////////////////////



    /////// Kernel data writing to L0 ///////
	 for (t=0; t<col; t=t+1) begin
		#0.5 clk = 1'b0;	WEN_xmem = 1; CEN_xmem = 0;	l0_wr = 1;	if (t>0) A_xmem = A_xmem + 1; 
		#0.5 clk = 1'b1;
	 end
	 #0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0;	
    #0.5 clk = 1'b1; 
	 #0.5 clk = 1'b0;  l0_wr = 0;
    #0.5 clk = 1'b1; 
    /////////////////////////////////////



    /////// Kernel loading to PEs ///////
	 #0.5 clk = 1'b0;	l0_rd = 1; 
	 #0.5 clk = 1'b1;
    for (t=0; t<row; t=t+1) begin
		#0.5 clk = 1'b0;	l0_rd = 1; load=1;
		#0.5 clk = 1'b1;
	 end
    /////////////////////////////////////
  


    ////// provide some intermission to clear up the kernel loading ///
    #0.5 clk = 1'b0;  load = 0; l0_rd = 0;
    #0.5 clk = 1'b1;  
  

    for (i=0; i<10 ; i=i+1) begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;  
    end
    /////////////////////////////////////



    /////// Activation data writing to L0 ///////
    for (t=0; t<len_nij; t=t+1) begin
		#0.5 clk = 1'b0;	WEN_xmem = 1; CEN_xmem = 0;	l0_wr = 1;	if (t>0) A_xmem = A_xmem + 1; 
		#0.5 clk = 1'b1;
	 end
	 #0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0;	;
    #0.5 clk = 1'b1; 
	 #0.5 clk = 1'b0;  l0_wr = 0;
    #0.5 clk = 1'b1; 
    /////////////////////////////////////



    /////// Execution ///////
	 #0.5 clk = 1'b0;	l0_rd = 1; 
	 #0.5 clk = 1'b1;
    for (t=0; t<len_nij; t=t+1) begin
		#0.5 clk = 1'b0;	l0_rd = 1; execute=1;
		#0.5 clk = 1'b1;
	 end
	 #0.5 clk = 1'b0;  l0_rd = 0;	execute=0;
    #0.5 clk = 1'b1; 
	 
	 for (i=0; i<len_nij; i=i+1) begin //wait for the end of exexution
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;
    end 
    /////////////////////////////////////



    //////// OFIFO READ ////////
    // Ideally, OFIFO should be read while execution, but we have enough ofifo
    // depth so we can fetch out after execution.
	 #0.5 clk = 1'b0;
	 A_pmem=0;  A_pmem2=0;
    #0.5 clk = 1'b1; 
    for (t=0; t<len_nij; t=t+1) begin //		
		 //1
		#0.5 clk = 1'b0; ofifo_rd = 1; sfp_sel = 0; 
		//if(i>0) begin    WEN_pmem = 0; CEN_pmem = 0; end
		//if (t>1) A_pmem = A_pmem + 1;
      #0.5 clk = 1'b1;
		
		//2
		#0.5 clk = 1'b0; 
		ofifo_rd = 0; acc = 1;
		
		if (chip_sel == 0) begin
			WEN_pmem = 1; CEN_pmem = 0;
			acc_scan_file = $fscanf(acc_file,"%11b", A_pmem);
		end
		else begin
			WEN_pmem2 = 1; CEN_pmem2 = 0;		
			acc_scan_file = $fscanf(acc_file,"%11b", A_pmem2);
		end
		#0.5 clk = 1'b1;
		
		//3
		#0.5 clk = 1'b0; 
		acc=0;  sfp_sel=1; 
		
		if (chip_sel == 0) 
			CEN_pmem = 1;
		else
			CEN_pmem2 = 1;	
			
		#0.5 clk = 1'b1;
		
		//4
		#0.5 clk = 1'b0; 
		acc=1;  
		#0.5 clk = 1'b1;
		
		//5
		#0.5 clk = 1'b0; 
		acc=0;  sfp_sel=0;
		if (kij == 8) relu = 1;						
		#0.5 clk = 1'b1;
		
		//6
		#0.5 clk = 1'b0; 
		if (kij == 8) relu = 0;
		if (chip_sel == 0) begin
			WEN_pmem2 = 0; CEN_pmem2 = 0; if (t>0) A_pmem2 = A_pmem2 + 1;
			
		end
		else begin
			WEN_pmem = 0; CEN_pmem = 0; if (t>0) A_pmem = A_pmem + 1;			
		end
		
		#0.5 clk = 1'b1;
		
		//7
		#0.5 clk = 1'b0; 
		if (kij % 2 == 0) begin
			CEN_pmem2 = 1; 			
		end
		else begin
			CEN_pmem = 1; 
		end		
		
		sfp_reset=1;		
				
		#0.5 clk = 1'b1;
		
		//8
		#0.5 clk = 1'b0; 
		
		sfp_reset=0;
		
		#0.5 clk = 1'b1;
	 end
    /////////////////////////////////////
	 #0.5 clk = 1'b0;	
	 //A_pmem = A_pmem + 1;		CEN_pmem = 1;  ofifo_rd=0;
	 chip_sel=~chip_sel;
	 #0.5 clk = 1'b1;
	 
  //end  
end  // end of kij loop
  $fclose(acc_file);
  ////////// Accumulation /////////
  out_file = $fopen("out.txt", "r");  
  //acc_file = $fopen("./data/acc_address.txt","r");
  final_add_file = $fopen("final_result_add.txt", "r");
  
  
  
  // Following three lines are to remove the first three comment lines of the file
  out_scan_file = $fscanf(out_file,"%s", answer); 
  out_scan_file = $fscanf(out_file,"%s", answer); 
  out_scan_file = $fscanf(out_file,"%s", answer); 

  error = 0;



  $display("############ Verification Start during accumulation #############"); 

  for (i=0; i<len_onij+1; i=i+1) begin //0:16

    #0.5 clk = 1'b0; 
    #0.5 clk = 1'b1; 

    #0.5 clk = 1'b0; 
    if (i>0) begin
     out_scan_file = $fscanf(out_file,"%128b", answer); // reading from out file to answer
       if (result == answer)
         $display("%2d-th output featuremap Data matched! :D", i); 
       else begin
         $display("%2d-th output featuremap Data ERROR!!", i); 
         $display("sfpout: %128b", result);
         $display("answer: %128b", answer);
         error = 1;
       end
    end
    #0.5 clk = 1'b1; 
 
    #0.5 clk = 1'b0; reset = 1;
    #0.5 clk = 1'b1;  
    #0.5 clk = 1'b0; reset = 0; 
    #0.5 clk = 1'b1;  
	 
	 #0.5 clk = 1'b0;  
	 if (chip_sel == 1) begin //read psum2
		final_add_scan_file = $fscanf(final_add_file,"%11b", A_pmem2); 
		out_en=1;
		WEN_pmem2=1;
		CEN_pmem2=0;
	 end
	 else begin //read psum1
		final_add_scan_file = $fscanf(final_add_file,"%11b", A_pmem); 
		out_en=1;
		WEN_pmem=1;
		CEN_pmem=0;
	 end
	 #0.5 clk = 1'b1;  
	 
	 #0.5 clk = 1'b0;  
	 CEN_pmem2=1;  CEN_pmem=1;
	 #0.5 clk = 1'b1;  
	 //read address from file. Send data in the psum memory specified by the address to the sfp and accumulate.
   /* for (j=0; j<len_kij+1; j=j+1) begin 

      #0.5 clk = 1'b0;   
        if (j<len_kij) begin CEN_pmem = 0; WEN_pmem = 1; acc_scan_file = $fscanf(acc_file,"%11b", A_pmem); end
                       else  begin CEN_pmem = 1; WEN_pmem = 1; end

        if (j>0)  acc = 1;  
      #0.5 clk = 1'b1;   
    end

    #0.5 clk = 1'b0; acc = 0;
    #0.5 clk = 1'b1; 
	 
	 #0.5 clk = 1'b0; relu = 1;
    #0.5 clk = 1'b1; 
	 #0.5 clk = 1'b0; relu = 0;
    #0.5 clk = 1'b1; */
	 
	 
	 
  end


  if (error == 0) begin
  	$display("############ No error detected ##############"); 
  	$display("########### Project Completed !! ############"); 

  end

  
  //////////////////////////////////

  for (t=0; t<10; t=t+1) begin  
    #0.5 clk = 1'b0;  
    #0.5 clk = 1'b1;  
  end

  #10 $finish;

end

always @(posedge clk) begin
   inst_w_q   <= inst_w; 
   D_xmem_q   <= D_xmem;
   CEN_xmem_q <= CEN_xmem;
   WEN_xmem_q <= WEN_xmem;
   A_pmem_q   <= A_pmem;
   CEN_pmem_q <= CEN_pmem;
   WEN_pmem_q <= WEN_pmem;
   A_xmem_q   <= A_xmem;
   ofifo_rd_q <= ofifo_rd;
   acc_q      <= acc;
	relu_q	  <= relu;
   ififo_wr_q <= ififo_wr;
   ififo_rd_q <= ififo_rd;
   l0_rd_q    <= l0_rd;
   l0_wr_q    <= l0_wr ;
   execute_q  <= execute;
   load_q     <= load;
	sfp_reset_q<= sfp_reset;
	sfp_sel_q  <= sfp_sel;
	chip_sel_q <= chip_sel;
	A_pmem_q2 <= A_pmem2;
	CEN_pmem_q2<= CEN_pmem2;
   WEN_pmem_q2<= WEN_pmem2;
	out_en_q   <= out_en;
	sram_reset_q<=sram_reset;
end


endmodule




