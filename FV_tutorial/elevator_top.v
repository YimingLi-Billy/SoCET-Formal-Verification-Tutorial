module elevator_top (
  input clk,
  input rst,

  // Configuration logic
  input        cfg_rnw,
  input [31:0] cfg_addr,
  input [15:0] cfg_wr_data,
  input [15:0] cfg_rd_data,

  // Elevator sense and control
  input [15:0] request_button,    // 1 button for each floor to indicate a floor to stop at
  input  [3:0] current_floor,     // 4-bit value indicating which floor we are at
  output [1:0] elevator_control,  // 2'b00=ELEV_MOTOR_STOP, 2'b01=ELEV_MOTOR_UP, 2'b10=ELEV_MOTOR_DOWN

  // Door sense and control
  input        door_open_sense,
  input        door_close_sense,
  output       door_motor_control // 2'b00=DOOR_STOP, 2'b01=DOOR_OPEN, 2'b10=DOOR_CLOSE
);

// Configuration logic
reg [3:0] cfg_reg_top_floor;
always @(posedge clk or posedge rst) begin
  if (rst) begin
      cfg_reg_top_floor <= 'd0;
  end else if (cfg_rnw==1'b0) begin
    if (cfg_addr==32'hfeedf00d) begin
      cfg_reg_top_floor <= cfg_wr_data[3:0];
    end
  end
end
assign cfg_rd_data[15:4] = 'd0;
assign cfg_rd_data[3:0]  = cfg_reg_top_floor;


// Elevator states
parameter WAIT          = 0;
parameter ELEVATOR_UP   = 1;
parameter ELEVATOR_DOWN = 2;

parameter ELEV_MOTOR_STOP = 2'b00;
parameter ELEV_MOTOR_UP   = 2'b01;
parameter ELEV_MOTOR_DOWN = 2'b10;

// This register has 16 flags indicating if we should stop at the floor
// indicated by the bit position
reg [15:0] floor_to_stop_at;
reg [3:0] floor_done;
genvar i;
generate for (i=0; i<16; i=i+1) begin: floor_to_stop_loop
  always @(posedge clk or posedge rst) begin
    if (rst)
      floor_to_stop_at[i] <= 1'b0;
    else begin
      if (floor_done==i) floor_to_stop_at[i] <= 1'b0;
      else if (i > 0 && request_button[i]) floor_to_stop_at[i] <= 1'b1;
    end
  end
end
endgenerate

reg going_up;
always @(posedge clk or posedge rst) begin
  if (rst) going_up <= 1'b1;
  else if (floor_done==cfg_reg_top_floor) going_up <= 1'b0;
  else if (floor_done=='d1)  going_up <= 1'b1;
end

reg [1:0] state;
always @(posedge clk or posedge rst) begin
  if (rst) begin
	state <= WAIT;
        floor_done <= 0;
  end else begin
    case (state)
      WAIT:
        begin
	if (ready_to_move && ~going_up && current_floor!=1 && floor_to_stop_at!=0)     state <= ELEVATOR_DOWN;
	else if (ready_to_move &&  going_up && current_floor!='d15 && floor_to_stop_at!=0)  state <= ELEVATOR_UP;
	else state <= WAIT;
        end

      ELEVATOR_UP:
	if (floor_to_stop_at[current_floor+1'b1]) begin 
          // Need to stop at next floor
          state <= WAIT; 
          floor_done <= current_floor+1'b1; 
        end else if (current_floor==cfg_reg_top_floor) begin
          state <= WAIT; 
        end else state <= ELEVATOR_UP;

      ELEVATOR_DOWN:
	if (floor_to_stop_at[current_floor+1'b1]) begin
          // Need to stop at next floor
          state <= WAIT; 
          floor_done <= current_floor-1'b1; 
        end else if (current_floor==1) begin
          state <= WAIT; 
        end else state <= ELEVATOR_DOWN;
 
    endcase
  end
end
assign elevator_control = (state==WAIT) ? ELEV_MOTOR_STOP : (state==ELEVATOR_UP) ? ELEV_MOTOR_UP : (state==ELEVATOR_DOWN) ? ELEV_MOTOR_DOWN : ELEV_MOTOR_STOP;

door_controller door_controller_inst (
  .clk(clk),
  .rst(rst),
  .ready_to_open(state==WAIT),
  .request(|request_button),
  .door_open_sense(door_open_sense),
  .door_close_sense(door_close_sense),
  .door_motor_control(door_motor_control),
  .ready_to_move(ready_to_move)
);

endmodule
