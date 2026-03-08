# AXI4 Interface UVM Verification Environment
##  Project Overview
This project implements a comprehensive, highly scalable Universal Verification Methodology (UVM) environment to verify a digital IP compliant with the AMBA AXI4 Protocol.

Beyond basic connectivity, this environment integrates advanced SystemVerilog (SV) features, including Functional Coverage (CDV) and SystemVerilog Assertions (SVA), to ensure high design confidence and protocol compliance.

##  Verification Architecture
The environment follows a standard UVM topology, facilitating reusability and modularity:

UVM Agent: Encapsulates the Sequencer, Driver, and Monitor for the AXI4 interface.

Driver: Converts transaction-level objects into AXI4 pin-level signaling (Address, Data, and Control channels).

Monitor: Samples the interface signals and broadcasts transactions via an Analysis Port.

Scoreboard: An associative-array-based reference model that performs real-time data integrity checks by comparing captured read data against stored write data.

Subscriber (Coverage): Implements a covergroup to track functional coverage metrics, ensuring all burst types and length combinations are exercised.

##  Key Features
1. Functional Coverage (Coverage-Driven Verification)
To quantify "how much" has been tested, the axi_coverage component tracks:

Burst Types: FIXED, INCR, and WRAP.

Burst Length: Minimum (1-beat), Maximum (16/256-beats), and mid-range distributions.

Cross Coverage: Ensuring every burst type is validated across multiple data lengths.

2. SystemVerilog Assertions (SVA)
Protocol compliance is monitored at the interface level using concurrent assertions:

Protocol Stability: Ensures AWVALID remains high and AWADDR remains stable until AWREADY is asserted (Handshake integrity).

Data Integrity: Validates data stability during WVALID cycles.

Reset Logic: Ensures all valid signals are driven low during system reset.

3. Constrained Random Testing
Utilizes UVM sequences to generate stimulus that hits edge cases (Corner Cases), such as:

Back-to-back transactions.

Maximum length bursts.

Error-response triggering using out-of-bound addresses.


## Tools & Methodology
Language: SystemVerilog

Methodology: UVM 1.2

Protocol: AMBA AXI4

Verification Technique: Constrained Random, CDV, Assertion-Based Verification (ABV).

## Author
Yu-Shyuen (Jacky) Hung

M.S. in Computer Science, National Taiwan University of Science and Technology.

Specialized in Computer Architecture, gcc/llvm and Digital Verification.
