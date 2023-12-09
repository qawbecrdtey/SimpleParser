# Simple Parser

A simple parser for a simple language.

```
expr    ::= ( op expr expr ) | num
op      ::= '+' | '-' | '*' | '/'
num     ::= ['0'-'9']+
```