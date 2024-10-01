**TL;DR - *Cracking Digital VLSI Verification Interview* 1st UVM project yap session - trials and tribulations**

For some context, I've decided to take a crack at the UVM projects provided by the *Cracking Digital VLSI Verification Interview* book by Ramdas M and Robin Garg, so I can crack DV interviews.

No matter how much I interview prep, the verification rabbit hole just keeps going, but I figure the fastest way to learn is by making UVM testbenches. These projects don't have much hand-holding though. The extent of help are basic DUTs and an APB testbench in the author's [github](https://github.com/VerificationExcellence).

As a matter of fact, the author states, "*We are intentionally not providing a complete code database as solution as it defeats the purpose of reader putting that extra amount of effort in coding.*"

I can't seem to find any other attempted solutions online, so I figured I might as well try it myself without an optimal solution to compare against. After all, real engineering rarely has a "correct" solution to compare against.

I made a [lengthy post](https://www.reddit.com/r/FPGA/comments/1fsjpuf/uvm_register_abstraction_layer/) yesterday hoping for some input on the best way to implement a register abstraction layer to verify the first project - a dual-port RAM. Although I didn't get any replies, I still think I've made a decent amount of headway into an amateur-ish solution and wanted to make a blog-style post as a "lessons-learned" list for my future self and any others whom may stumble across similar struggles.

Starting off with the [UVM for Candy Lovers RAL tutorial](https://cluelogic.com/2012/10/uvm-tutorial-for-candy-lovers-register-abstraction/) and [ChipVerify's article on backdoor access](https://www.chipverify.com/uvm/uvm-register-backdoor-access), I wanted to make user-defined classes of `uvm_reg` and `uvm_reg_block` with the idea that I would instantiate an array of 256 8-bit wide `dpram_reg` registers in my `dpram_reg_block` to mimic the 256 byte memory block in the DUT.

However, just as I was about to implement it using `uvm_reg_map`'s `add_reg()` function, I saw the `add_mem()` function just below it in [documentation](https://verificationacademy.com/verification-methodology-reference/uvm/docs_1.1b/html/files/reg/uvm_reg_map-svh.html#uvm_reg_map.add_reg). Seeing as I was trying to verify a memory block, I decided to dig into using that function instead. Unlike `uvm_reg` which benefits from user-defined subclasses to specify the uses and fields of the register, `uvm_mem` in most cases does not need to be specialized into a user-defined subclass. After all, it's just storing data and does not inherently map to control or status bits as a register might.

Moreover, reading the `uvm_mem` [documentation ](https://verificationacademy.com/verification-methodology-reference/uvm/docs_1.1b/html/files/reg/uvm_mem-svh.html#uvm_mem)seems to suggest that backdoor access is actually encouraged. Considering that this aligned with the intuition I had after a first-attempt UVM testbench for the DP RAM block, I decided to research how other testbenches use `uvm_mem` to model memory blocks.

Of course, I struggled to find a good resource on how to use `uvm_mem` in what seems to be a reoccurring theme of limited reference code and poor explanations that I can't seem to escape on this journey to mastering UVM. ChatGPT has been a great tool in filling in gaps, but even it is prone to mistakes. In fact, I asked it (GPT-4o) how to instantiate a `uvm_mem` object in a `uvm_reg_block` and it botched it three times in direct contradiction to the documented function signatures.

Eventually, I did stumble across a [forum post](https://verificationacademy.com/forums/t/back-door-access-for-uvm-mem/40973) that linked to a very useful but somewhat complex [example](https://www.edaplayground.com/x/6DJg) in EDA Playground. That playground served as reference code to instantiate a `uvm_mem` object inside my user-defined class `dpram_reg_block extends uvm_reg_block`. A few things I gleaned from the example:


1. `uvm_mem` construction and configuration

   
   1. If using `uvm_mem` as is, you do not need to use `uvm_mem::type_id::create()` to instantiate a new object as `uvm_mem` is a type defined by the UVM library and not a user-defined subclass that needs to be registered with the factory. Using `type_id::create()` wouldn't work anyways as the `new()` function has extra parameters to specify the number of words and number of bits per word in the memory block.
2. Backdoor access redundancy

   
   1. In `regmodel.sv` , it uses the `uvm_mem::add_hdl_path_slice()` function and `uvm_reg_block::add_hdl_path()` function to specify the memory block in the DUT the backdoor access should refer to. In `my_mem_backdoor.sv` , a `uvm_reg_backdoor`subclass is defined with custom `read()` and `write()` functions, and `topenv.sv` instantiates a `my_mem_backdoor` that connects to the register block's backdoor. If either the `add_hdl_path()` functions or all the `my_mem_backdoor` code gets commented out, the simulation seems to run the same as long as one of them are still in use.
3. UVM hierarchy and encapsulation is flexible yet unpredictable

   
   1. In `bus.sv`, `bus_env_default_seq` uses the `bus_reg_block` that refers to the DUT's memory block the testbench is supposed to backdoor access, which is exactly what the derived sequence in `bus_env_reg_seq.sv` does with its `burst_write()`s and `burst_read()`s. What I couldn't figure out before taking a deep-dive into the structure and organization of the testbench is how the sequence constructed the `bus_reg_block` it was using. After all, you have to construct an object before using it.
   2. Doing some digging, I found that the example testbench

      
      1. constructs the `top_reg_block` in the `build_phase()` of the `top_env` class, which then constructs the `bus_reg_block` by calling the `build()` function as defined in `regmodel.sv`. (line 163-164)
      2. Then, in the `top_default_seq::body()`, the `bus_reg_block` of the `bus_env_default_seq` is connected to the `top_default_seq` register block. (line 80)
      3. That `top_default_seq` virtual sequence register block is set to the register block created in the `top_env::build_phase` by `vseq.regmodel = regmodel` in `top_env::run_phase()`. (line 213)
   3. Data encapsulation is helpful in abstracting such a convoluted implementation, but it sure is hard for a UVM newbie like myself. It's worth the effort, but I just wish there was a guide to ease beginners into the complexity. Without a solid foundation in SystemVerilog and OOP concepts from C++ and Java, I'd definitely struggle a lot more.

An interesting convention I noticed is that the example used the backdoor reads and writes in the sequence and checked results using assert statements after the reads and writes. From my perspective, it makes sense for the sequence to backdoor access the DUT in case frontdoor access is insufficient in providing stimuli to the DUT.

What I don't understand is checking outputs in the sequence itself. Isn't that the scoreboard's job? Maybe it's just for proof-of-concept to show how to backdoor access the DUT, but other examples like [this](https://www.edaplayground.com/x/3Zw6) and [this](https://www.edaplayground.com/x/Rfjn) perform backdoor access right in the test itself, completely disregarding a scoreboard. Even the [UVM for Candy Lovers Backdoor access tutorial](https://www.edaplayground.com/x/EVA) does all backdoor accesses in the sequence, although backdoor access in the scoreboard isn't exactly necessary considering their testbench and DUT was designed with frontdoor access in mind.

None of the examples I've seen attempted using backdoor reads in the scoreboard to check output correctness, so with the risk of flying in the face against convention, I wanted to try implementing it myself.


1. In my environment `build_phase()`, I instantiated and `build()` the `dpram_reg_block`
2. In my scoreboard class, I declared a `dpram_reg_block dpram_reg_blk;`
3. In the environment `connect_phase()`, I connected the environment register block to the scoreboard register block: `dpram_sb.dpram_reg_blk = dpram_reg_blk;`
4. In my scoreboard's `check_output()` function, I added the checking logic laid out in the original post

   
   1. If write transaction, backdoor read the write address and compare to the transaction's input byte
   2. If read transaction, backdoor read the read address and compare to the transaction's output byte
   3. If both read and write transaction, check if the input byte, output byte, and byte in RAM are all the same

Backdoor accesses are supposed to take zero simulation time, but because they are written as tasks, they end up being incompatible with the scoreboard's `check_output()` function. Although I could have turned `check_output()` into a task, it was being called by its internal subscriber's `write()` function, which can't be overridden by a task, and I didn't want to have to change my testbench organization just because I added a register block.

For my second approach, I added to my uvm_sequence_item and monitor:


1. Added a new variable to my uvm_sequence_item transaction: `mem_data`
2. In the monitor `run_phase()` task, on top of grabbing the output data from the interface, it performs a backdoor read to get the data at the read or write address and puts it into the transaction's `mem_data`
3. Remove the backdoor reads from the scoreboard and instead check against the transaction's `mem_data`

After all these changes, I was finally able to get my testbench to compile and run. It's gotta work... right?

(as an aside, if you run into a compile error when performing a backdoor access that looks like `Incompatible complex type usage`, make sure you're not specifying .parent(this). Just leave that argument blank so it defaults to null)

For whatever reason, getting your hopes up when trying to get an unfamiliar framework/toolchain/technology to work is a surefire way to make it fail, and that's exactly what happened here. At each attempt of a backdoor read, the simulator threw a `UVM_ERROR: hdl path 'tb_top.dpram0.ram[0]' is 8 bits, but the maximum size is 0. You can increase the maximum via a compile-time flag: +define+UVM_HDL_MAX_WIDTH=<value>`

Naturally, I added the compile flag setting the max width to 8 and outputted the value of `UVM_HDL_MAX_WIDTH` just to be sure that it was being set correctly. In fact, if you don't specify the value in the compile flag, it defaults to 1024, which is definitely not 0. This is where I hit a blocker for a while.

Unsure of what to do, I tried to read carefully through the reference code in case I missed anything setting up the backdoor access. Perhaps I had to set up a uvm_reg_backdoor? But that didn't make sense because the reference code still works when commenting out the uvm_reg_backdoor code. Consulting ChatGPT erroneously led me to believe the error was forgetting to specify the size of memory correctly in the `uvm_mem` construction.

By chance, I eventually ended up changing the simulator after running out of ideas and noticed I got a completely different set of errors using different simulators. Different compilers for the same programming language might vary slightly in behavior in edge cases, but overall, if the source code for a program successfully compiles under one compiler, it should successfully compile under another compiler as long as they are all conforming to the same version of the language standard, e.g. gcc vs clang.

Using different simulators in EDA Playground for the same source HDL/HVL code seems to be way less predictable. What might compile and run under Synopsys VCS might not compile under Cadence Xcelium or Siemens Questa and with completely different errors, which is exactly what happened in this case.

Considering how problematic it is that I have to worry about having to change my testbench depending on which simulator is being used and that none of the free simulators support UVM, I'm shocked there isn't more of an effort to climb out of the hole this industry dug itself into by relying on closed-source proprietary tools. But that's a discussion for another day. In this case, the inconsistency between simulators was actually quite helpful in overcoming the blocker.

In my testbench, I was using the VCS simulator, but the default simulator for the reference code is Xcelium. Knowing that the reference code should "work", I changed the simulator for the reference code to VCS and noticed the following error: `Error-[ACC-STR] Design debug db not found`

Googling the error led me to an [article](https://developer.arm.com/documentation/ka004963/latest/) saying I needed to add compile flags before running VCS. Lo and behold, adding the `-debug_access+r+w+nomemcbk -debug_region+cell` flags did the trick for my testbench. Going back to warnings I initially ignored, I found a warning that would've been useful to pay attention to:

```javascript
Warning-[INTFDV] VCD dumping of interface/program/package
, 33
Selective VCD dumping of interface 'dpram_if' is not supported. Selective
VCD dumping for interfaces, packages and programs is not supported.
Use full VCD dumping '$dumpvars(0)', or use VPD or FSDB dumping, recompile
with '-debug_access'.testbench.sv
```

Turns out `-debug_access+r+w+nomemcbk -debug_region+cell` aren't necessary and simply adding the `-debug_access` is sufficient.

Now why did missing the `-debug_access` flag make VCS complain about the `UVM_HDL_MAX_WIDTH`? I have no idea, and I hope I'm not alone in the sentiment that issues like these make working with SystemVerilog and its simulators that much less appealing.

I am glad I didn't have to implement the whole RAL to get the testbench to work as I mentioned in the last point of uncertainty I had in the previous post. That's something I want to save for a future attempt/testbench.

Anyways, it's something. Not the best or most optimal, but I feel like I've learned a decent bit and am certainly open to constructive criticism. Feel free to check it out [here](https://www.edaplayground.com/x/SVxA)