// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = stablehlo.constant dense<[[0, 1], [2, 3]]> : tensor<2x2xi32>
    %1:2 = call @inputs() : () -> (tensor<5x6x7xui32>, tensor<2x7xui32>)
    %2 = call @expected() : () -> tensor<5x6x7xui32>
    %3 = "stablehlo.scatter"(%1#0, %0, %1#1) ({
    ^bb0(%arg0: tensor<ui32>, %arg1: tensor<ui32>):
      %5 = stablehlo.minimum %arg0, %arg1 : tensor<ui32>
      stablehlo.return %5 : tensor<ui32>
    }) {scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [1], inserted_window_dims = [0, 1], scatter_dims_to_operand_dims = [0, 1], index_vector_dim = 1>, unique_indices = true} : (tensor<5x6x7xui32>, tensor<2x2xi32>, tensor<2x7xui32>) -> tensor<5x6x7xui32>
    %4 = stablehlo.custom_call @check.eq(%3, %2) : (tensor<5x6x7xui32>, tensor<5x6x7xui32>) -> tensor<i1>
    return %4 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<5x6x7xui32>, tensor<2x7xui32>) {
    %0 = stablehlo.constant dense<"0x010000000100000002000000020000000200000000000000060000000100000001000000060000000100000001000000010000000100000001000000020000000200000000000000000000000100000000000000050000000200000004000000020000000000000002000000000000000100000006000000040000000600000000000000020000000100000008000000010000000000000004000000000000000300000000000000040000000300000001000000020000000100000000000000010000000500000000000000020000000300000000000000000000000100000003000000030000000200000002000000000000000400000003000000010000000000000001000000010000000300000003000000000000000500000001000000040000000200000000000000030000000400000002000000000000000000000000000000010000000100000002000000000000000000000000000000020000000100000000000000010000000000000001000000010000000500000003000000030000000000000000000000000000000200000001000000020000000100000001000000000000000000000002000000070000000000000002000000050000000200000001000000010000000300000001000000030000000000000002000000030000000200000000000000010000000000000002000000020000000100000003000000030000000400000001000000000000000200000002000000000000000000000002000000020000000000000002000000000000000400000002000000020000000100000000000000030000000100000000000000000000000200000000000000000000000500000003000000030000000000000001000000010000000100000000000000020000000000000002000000030000000400000006000000030000000300000003000000000000000000000000000000010000000000000001000000000000000200000003000000000000000100000000000000000000000800000001000000030000000000000005000000030000000000000001000000020000000100000001000000010000000400000005000000030000000000000000000000000000000000000000000000020000000000000005000000000000000000000003000000"> : tensor<5x6x7xui32>
    %1 = stablehlo.constant dense<[[0, 3, 0, 2, 2, 1, 6], [0, 2, 3, 0, 1, 4, 0]]> : tensor<2x7xui32>
    return %0, %1 : tensor<5x6x7xui32>, tensor<2x7xui32>
  }
  func.func private @expected() -> tensor<5x6x7xui32> {
    %0 = stablehlo.constant dense<"0x010000000100000002000000020000000200000000000000060000000000000001000000000000000100000001000000010000000100000001000000020000000200000000000000000000000100000000000000050000000200000004000000020000000000000002000000000000000100000006000000040000000600000000000000020000000100000008000000010000000000000004000000000000000300000000000000040000000300000001000000020000000100000000000000010000000500000000000000020000000300000000000000000000000100000003000000030000000200000002000000000000000400000003000000010000000000000001000000010000000300000003000000000000000500000001000000040000000200000000000000030000000400000002000000000000000000000000000000010000000100000002000000000000000000000000000000020000000100000000000000010000000000000001000000010000000500000003000000030000000000000000000000000000000200000001000000020000000100000001000000000000000000000002000000000000000000000002000000000000000200000001000000010000000300000001000000030000000000000002000000030000000200000000000000010000000000000002000000020000000100000003000000030000000400000001000000000000000200000002000000000000000000000002000000020000000000000002000000000000000400000002000000020000000100000000000000030000000100000000000000000000000200000000000000000000000500000003000000030000000000000001000000010000000100000000000000020000000000000002000000030000000400000006000000030000000300000003000000000000000000000000000000010000000000000001000000000000000200000003000000000000000100000000000000000000000800000001000000030000000000000005000000030000000000000001000000020000000100000001000000010000000400000005000000030000000000000000000000000000000000000000000000020000000000000005000000000000000000000003000000"> : tensor<5x6x7xui32>
    return %0 : tensor<5x6x7xui32>
  }
}

