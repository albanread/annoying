# annoying

How annoying is ARM 32 bit assembler?

The ARM assembler in for example FORTH seems quite reasonable.

The ARM processor seems to have nice instructions and plenty of nice wide registers.
Part of the reason that the FORTH assembler seems nice; is it generates PC relative instructions for you; you can use the FORTH stack to pass around any 32bit sized values; and use FORTH itself to manage variables, constants and literals.

I wanted to see how annoying straight ARM assembler is.

The ARM is tedious when you want to load values; numbers, pointers, etc into registers; unless the values fit into the small ammounts of space left in the ARM instructions; which they generally dont.

So you might imagine that if you want to load a large value you could just load it from memory.

But to load something from memory you first need to load the things address; which also generally wont fit.

To work around this you can use macros to generate the multiple instructions needed to just load a value into an ARM register.

Writing assembly language is an acquired taste; tracking which register does what; adding a shed-load of extra complexity because the instruction set of a 32 bit processor cant load an immediate value without addition or shifting gymnastics is truly annoying.

This extends to addresses as well including things like B and BL; the linker has trouble making them reach.

ARM32 assembler is very annoying, and its brother the Linker even more so.

Because of all this exasperating vileness; the assembler itself provides psuedo instructions; that generate some number of real instructions.

e.g. LDR r0, =xxxxxxxx
Will create the literal xxxxxxx and generate some sequence of instructions to access and load that.

ADDR is a macro it is not an ADR instruction; since ADR can not reach very far.











