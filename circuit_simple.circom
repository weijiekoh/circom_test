// Just add left and right
template Add() {
  signal input left;
  signal input right;
  signal output out;

  out <== left + right;
}

// 3 inputs, 2 outputs
template Selector() {
  signal input in[3];
  signal output out[2];

  out[0] <== in[0] + in[1];
  out[1] <== in[1] + in[2];
}

template Foo() {
    var n_levels = 2;
    signal output out;

    component selectors[n_levels];
    component adders[n_levels];

    // This for loop assigns values to the first 2 inputs of each Selector, and
    // wires each Selector's outputs to each Adder's inputs.
    // Note that we don't assign anything to the last input of each Selector.
    for (var i = 0; i < n_levels; i++) {
      selectors[i] = Selector();
      adders[i] = Add();

      selectors[i].in[0] <== i;
      selectors[i].in[1] <== i + 1;

      selectors[i].out[0] ==> adders[i].left;
      selectors[i].out[1] ==> adders[i].right;
    }

    // Finally, assign something to the last input of each Selector.
    selectors[0].in[2] <== 3;

    for (var i = 1; i < n_levels; i++) {
      adders[i-1].out ==> selectors[i].in[2];
    }

    out <== adders[n_levels - 1].out;

    /*
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
    */ 

}

component main = Foo();
