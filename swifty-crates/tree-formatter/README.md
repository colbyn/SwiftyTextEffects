# Tree Formatter

```
$ cargo run --example expressions
Simple Number:
42
--------------------------
Simple Unary Operation:
-
╰╼ 5
--------------------------
Simple Binary Operation:
+
├╼ 7
╰╼ 3
--------------------------
Nested Operations:
*
├╼ +
│  ├╼ 1
│  ╰╼ 2
╰╼ -
   ├╼ 3
   ╰╼ 4
--------------------------
Complex Expression:
-
╰╼ *
   ├╼ +
   │  ├╼ 5
   │  ╰╼ 3
   ╰╼ -
      ├╼ 10
      ╰╼ 2
--------------------------
Deeply Nested Expression:
+
├╼ -
│  ├╼ 1
│  ╰╼ *
│     ├╼ 2
│     ╰╼ 3
╰╼ /
   ├╼ 4
   ╰╼ +
      ├╼ 5
      ╰╼ 6
```