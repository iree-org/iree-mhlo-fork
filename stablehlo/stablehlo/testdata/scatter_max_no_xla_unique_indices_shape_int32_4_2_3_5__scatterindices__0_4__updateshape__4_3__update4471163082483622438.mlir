// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = stablehlo.constant dense<[0, 4]> : tensor<2xi32>
    %1:2 = call @inputs() : () -> (tensor<4x2x3x5xi32>, tensor<4x3xi32>)
    %2 = call @expected() : () -> tensor<4x2x3x5xi32>
    %3 = "stablehlo.scatter"(%1#0, %0, %1#1) ({
    ^bb0(%arg0: tensor<i32>, %arg1: tensor<i32>):
      %5 = stablehlo.maximum %arg0, %arg1 : tensor<i32>
      stablehlo.return %5 : tensor<i32>
    }) {scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [0, 1], inserted_window_dims = [1, 3], scatter_dims_to_operand_dims = [1, 3]>, unique_indices = true} : (tensor<4x2x3x5xi32>, tensor<2xi32>, tensor<4x3xi32>) -> tensor<4x2x3x5xi32>
    %4 = stablehlo.custom_call @check.eq(%3, %2) : (tensor<4x2x3x5xi32>, tensor<4x2x3x5xi32>) -> tensor<i1>
    return %4 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<4x2x3x5xi32>, tensor<4x3xi32>) {
    %0 = stablehlo.constant dense<"0x000000000100000001000000FBFFFFFF0000000001000000FDFFFFFF000000000100000000000000FDFFFFFF0000000000000000FEFFFFFF0000000000000000F8FFFFFF0000000000000000000000000000000002000000FCFFFFFFFEFFFFFF01000000FFFFFFFFFEFFFFFF0300000001000000010000000000000001000000FBFFFFFFFCFFFFFFFEFFFFFF0000000000000000FFFFFFFFFDFFFFFF0000000000000000030000000100000005000000FFFFFFFF0100000005000000000000000000000003000000FEFFFFFFFEFFFFFFFBFFFFFF000000000300000000000000FAFFFFFF05000000FAFFFFFFFDFFFFFFFEFFFFFF03000000FFFFFFFF02000000FCFFFFFF0000000001000000FCFFFFFF00000000FEFFFFFF040000000000000000000000FFFFFFFF0100000000000000FDFFFFFF00000000FFFFFFFFFDFFFFFFFFFFFFFF000000000200000002000000FEFFFFFFFEFFFFFFFFFFFFFFFAFFFFFFFEFFFFFF010000000300000003000000FDFFFFFFFBFFFFFFFEFFFFFFFDFFFFFFFDFFFFFF000000000000000000000000000000000200000000000000000000000000000000000000FEFFFFFF000000000100000000000000FFFFFFFF0100000000000000FEFFFFFFFCFFFFFFFDFFFFFFFFFFFFFFFFFFFFFF0000000002000000"> : tensor<4x2x3x5xi32>
    %1 = stablehlo.constant dense<[[0, 3, 2], [0, -3, 2], [-4, -4, 0], [0, -1, 2]]> : tensor<4x3xi32>
    return %0, %1 : tensor<4x2x3x5xi32>, tensor<4x3xi32>
  }
  func.func private @expected() -> tensor<4x2x3x5xi32> {
    %0 = stablehlo.constant dense<"0x000000000100000001000000FBFFFFFF0000000001000000FDFFFFFF000000000100000003000000FDFFFFFF0000000000000000FEFFFFFF0200000000000000F8FFFFFF0000000000000000000000000000000002000000FCFFFFFFFEFFFFFF01000000FFFFFFFFFEFFFFFF0300000001000000010000000000000001000000FBFFFFFFFCFFFFFF000000000000000000000000FFFFFFFFFDFFFFFF0000000000000000030000000100000005000000020000000100000005000000000000000000000003000000FEFFFFFFFEFFFFFFFBFFFFFF000000000300000000000000FAFFFFFF05000000FAFFFFFFFDFFFFFFFEFFFFFF03000000FFFFFFFF02000000FCFFFFFF0000000001000000FCFFFFFF00000000FEFFFFFF040000000000000000000000FFFFFFFF0100000000000000FDFFFFFF00000000FFFFFFFFFDFFFFFFFFFFFFFF000000000200000002000000FEFFFFFFFEFFFFFFFFFFFFFFFAFFFFFFFEFFFFFF010000000300000003000000FDFFFFFFFBFFFFFF00000000FDFFFFFFFDFFFFFF000000000000000000000000000000000200000000000000000000000200000000000000FEFFFFFF000000000100000000000000FFFFFFFF0100000000000000FEFFFFFFFCFFFFFFFDFFFFFFFFFFFFFFFFFFFFFF0000000002000000"> : tensor<4x2x3x5xi32>
    return %0 : tensor<4x2x3x5xi32>
  }
}

