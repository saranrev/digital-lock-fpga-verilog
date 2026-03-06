# digital-lock-fpga-verilog
A Digital Lock System implemented using Verilog on an FPGA board, designed based on the Finite State Machine (FSM) concept. The system verifies a user-entered password and grants or denies access accordingly, demonstrating practical hardware design using digital logic and state transitions.

A password-based digital lock system implemented on an FPGA using Verilog HDL, demonstrating the practical application of the Finite State Machine (FSM) concept in digital electronics.

Introduction:
This project implements a Digital Lock System using Verilog on an FPGA board. The system is designed to control access by verifying a user-entered password and unlocking only when the correct code is provided. The design is written in Verilog Hardware Description Language (HDL) and implemented on an FPGA platform to demonstrate hardware-based digital system design.
The project is based on the concept of a Finite State Machine (FSM), which is one of the fundamental and important concepts in Digital Electronics. FSM allows the system to move through different states depending on inputs and conditions. By applying this concept, the lock system processes user input, verifies the password, and controls the locking mechanism in an organized and efficient manner.

Technologies Used:
Verilog HDL for hardware design,
FPGA Development Board for implementation,
Digital Electronics Concepts such as Finite State Machine (FSM),

About Verilog:
Verilog is a Hardware Description Language (HDL) used to model and design digital electronic systems. It allows designers to describe the structure and behavior of digital circuits such as logic gates, registers, and sequential systems. Verilog is widely used in FPGA and ASIC design for simulation, verification, and hardware implementation.
In this project, Verilog is used to implement the logic of the digital lock system and define the different states of the Finite State Machine that control the locking and unlocking process.

Working of the Lock System:
The digital lock system operates through several states defined in the Finite State Machine. Initially, the system starts in the Lock State, where the lock remains closed and waits for user interaction. It then transitions to the Idle State, where the system is ready to receive input from the user.
Next, the system moves to the Input State, where the user enters the password. After receiving the input, the system transitions to the Verify State, where the entered code is compared with the predefined password stored in the system.
If the entered password is correct, the system moves to the Unlock State, granting access by unlocking the system. However, if the password is incorrect, the system enters the Error State, indicating that the password is wrong. The system then returns back to the Lock State, restarting the process for the next attempt after some delay.
