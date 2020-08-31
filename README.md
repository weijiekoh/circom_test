# circom 0.5.23 vs circom 0.0.34

The witness calcuation of `circuit_bad.circom` works with `circom` v0.0.34, but
now with v0.5.21.

`circuit_works.circom` works with v0.5.21.

To run the code, clone this repository, `cd` into it, and use:

```bash
npm i
npm run build
node ./build/index.js
```

The reason may lie in the way signals are assigned. In `circuit_bad.circom`,
the output signals of `selectors[i]` are wired to the input signals of
`hasher[i]`. The output signal of `hasher[i]`, however, is only wired to
`selectors[i].input_elem` **later on** in a `for` loop.

This makes sense if one imagines that the compiler does some kind of lazy
evaluation - just wire the signals first, and execute the program later. This,
however, does not seem to be the case with `circom` 0.5.21.

See `circuit_simple.circom` as well. The basic structure of the circuits is as
such:

```
0 ==> S0.in[0] 
1 ==> S0.in[1]
      S0.in[2] <== 3
        S0.out[0] ==> A0.left
        S0.out[1] ==> A0.right
                      A0.out ==||
                               ||
1 ==> S1.in[0]                 ||
2 ==> S1.in[1]                 ||
      S1.in[2] <===============//
        S1.out[0] ==> A1.left
        S1.out[1] ==> A1.right
                      A1.out ==> out
```

`S0` and `S1` are selectors and `A0` and `A1` are hashers (which we also call
Adders; it doesn't matter).

It seems that the compiler prefers this following structure, which uses
intermediate signals (`L0`, `L1`, and `L2`) instead.

```
L0 <== 3
||
||
\\==> S0.in[0]
0 ==> S0.in[1]
      S0.out[0] ==> A0.left
      S0.out[1] ==> A0.right
L1 <=============== A0.out
||
||
\\==> S1.in[0]
1 ==> S1.in[1]
      S1.out[0] ==> A1.left
      S0.out[1] ==> A1.right
L2 <=============== A1.out
||
||
\\==> out
```
