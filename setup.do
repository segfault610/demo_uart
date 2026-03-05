# ===============================
# ModelSim compile & run script
# ===============================

# Check if 'work' library exists, create it if missing
if { [file exists work] == 0 } {
    file mkdir work
}

vlib work
vmap work work

# Compile RTL
vlog ./rtl/uart_tx.v
vlog ./rtl/uart_rx.v
vlog ./rtl/uart_top.v

# Compile Testbench
vlog ./tb/tb_uart.v

# Load testbench
vsim tb_uart

# Run simulation
run -all

# Exit ModelSim
quit -f
