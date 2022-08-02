# Software Stack

Software comprises of code and data that is loaded in memory and used by the CPU.
Code means instructions that are to be fetched by the CPU, decoded and executed.
This is called **machine code**, i.e. binary instructions that are understood by the CPU.

TODO: diagram hardware vs software - the benefit of software

So, when compared to hardware, **software is highly flexible**.
We can tie together specific instructions to handle a given task and run them on hardware (CPU, memory, I/O).
Different pieces of these instructions solve different tasks and run on the same hardware.
Moreover, these pieces of instructions can be duplicated and run on different pieces of hardware, thus providing **software reusability**.
All we are left with is creating those pieces of instructions, also called programs.

The most direct way to write programs is in machine code.
First, we browse the CPU's "language" called the ISA - *Instruction Set Architecture* - and then we write the binary (machine code) instructions for our program.
This is how things happened in the early days of computing, when [punched cards](https://en.wikipedia.org/wiki/Punched_card) were used.
Obviously, this is cumbersome, error prone and a mess to maintain, update and reuse.

The next step was to use assembly language.
Assembly language is a human-readable variant of machine code, that is more easily written.
Assembly language programs are assembled into machine code that is then loaded in memory and run on the CPU.
While this makes program writing easier, it still is difficult to maintain.

So higher-level programming languages were devised.
These programming languages provide a set of instructions that are closer to natural language.
This way, programs can be relatively easy written, providing **fast software development**.
Programs are compiled intro corresponding assembly language code, that is then assembled into machine code, that is then loaded in memory and run on the CPU.
Maintenance is simplified and other people can contribute to existing programs.
Another important feature of higher-level programming languages is **portability**: the same program can be compiled and assembled to run on different architectures.

TODO: Diagram with phases of a program

In summary, software has intrinsic characteristics:
* **flexibility**: We can (easily) create new pieces of software.
  Little is required, we don't need raw materials as in the case of hardware or housing or transportation.
* **reusability**: Software can be easily copied to new systems and provide the same benefits there.

Other characteristics are important to have, as they make life easier for both users and developers of software:
* **portability**: This is the ability to build and run the same program on different computing platforms.
  This allows a developer to write the application code once and then run it everywhere.
* **fast development**: We want developers to be able to write code faster, using higher-level programming languages.

The last two characteristics rely on two items:
* **higher-level programming languages**: As discussed above, a compiler will take a higher-level program and transform it into binary code for different computing platforms, thus providing portability.
  Also, it's easier to read (comprehend) and write (develop) source code in a higher-level programming language, thus providing fast development.
* **software stacks**: A software stack is the layering of software such that each lower layer provides a set of features that the higher layer can directly use.
  This means that there is no need for the higher layer to reimplement those features;
  this provides fast development: focus on only the newer / required parts of software.

  Also, each lower layer provides a generic interface to the higher layer.
  These generic interfaces "hides" possible differences in the even lower layers.
  This way, a software stack ensures portability across different other parts of software (and hardware as well).
  For example, the standard C library, that we will present shortly, ensures portability across different operating systems.

TODO: Diagram of generic software stack

TODO: Quiz

## Modern Software Stacks

Most modern computing systems use a software stack such as the one in the figure below:

TODO: modern software stack

This modern software stack allows fast development and provides a rich set of applications to the user.

The basic software component is the **operating system** (OS) (technically the operating system **kernel**).
The OS provides the fundamental primitives to interact with hardware (read and write data) and to manage the running of applications (such as memory allocation, thread creation, scheduling).
These primitives form the **system call API** or **system API**.
An item in the system call API, i.e. the equivalent of a function call that triggers the execution of a functionality in the operating system, is a **system call**.

The system call API is well defined, stable and complete: it exposes the entire functionality of the operating system and hardware.
However, it is also minimalistic with respect to features and it provides a low-level (close to hardware) specification, making it cumbersome to use and **not portable**.

Due to the downsides of the system call API, a basic library, the **standard C library** (also called **libc**), is built on top of it.
The standard C library wraps each system call into an equivalent function call, following a portable calling convention.
Because the system call API uses an OS-specific calling convention, the standard C library typically wraps each system call into an equivalent function call, following a portable calling convention.
More than these wraps, the standard C library provides its own API that is typically portable.
Part of the API exposed by the standard C library is the **standard C API**, also called **ANSI C** or **ISO C**;
this API is typically portable across all platforms (operating systems and hardware).
Despite its name, the standard C library provides APIs that may not be standard, but particular to the underlying operating systems, such as system call wrapper functions.

The existence of the standard C library is reliant on the C programming language, a very simple programming language and very close to the low-level view of the memory.
Because of this, most higher-level and more feature rich programming languages rely on the C library.
Each programming language typically provides a standard library of its own together with a runtime library, both of which rely on the C library.
The standard C library is used to develop programs in the respective programming language.
Conversely, the runtime library is transparent to the user and is used during runtime to provide the features required (such as exception handling, bounds checking, garbage collection etc.).

Other topic-specific libraries (image processing, encryption, compression, regular expression handling etc.) are then built on top of the standard C library and / or specific programming language libraries.
These contribute to the overall set of APIs made available to the developer.

With these APIs made available (system call API, C library API, programming language API, topic-specific APIs), the developer can rapidly create (portable) applications that are then provided to users.
Applications benefit from the larger set of libraries available on a system;
in other words, they employ **software reusability**.

In the rest of this chapter, we will analyze the software stack for different applications, we will build and run different types of applications and libraries and we will take a peek in the implementation of modern operating systems and low-level components.

## Analyzing the Software Stack

To get a better grasp on how the software stack works, let's do a bottom-up approach:
we build and run different programs, that start of by using the system call API (the lowest layer in the software stack) and progressively use higher layers.

### Basic System Calls

The `support/basic-syscall/` folder stores the implementation of a simple program in assembly language for the x86_64 (64 bit) architecture.
The program invokes two system calls: `write` and `exit`.
The program is duplicated in two files using the two x86 assembly language syntaxes: the Intel / NASM syntax (`hello.asm`) and the AT&T / GAS syntax (`hello.s`).

The implementation follows the [x86_64 Linux calling convention](https://x64.syscall.sh/):
* system call ID is passed in the `rax` register
* system call arguments are passed, in order, in the `rdi`, `rsi`, `rdx`, `r10`, `r8`, `r9` registers

Let's build and run the two programs:

```
student@os:~/.../lab/support/basic-syscall$ ls
hello.asm  hello.s  Makefile

student@os:~/.../lab/support/basic-syscall$ make
nasm -f elf64 -o hello-nasm.o hello.asm
cc -nostdlib -no-pie -Wl,--entry=main -Wl,--build-id=none  hello-nasm.o   -o hello-nasm
gcc -c -o hello-gas.o hello.s
cc -nostdlib -no-pie -Wl,--entry=main -Wl,--build-id=none  hello-gas.o   -o hello-gas

student@os:~/.../lab/support/basic-syscall$ ls
hello.asm  hello-gas  hello-gas.o  hello-nasm  hello-nasm.o  hello.s  Makefile

student@os:~/.../lab/support/basic-syscall$ ./hello-nasm
Hello, world!
student@os:~/.../lab/support/basic-syscall$ ./hello-gas
Hello, world!
```

The two programs end up printing the `Hello, world!` message at standard output by issuing the `write` system call.
Then they complete their work by issuing the `exit` system call.
Use `man 2 write` and `man 3 exit` to get a detailed understanding of the syntax and use of the two system calls.
You can also check the [online man pages](): [`write`](https://man7.org/linux/man-pages/man2/write.2.html), [`exit`](https://man7.org/linux/man-pages/man3/exit.3.html)

We use `strace` to inspect system calls issued by a program:

```
student@os:~/.../lab/support/basic-syscall$ strace ./hello-nasm
execve("./hello-nasm", ["./hello-nasm"], 0x7ffc4e175f00 /* 63 vars */) = 0
write(1, "Hello, world!\n", 14Hello, world!
)         = 14
exit(0)                                 = ?
+++ exited with 0 +++
```

There are three system calls captured by `strace`:
* `execve`: this is issued by the shell to create the new process;
  you'll find out more about `execve` in the "Compute" chapter
* `write`: called by the program to print `Hello, world!` to standard output
* `exit`: to exit the program

This is the most basic program for doing system calls.
Given that system calls require a specific calling convention, their invocation can only be done in assembly language.
Obviously, this is not portable (specific to a given CPU architecture, x86_64 in our case) and too verbose and difficult to maintain.
For portability and maintainability, we require a higher level language, such as C.
In order to use C, we need function wrappers around system calls.

#### Practice

Update the `hello.asm` and / or `hello.s` files to print both `Hello, world!` and `Bye, world!`.
This means adding another `write` system call.

TODO: Quiz

### System Call Wrappers

The `support/syscall-wrapper/` folder stores the implementation of a simple program written in C (`main.c`) that calls the `write()` and `exit()` functions.
The functions are defined in `syscall.asm` as wrappers around corresponding system calls.
Each function invokes the corresponding system call using the specific system call ID and the arguments provided for the function call.

The implementation of the two wrapper functions in `syscall.asm` is very simple, as the function arguments are passed in the same registers required by the system call.
This is because of the overlap of the first three registers for the [x86_64 Linux function calling convention](https://en.wikipedia.org/wiki/X86_calling_conventions#System_V_AMD64_ABI) and the [x86_64 Linux system call convention](https://x64.syscall.sh/).

`syscall.h` contains the declaration of the two functions and it's included in `main.c`.
This way, C programs can be written that make function calls that end up making system calls.

Let's build, run and trace system calls for the program:

```
student@os:~/.../lab/support/syscall-wrapper$ ls
main.c  Makefile  syscall.h  syscall.s

student@os:~/.../lab/support/syscall-wrapper$ make
gcc -c -o main.o main.c
nasm -f elf64 -o syscall.o syscall.s
cc -nostdlib -no-pie -Wl,--entry=main -Wl,--build-id=none  main.o syscall.o   -o main

student@os:~/.../lab/support/syscall-wrapper$ ls
main  main.c  main.o  Makefile  syscall.h  syscall.o  syscall.s

student@os:~/.../software-stack/lab/syscall-wrapper$ ./main
Hello, world!

student@os:~/.../lab/support/syscall-wrapper$ strace ./main
execve("./main", ["./main"], 0x7ffee60fb590 /* 63 vars */) = 0
write(1, "Hello, world!\n", 14Hello, world!
)         = 14
exit(0)                                 = ?
+++ exited with 0 +++
```

The trace is similar to the previous example, showing the `write` and `exit` system calls.

By creating system call wrappers as C functions, we are now relieved of the burden of writing assembly language code.
Of course, there has to be an initial implementation of wrapper functions written in assembly language;
but, after that, we can use C only.

#### Practice

Update the files in the `support/syscall-wrapper/` folder to make `read` system call available as a wrapper.
Make a call to the `read` system call to read data from standard input in a buffer.
Then call `write()` to print data from that buffer.

Note that the `read` system call returns the number of bytes `read`.
Use that as the argument to the subsequent `write` call that prints read data.

We can see that it's easier to have wrapper calls and write most of the code in C than in assembly language.

TODO: Quiz

### Common Functions

By using wrapper calls, we are able to write our programs in C.
However, we still need to implement common functions for string management, working with I/O, working with memory.

The simple attempt is to implement these functions (`printf()` or `strcpy()` or `malloc()`) once in a C source code file and then reuse them when needed.
This saves us time (we don't have to reimplement) and allows us to constantly improve one implementation constantly;
there will only be one implementation that we update to increase its safety, efficiency or performance.

The `support/common-functions/` folder stores the implementation of string management functions, in `string.c` and `string.h` and of printing functions in `printf.c` and `printf.h`.
The `printf` implementation is [this one](https://github.com/mpaland/printf).

There are two programs: `main_string.c` showcases string management functions, `main_printf.c` showcases the `printf()` function.

`main_string.c` depends on the `string.h` and `string.c` files that implement the `strlen()` and `strcpy()` functions.
We print messages using the `write()` system call wrapper implemented in `syscall.s`

Let's build and run the program:

```
student@os:~/.../lab/support/common-functions$ make main_string
gcc -fno-stack-protector   -c -o main_string.o main_string.c
gcc -fno-stack-protector   -c -o string.o string.c
nasm -f elf64 -o syscall.o syscall.s
gcc -nostdlib -no-pie -Wl,--entry=main -Wl,--build-id=none  main_string.o string.o syscall.o   -o main_string

student@os:~/.../lab/support/common-functions$ ./main_string
Destination string is: warhammer40k

student@os:~/.../lab/support/common-functions$ strace ./main_string
execve("./main_string", ["./main_string"], 0x7ffd544d0a70 /* 63 vars */) = 0
write(1, "Destination string is: ", 23Destination string is: ) = 23
write(1, "warhammer40k\n", 13warhammer40k
)          = 13
exit(0)                                 = ?
+++ exited with 0 +++
```

When using `strace` we see that only the `write()` system call wrapper triggers a system call.
There are no system calls triggered by `strlen()` and `strcpy()` as can be seen in their implementation.

In addition, `main_printf.c` depends on the `printf.h` and `printf.c` files that implement the `printf()` function.
There is a requirement to implement the `_putchar()` function;
we implement it in the `main_printf.c` file using the `write()` syscall call wrapper.
The `main()` function `main_printf.c` file contains all the string and printing calls.
`printf()` offers a more powerful printing interface, allowing us to print addresses and integers.

Let's build and run the program:

```
student@os:~/.../lab/support/common-functions$ make main_printf
gcc -fno-stack-protector   -c -o printf.o printf.c
gcc -nostdlib -no-pie -Wl,--entry=main -Wl,--build-id=none  main_printf.o printf.o string.o syscall.o   -o main_printf

student@os:~/.../lab/support/common-functions$ ./main_printf
[before] src is at 00000000004026A0, len is 12, content: "warhammer40k"
[before] dest is at 0000000000603000, len is 0, content: ""
copying src to dest
[after] src is at 00000000004026A0, len is 12, content: "warhammer40k"
[after] dest is at 0000000000603000, len is 12, content: "warhammer40k"

student@os:~/.../lab/support/common-functions$ strace ./main_printf
execve("./main_printf", ["./main_printf"], 0x7ffcaaa1d660 /* 63 vars */) = 0
write(1, "[", 1[)                        = 1
write(1, "b", 1b)                        = 1
write(1, "e", 1e)                        = 1
write(1, "f", 1f)                        = 1
write(1, "o", 1o)                        = 1
write(1, "r", 1r)                        = 1
write(1, "e", 1e)                        = 1
write(1, "]", 1])                        = 1
write(1, " ", 1 )                        = 1
write(1, "s", 1s)                        = 1
write(1, "r", 1r)                        = 1
[...]
```

We see that we have greater printing flexibility with the `printf()` function.
However, one downside of the current implementation is that it makes a system call for each character.
This is inefficient and could be improved by printing a whole string.

#### Practice

Enter the `support/common-functions/` folder and go through the practice items below.

1. Update `string.c` and `string.h` to make available the `strcat()` function.
   Call that function in `main_string.c` and print the result.

1. Update the `main_printf.c` file to use the implementation of `sprintf()` to collect information to be printed inside a buffer.
   Call the `write()` function to print the information.
   The `printf()` function will no longer be called.
   This results in a single `write` system call.

Using previously implemented functions allows us to more efficiently write new programs.
These functions provide us with extensive features that we use in our programs.

TODO: Quiz

### Libraries and libc

Once we have common functions implemented, we can reuse them at any time.
The main unit for software reusabibility is the **library**.
In short, a library is a common machine code that can be linked against different other software components.
Each time we want to use the `printf()` function or the `strlen()` function, we don't need to reimplement them.
We also don't need to use existing source code files, rebuild them and reuse them.
We (re)use existing machine code in libraries.

A library is a collection of object files that export given data structures and functions to be used by other programs.
We create a program, we compile and then we link it agaist the library for all the features it provides.

The most important library in modern operating systems is the **standard C library**, also called **libc**.
This is the library providing system call wrappers and basic functionality for input-output, string management, memory management.
By default, a program is always linked with the standard C library.
In the examples above we've explicitly disabled the use of the standard C library with the help of the `-nostdlib` linker option.

By using the standard C library, it's much easier to create new programs.
You call existing functionality in the library and implement only features particular to your program.

The `support/libc/` folder stores the implementation of programs using the standard C library: `hello.c`, `main_string.c` and `main_printf.c`.
These programs are almost identical to those used in the past sections:

* `hello.c` is similar to the programs in `solution/basic-syscall/` and `solution/syscall-wrapper/`
* `main_string.c` and `main_printf.c` are similar to the programs in `solution/common-functions/`

Let's build and run them:

```
student@os:~/.../lab/support/libc$ ls
hello  hello.c  hello.o  main_printf  main_printf.c  main_printf.o  main_string  main_string.c  main_string.o  Makefile

student@os:~/.../lab/support/libc$ make clean
rm -f hello hello.o
rm -f main_printf main_printf.o
rm -f main_string main_string.o

student@os:~/.../lab/support/libc$ ls
hello.c  main_printf.c  main_string.c  Makefile

student@os:~/.../lab/support/libc$ make
cc -Wall   -c -o hello.o hello.c
cc -static  hello.o   -o hello
cc -Wall   -c -o main_printf.o main_printf.c
cc -static  main_printf.o   -o main_printf
cc -Wall   -c -o main_string.o main_string.c
cc -static  main_string.o   -o main_string

student@os:~/.../lab/support/libc$ ls
hello  hello.c  hello.o  main_printf  main_printf.c  main_printf.o  main_string  main_string.c  main_string.o  Makefile

student@os:~/.../lab/support/libc$ ./hello
Hello, world!
Bye, world!
aaa
aaa
^C

student@os:~/.../lab/support/libc$ ./main_string
Destination string is: warhammer40k

student@os:~/.../lab/support/libc$ ./main_printf
[before] src is at 0x492308, len is 12, content: "warhammer40k"
[before] dest is at 0x6bb340, len is 0, content: ""
copying src to dest
[after] src is at 0x492308, len is 12, content: "warhammer40k"
[after] dest is at 0x6bb340, len is 12, content: "warhammer40k"
abc
```

The behavior / output is similar to the ones in the previous sections:

```
student@os:~/.../lab/support/libc$ ../../solution/basic-syscall/hello-nasm
Hello, world!
Bye, world!
aaa
aaa
^C

student@os:~/.../lab/support/libc$ ../../solution/common-functions/main_string
Destination string is: warhammer40k

student@os:~/.../lab/support/libc$ ../../solution/common-functions/main_printf
[before] src is at 0000000000402680, len is 12, content: "warhammer40k"
[before] dest is at 0000000000604000, len is 0, content: ""
copying src to dest
[after] src is at 0000000000402680, len is 12, content: "warhammer40k"
[after] dest is at 0000000000604000, len is 12, content: "warhammer40k"
abc
```

We can inspect the system calls made to check the similarities.
For example, for the `main_printf` program we get the outputs:

```
student@os:~/.../lab/support/libc$ strace ./main_printf
execve("./main_printf", ["./main_printf"], 0x7fff7b38c240 /* 66 vars */) = 0
brk(NULL)                               = 0x15af000
brk(0x15b01c0)                          = 0x15b01c0
arch_prctl(ARCH_SET_FS, 0x15af880)      = 0
uname({sysname="Linux", nodename="[...]", ...}) = 0
readlink("/proc/self/exe", "[...]/operating"..., 4096) = 105
brk(0x15d11c0)                          = 0x15d11c0
brk(0x15d2000)                          = 0x15d2000
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 18), ...}) = 0
write(1, "[before] src is at 0x492308, len"..., 64[before] src is at 0x492308, len is 12, content: "warhammer40k"
) = 64
write(1, "[before] dest is at 0x6bb340, le"..., 52[before] dest is at 0x6bb340, len is 0, content: ""
) = 52
write(1, "copying src to dest\n", 20copying src to dest
)   = 20
write(1, "[after] src is at 0x492308, len "..., 63[after] src is at 0x492308, len is 12, content: "warhammer40k"
) = 63
write(1, "[after] dest is at 0x6bb340, len"..., 64[after] dest is at 0x6bb340, len is 12, content: "warhammer40k"
) = 64
write(1, "ab", 2ab)                       = 2
write(1, "c\n", 2c
)                      = 2
exit_group(0)                           = ?
+++ exited with 0 +++

student@os:~/.../lab/support/libc$ strace ../../solution/common-functions/main_printf
execve("../../solution/common-functions/main_printf", ["../../solution/common-functions/"...], 0x7ffe204eec00 /* 66 vars */) = 0
write(1, "[before] src is at 0000000000402"..., 72[before] src is at 0000000000402680, len is 12, content: "warhammer40k"
) = 72
write(1, "[before] dest is at 000000000060"..., 60[before] dest is at 0000000000604000, len is 0, content: ""
) = 60
write(1, "copying src to dest\n", 20copying src to dest
)   = 20
write(1, "[after] src is at 00000000004026"..., 71[after] src is at 0000000000402680, len is 12, content: "warhammer40k"
) = 71
write(1, "[after] dest is at 0000000000604"..., 72[after] dest is at 0000000000604000, len is 12, content: "warhammer40k"
) = 72
write(1, "ab", 2ab)                       = 2
write(1, "c\n", 2c
)                      = 2
exit(0)                                 = ?
+++ exited with 0 +++
```

The output is similar, with differences at the beginning and the end of the system call trace.
In the case of the libc-built program a series of additional system calls (`brk`, `arch_prctl`, `uname` etc.) are made.
Also, there is an implicit call to `exit_group` instead of an explicit one to `exit` in the non-libc case.
These are initialization and cleanup routines that are implicitly added when using the standard C library.
They are generally used for setting and cleaning up the stack, environment variables and other pieces of information required by the program or the standard C library itself.

We could argue that the initilization steps incur overhead and that's a downside of using the standard C library.
However, these initialization steps are required for almost all programs.
And, given that almost all programs make use of the basic features of the standard C library, libc is almost always used.
We can say the above were exceptions to the rule, where we didn't make use of the standard C library.

Summarizing, the advantages and disadvantages of using the standard C library are:

* (+) easier development: do calls to existing functions already implemented in the standard C library;
  default build and link flags
* (+) portability: if the system provides a standard C library, one calls the library functions that will then interact with the lower-layer API
* (+) implicit initialization and cleanup: no need for you do explicitly create them
* (-) usually larger in size (static) executables
* (-) a level of overhead as the standard C library wraps system calls
* (-) potential security issues: a larger set of (potentially vulnerable) functions are presented by the standard C library

#### Practice

Enter the `support/libc/` folder and go through the practice items below.

1. Use `malloc()` and `free()` functions in the `memory.c` program.
   Make your own use of the allocated memory.

   It's very easy to use memory management functions with the libc.
   The alternative (without the libc) would be more cumbersome.

   Use different values for `malloc()`, i.e. the allocation size.
   Use `strace` to check the system calls invoked by `malloc()` and `free()`.
   You'll see that, depending on the size, the `brk` or `mmap` / `munmap` system calls are invoked.
   And for certain calls to `malloc()` / `free()` no syscall is happening.
   You'll find more about them in the Data chapter (TODO: link when available).

1. Create your own C program with calls to the standard C library in `vendetta.c`.
   Be as creative as you can about the types of functions being made.

TODO: Quiz

### Interfaces, API, ABI

- part of lecture

A library, such as the standard C library, exposes an **interface** that is going to be used by other software components.
The actual library contents are the **implementation**.
The interface consists of **header files** (`.h`).
The implementation is the actual binary library file.

Typically, a library interface (a header file) consists of:

* function declarations (i.e. function headers or function signatures);
  function definitions are typically part of the library implementation
* definitions of structures, classes and other types
* macros
* variable declarations (exported symbols);
  similarly to functions, variable definitions are typically part of the library implementation

The library interface is also called the **library API** (*Application Programming Interface*).
This is what a program that uses the library requires during the build process (compiling and linking).
This however, doesn't guarantee the correct running of the resulting program.
For the program to run correctly, the program itself and the library have to be binary compatible.
That is, the calling convention and data structure layout must match.
These form the **ABI** (*Application Binary Interface*).

It is usually the job of the compiler and linker to ensure that two different pieces of binary software that are run together share the same ABI.
ABI compatibility is required both when linking together a library and a program and when running a program on top of a given operating system.
In the latter case, registers and memory area must be filled correctly by the program as expected by the operating system.

TODO: diagram with API + ABI

### Statically-linked and Dynamically-linked Libraries

Libraries can be statically-linked or dynamically-linked, creating statically-linked executables and dynamically-linked executables.
Typically, the executables found in modern operating systems are dynamically-linked, given their reduced size and ability to share libraries at runtime.

The `support/static-dynamic/` folder stores the implementation of a simple "Hello, World!"-printing program that uses both static and dynamic linking of libraries.
Let's build and run the two executables

```
student@os:~/.../lab/support/static-dynamic$ ls
hello.c  Makefile

student@os:~/.../lab/support/static-dynamic$ make
cc -Wall   -c -o hello.o hello.c
cc   hello.o   -o hello
cc -static -o hello_static hello.o

student@os:~/.../lab/support/static-dynamic$ ls -lh
total 852K
-rwxrwxr-x 1 razvan razvan 8.2K Aug  2 15:53 hello
-rw-rw-r-- 1 razvan razvan   76 Aug  2 15:51 hello.c
-rw-rw-r-- 1 razvan razvan 1.6K Aug  2 15:53 hello.o
-rwxrwxr-x 1 razvan razvan 827K Aug  2 15:53 hello_static
-rw-rw-r-- 1 razvan razvan  237 Aug  2 15:53 Makefile

student@os:~/.../lab/support/static-dynamic$ ./hello
Hello, World!

student@os:~/.../lab/support/static-dynamic$ ./hello_static
Hello, World!
```

The two executables (`hello` and `hello_static`) behave similarly, despite having vastly different sizes (`8.2K` vs. `827K` - 100 times larger).

We use `nm` and `ldd` to catch differences between the two types of resulting executables:

```
student@os:~/.../lab/support/static-dynamic$ ldd hello
        linux-vdso.so.1 (0x00007ffc8d9b2000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f10d1d88000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f10d237b000)

student@os:~/.../lab/support/static-dynamic$ ldd hello_static
        not a dynamic executable

student@os:~/.../lab/support/static-dynamic$ nm hello | wc -l
33

student@os:~/.../lab/support/static-dynamic$ nm hello_static | wc -l
1674
```

The dynamic executable references the dyamically-linked libc library (`/lib/x86_64-linux-gnu/libc.so.6`), whil the statically-linked executable has no references.
Also, given the statically-linked executable integrated entire parts of statically-linked libraries, there are many more symbols than in the case of a dynamically-linked executable (`1674` vs. `33`).

We can use `strace` to see that there are differences in the preparatory system calls for each type of executables.
For the dynamically-linked executable, the dynamically-linked library (`/lib/x86_64-linux-gnu/libc.so.6`) is opened during runtime:

```
student@os:~/.../lab/support/static-dynamic$ strace ./hello
execve("./hello", ["./hello"], 0x7ffc409c6640 /* 66 vars */) = 0
brk(NULL)                               = 0x55a72eda6000
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=198014, ...}) = 0
mmap(NULL, 198014, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7f3136a41000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\3\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\240\35\2\0\0\0\0\0"..., 832) = 832
fstat(3, {st_mode=S_IFREG|0755, st_size=2030928, ...}) = 0
mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f3136a3f000
mmap(NULL, 4131552, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7f3136458000
mprotect(0x7f313663f000, 2097152, PROT_NONE) = 0
mmap(0x7f313683f000, 24576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1e7000) = 0x7f313683f000
mmap(0x7f3136845000, 15072, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f3136845000
close(3)                                = 0
arch_prctl(ARCH_SET_FS, 0x7f3136a404c0) = 0
mprotect(0x7f313683f000, 16384, PROT_READ) = 0
mprotect(0x55a72d1bb000, 4096, PROT_READ) = 0
mprotect(0x7f3136a72000, 4096, PROT_READ) = 0
munmap(0x7f3136a41000, 198014)          = 0
fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 18), ...}) = 0
brk(NULL)                               = 0x55a72eda6000
brk(0x55a72edc7000)                     = 0x55a72edc7000
write(1, "Hello, World!\n", 14Hello, World!
)         = 14
exit_group(0)                           = ?
+++ exited with 0 +++

student@os:~/.../lab/support/static-dynamic$ strace ./hello_static
execve("./hello_static", ["./hello_static"], 0x7ffc9fd45400 /* 66 vars */) = 0
brk(NULL)                               = 0xff8000
brk(0xff91c0)                           = 0xff91c0
arch_prctl(ARCH_SET_FS, 0xff8880)       = 0
uname({sysname="Linux", nodename="yggdrasil", ...}) = 0
readlink("/proc/self/exe", "/home/razvan/school/so/operating"..., 4096) = 116
brk(0x101a1c0)                          = 0x101a1c0
brk(0x101b000)                          = 0x101b000
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 18), ...}) = 0
write(1, "Hello, World!\n", 14Hello, World!
)         = 14
exit_group(0)                           = ?
+++ exited with 0 +++
```

Similarly, we can investigate a system executable (`/bin/ls`) to see that indeed all referenced dynamically-linked libraries are opened (via the `openat` system call) at runtime:

```
student@os:~/.../lab/support/static-dynamic$ ldd $(which ls)
	linux-vdso.so.1 (0x00007ffc3bdf3000)
	libselinux.so.1 => /lib/x86_64-linux-gnu/libselinux.so.1 (0x00007f092bd88000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f092b997000)
	libpcre.so.3 => /lib/x86_64-linux-gnu/libpcre.so.3 (0x00007f092b726000)
	libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007f092b522000)
	/lib64/ld-linux-x86-64.so.2 (0x00007f092c1d2000)
	libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007f092b303000)

student@os:~/.../lab/support/static-dynamic$ strace -e openat ls
openat(AT_FDCWD, "/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libselinux.so.1", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libpcre.so.3", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libdl.so.2", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libpthread.so.0", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/proc/filesystems", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, "/usr/lib/locale/locale-archive", O_RDONLY|O_CLOEXEC) = 3
openat(AT_FDCWD, ".", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3
community  docs  _index.html  search.md
+++ exited with 0 +++
```

- no practice

TODO: Quiz

### Library calls vs system calls

The standard C library has primarily two uses:

1. wrapping system calls into easier to use C-style library calls, such as `open()`, `write()`, `read()`
1. adding common functionality required for our program, such as string management (`strcpy`), memory management (`malloc()`) or formatted I/O (`printf()`)

The first use means a 1-to-1 mapping between library calls and system calls: one library call means one system call.
The second group doesn't have a standard mapping.
A library call could be mapped to no system calls, one system call, two or more system calls or it may depend (a system call may or may not happen).

The `support/libcall-syscall/` folder stores the implementation of a simple program that makes different library calls.
Let's build the program and then trace the library calls (with `ltrace`) and the system calls (with `strace`):

```
student@os:~/.../lab/support/libcall-syscall$ make
cc -Wall   -c -o call.o call.c
cc   call.o   -o call
cc -Wall   -c -o call2.o call2.c
cc   call2.o   -o call2

student@os:~/.../lab/support/libcall-syscall$ ltrace ./call
fopen("a.txt", "wt")                                                                                             = 0x556d57679260
strlen("Hello, world!\n")                                                                                        = 14
fwrite("Hello, world!\n", 1, 14, 0x556d57679260)                                                                 = 14
strlen("Bye, world!\n")                                                                                          = 12
fwrite("Bye, world!\n", 1, 12, 0x556d57679260)                                                                   = 12
fflush(0x556d57679260)                                                                                           = 0
+++ exited (status 0) +++

student@os:~/.../lab/support/libcall-syscall$ strace ./call
[...]
openat(AT_FDCWD, "a.txt", O_WRONLY|O_CREAT|O_TRUNC, 0666) = 3
fstat(3, {st_mode=S_IFREG|0664, st_size=0, ...}) = 0
write(3, "Hello, world!\nBye, world!\n", 26) = 26
exit_group(0)                           = ?
+++ exited with 0 +++
```

We have the following mappings:
* The `fopen()` library call invokes the `openat` and the `fstat` system calls.
* The `fwrite()` library call invokes no system calls.
* The `strlen()` library call invokes no system calls.
* The `fflush()` library call invokes the `write` system call.

This all seems to make sense.
The main reason for `fwrite()` not making any system calls is the use of a standard C library buffer.
Calls the `fwrite()` end up writing to that buffer to reduce the number of system calls.
Actual system calls are made either when the standard C library buffer is full or when an `fflush()` library call is made.

#### Practice

Enter the `support/libcall-syscall/` folder and go through the practice items below.

1. Check library calls and system calls for the `call2.c` file.
   Use `ltrace` and `strace`.

   Find explanations for the calls being made and the library call to system call mapping.

TODO: Quiz

## Arena

Go through the practice items below to hone your skills in working with layers of the software stack.

### System Calls

Enter the `support/basic-syscall/` folder and go through the practice items below.
If you get stuck, take a sneak peak at the solutions in the `solution/basic-syscall/` folder.

For debugging, use `strace` to trace the system calls from your program and make sure the arguments are set right.

1. Update the `hello.asm` and / or `hello.s` files to pause the execution of the program before the `exit` system call.

   You need to make the `sys_pause` system call, with no arguments.
   Find its ID [here](https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/).

1. Update the `hello.asm` and / or `hello.s` files to read a message from standard input and print it to standard output.

   You'll need to define a buffer in the `data` or `bss` section.
   Use the `read` system call to read data in the buffer.
   The return value of `read` (placed in the `rax` register) is the number of bytes read.
   Use that value as the 3rd argument or `write`, i.e. the number of bytes printed.

   Find the ID of the `read` system call [here](https://x64.syscall.sh/).
   To find out more about its arguments, see [its man page](https://man7.org/linux/man-pages/man2/read.2.html).
   Standard input descriptor is `0`.

1. **Difficult**: Port the initial program to ARM on 64 bits (also called **aarch64**).

   Use the skeleton files in the `arm/` folder.
   Find information about the aarch64 system calls [here](https://arm64.syscall.sh/).

1. Create your own program, written in assembly, doing some system calls you want to learn more about.
   Some system calls you could try: `open`, `rename`, `mkdir`.
   Create a Makefile for that program.
   Run the resulting program with `strace` to see the actual system calls being made (and their arguments).

### System Call Wrappers

Enter the `support/syscall-wrapper/` folder and go through the practice items below.
If you get stuck, take a sneak peak at the solutions in the `solution/syscall-wrapper/` folder.

1. Update the files in the `syscall-wrapper/` folder to make the `getpid` system call available as a wrapper.
   Create a function with the signature `unsigned int itoa(int n, char *a)` that converts an integer to a string.
   It returns the number of digits in the string.
   For example, it will convert the number `1234` to the string `"1234"` string (NUL-terminated, 5 bytes long);
   the return value is `4` (the number of digits of the `"1234"` string).

   Then make the call to `getpid`;
   it gets no arguments and returns an integer (the PID - *process ID* of the current process).

### Common Functions

Enter the `support/common-functions/` folder and go through the practice items below.
If you get stuck, take a sneak peak at the solutions in the `solution/common-functions/` folder.

1. Update the `putchar()` function in `main_printf.c` to implement a buffered functionality of `printf()`.
   Characters passed via the `putchar()` call will be stored in a predefined static global buffer.
   The `write()` call will be invoked when a newline is encountered or when the buffer is full.
   This results in a reduced number of `write` system calls.
   Use `strace` to confirm the reduction of the number of `write` system calls.

1. Update the `main_printf.c` file to also feature a `flush()` function that forces the flushing the static global buffer and a `write` system call.
   Make calls to `printf()` and `flush()` to validate the implementation.
   Use `strace` to inspect the `write` system calls invoked by `printf()` and `flush()`.

### Libraries and libc

Enter the `support/libc/` folder and go through the practice items below.
If you get stuck, take a sneak peak at the solutions in the `solution/libc/` folder.

1. Inside the `vendetta.c` file make a call `open("a.txt", O_RDWR | O_CREAT, 0644)` to open / create the `a.txt` file.
   Make sure you include all required headers.
   Check the system call being made.

   Make an `fopen()` with the proper arguments that gets as close as possible to the `open()` call, i.e. the system call arguments are as close as possible.

1. Inside the `vendetta.c` file make a call to `sin()` function (for sine).
   Compute `sin(0)` and `sin(PI/2)`.
