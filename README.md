# circom 0.5.23 vs circom 0.0.34

The witness calcuation of `circuit_bad.circom` works with `circom` v0.0.34, but
now with v0.5.23.

`circuit_works.circom` works with v0.5.23.

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
however, does not seem to be the case.
