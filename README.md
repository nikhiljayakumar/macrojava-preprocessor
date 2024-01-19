# MacroJava Preprocessor

Simple Lexer & Parser that allows for for macros (found in C/C++) to be added to Java. Using Flex & Bison, gives introductory understanding to compiler design. 

Takes [MacroJava](https://www.cse.iitm.ac.in/~krishna/cs3300/macrojava-spec.html) file as input and returns Java file with macros added. Full problem statement [here](https://www.cse.iitm.ac.in/~krishna/cs3300/hw1.html).

If X.java contains the appropriate MacroJava file, then follow instructions to output Java file into Y.java

```
bison -d P1.y
flex P1.l
gcc P1.tab.c lex.yy.c -lfl -o P1
./P1 Y.java 
```
Existing Issues
 - Cannot parse comments (not given in grammar)
 - Incorrect indentation in output file
