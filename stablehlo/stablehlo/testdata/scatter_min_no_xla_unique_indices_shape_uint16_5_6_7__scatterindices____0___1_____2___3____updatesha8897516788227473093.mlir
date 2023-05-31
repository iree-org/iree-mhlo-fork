// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = stablehlo.constant dense<[[[0], [1]], [[2], [3]]]> : tensor<2x2x1xi32>
    %1:2 = call @inputs() : () -> (tensor<5x6x7xui16>, tensor<5x2x2x7xui16>)
    %2 = call @expected() : () -> tensor<5x6x7xui16>
    %3 = "stablehlo.scatter"(%1#0, %0, %1#1) ({
    ^bb0(%arg0: tensor<ui16>, %arg1: tensor<ui16>):
      %5 = stablehlo.minimum %arg0, %arg1 : tensor<ui16>
      stablehlo.return %5 : tensor<ui16>
    }) {scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [0, 3], inserted_window_dims = [1], scatter_dims_to_operand_dims = [1], index_vector_dim = 2>, unique_indices = true} : (tensor<5x6x7xui16>, tensor<2x2x1xi32>, tensor<5x2x2x7xui16>) -> tensor<5x6x7xui16>
    %4 = stablehlo.custom_call @check.eq(%3, %2) : (tensor<5x6x7xui16>, tensor<5x6x7xui16>) -> tensor<i1>
    return %4 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<5x6x7xui16>, tensor<5x2x2x7xui16>) {
    %0 = stablehlo.constant dense<"0x030001000200020003000000000004000100000001000300040001000400000004000100030003000100020003000100030002000100020001000300020005000300050003000000000000000100030000000100000000000000010000000900040008000000010004000100000000000000020000000300010001000100000002000000030004000100000004000000050000000300040000000300010002000000030001000000000001000200040002000400040002000500010002000B00010004000100000001000000010002000200030004000100000001000300090002000100010003000200040000000000020000000000050000000000030002000400040001000500030003000100040001000000030005000300000005000300000001000100000003000000000001000400020000000200020003000000010000000300040003000000010000000300000001000000010001000000000001000000010001000100010000000000000003000200040004000400010001000400040000000000020000000100010004000100010000000200000001000100050000000700"> : tensor<5x6x7xui16>
    %1 = stablehlo.constant dense<"0x03000300000000000400010000000000060003000000000002000000020003000200010007000000040000000100030002000400010000000300000000000000050004000000010000000000040002000100000001000300000001000300010002000100010001000000000001000400050004000000010000000300000001000400010001000300040001000100050001000000000000000100010000000200020002000100020002000100000000000100000005000000010001000200040003000300010004000200010002000200020002000200040001000200020001000000010001000300010003000200000003000100030003000400000001000700090002000400000001000200030005000200010001000100"> : tensor<5x2x2x7xui16>
    return %0, %1 : tensor<5x6x7xui16>, tensor<5x2x2x7xui16>
  }
  func.func private @expected() -> tensor<5x6x7xui16> {
    %0 = stablehlo.constant dense<"0x030001000000000003000000000000000100000000000000020000000200000002000100030000000100000001000100020002000100000001000300020005000300050003000000000000000100030000000100000000000000000000000400000001000000000004000100000000000000020000000100010001000100000001000000000000000100000004000000050000000300040000000300010002000000030001000000000001000000010000000300000001000400010001000300010001000100000001000000000000000100010000000100000001000100020002000100010003000200040000000000020000000000050000000000020001000000000001000000030000000100010001000000030003000100000002000100000001000100000002000000000001000200010000000200020003000000010000000300040003000000010000000300000001000000010001000000000000000000010001000100010000000000000003000200040000000100010001000400020000000000010000000100010004000100010000000200000001000100050000000700"> : tensor<5x6x7xui16>
    return %0 : tensor<5x6x7xui16>
  }
}

