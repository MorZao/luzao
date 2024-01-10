**fabonacci.sv**
```
module  fibonacci(
input  logic clk,
input  logic reset,
input  logic [15:0] din,
input  logic start,
output  logic [15:0] dout,
output  logic done );

// Local logic signals
logic [15:0] a, b;
enum logic [1:0] {IDLE, CALC, DONE} state, next_state;

// State Transition Logic
always_ff  @(posedge clk, posedge reset) begin

if (reset) begin

state <= IDLE;

a <=  0;
b <=  1;
dout <=  0;
done <=  0;
end  else  begin
state <= next_state;

if (state == CALC) begin

if (b >= din) begin  // Check if the next number will exceed 'din'

next_state <= DONE; // Transition to DONE before updating 'b'

end  else  begin

a <= b;

b <= a + b;

end

end

end

end

  
  

// Output Logic

always_comb  begin

next_state = state; // Default to hold state

case (state)

IDLE:  begin

if (start)

next_state = CALC;

dout =  0;

done =  0;

end

CALC:  begin

if (b < din) begin

dout = b;

done =  0;

end  else  begin

next_state = DONE;

dout = b;

end

end

DONE:  begin

dout = b;

done =  1;

if (start ==  0) next_state = IDLE;

end

endcase

end

endmodule
```

**fibonacci_tb.sv**

```
`timescale 1ns/1ns

  

module  fibonacci_tb;

  

logic clk;

logic reset =  1'b0;

logic [15:0] din =  16'h0;

logic start =  1'b0;

logic [15:0] dout;

logic done;

  

// instantiate your design

fibonacci  fib(clk, reset, din, start, dout, done);

  

// Clock Generator

always

begin

clk =  1'b0;

#5;

clk =  1'b1;

#5;

end

  

initial  begin

// Setup waveform dump

$dumpfile("waveform.vcd");

$dumpvars(0, fibonacci_tb);

  

// Reset

#0 reset =  0;

#10 reset =  1;

#10 reset =  0;

/* ------------- Input of 5 ------------- */

// Inputs into module/ Assert start

#10;

din =  16'd377;

start =  1'b1;

#10 start =  1'b0;

// Wait until calculation is done

#10  wait (done ==  1'b1);

  
  

// Display the result

$display("-----------------------------------------");

$display("Input: %d", din);

if (dout ===  377)

$display("CORRECT RESULT: %d, GOOD JOB!", dout);

else

$display("INCORRECT RESULT: %d, SHOULD BE: 337", dout);

  

// Allow some time for observing the final state in the waveform

#20;

  

// Finish the simulation

$finish;

end

  

endmodule
```
