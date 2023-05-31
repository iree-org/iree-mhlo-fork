// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = stablehlo.constant dense<0> : tensor<1xi32>
    %1:2 = call @inputs() : () -> (tensor<1x125xi32>, tensor<1xi32>)
    %2 = call @expected() : () -> tensor<1x125xi32>
    %3 = "stablehlo.scatter"(%1#0, %0, %1#1) ({
    ^bb0(%arg0: tensor<i32>, %arg1: tensor<i32>):
      stablehlo.return %arg1 : tensor<i32>
    }) {scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [0], inserted_window_dims = [1], scatter_dims_to_operand_dims = [1]>, unique_indices = true} : (tensor<1x125xi32>, tensor<1xi32>, tensor<1xi32>) -> tensor<1x125xi32>
    %4 = stablehlo.custom_call @check.eq(%3, %2) : (tensor<1x125xi32>, tensor<1x125xi32>) -> tensor<i1>
    return %4 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<1x125xi32>, tensor<1xi32>) {
    %0 = stablehlo.constant dense<"0x01000000FFFFFFFFFFFFFFFF0000000000000000030000000000000002000000FDFFFFFF030000000300000003000000FFFFFFFF00000000FEFFFFFF0400000003000000FEFFFFFFFDFFFFFF03000000FDFFFFFFFFFFFFFFFCFFFFFF00000000FDFFFFFFFAFFFFFFFFFFFFFF060000000200000002000000FCFFFFFF00000000FEFFFFFF0500000000000000010000000000000002000000FFFFFFFF03000000000000000300000005000000FAFFFFFF000000000400000000000000FDFFFFFF06000000FFFFFFFF00000000FDFFFFFF03000000FFFFFFFF0100000000000000FEFFFFFF02000000FEFFFFFF00000000FFFFFFFF040000000400000002000000FDFFFFFF000000000000000000000000FDFFFFFF07000000FDFFFFFF01000000FBFFFFFFFEFFFFFFFFFFFFFF000000000000000004000000010000000100000000000000040000000000000005000000FCFFFFFFFDFFFFFF03000000FCFFFFFF030000000200000000000000FEFFFFFFFFFFFFFF010000000000000000000000FDFFFFFFFEFFFFFF00000000FEFFFFFF010000000100000002000000FCFFFFFFFCFFFFFF04000000FCFFFFFF01000000FBFFFFFF0200000001000000F8FFFFFFFDFFFFFF0100000005000000FEFFFFFF00000000FCFFFFFFFFFFFFFF060000000100000000000000FEFFFFFF0300000001000000"> : tensor<1x125xi32>
    %1 = stablehlo.constant dense<-1> : tensor<1xi32>
    return %0, %1 : tensor<1x125xi32>, tensor<1xi32>
  }
  func.func private @expected() -> tensor<1x125xi32> {
    %0 = stablehlo.constant dense<"0xFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000030000000000000002000000FDFFFFFF030000000300000003000000FFFFFFFF00000000FEFFFFFF0400000003000000FEFFFFFFFDFFFFFF03000000FDFFFFFFFFFFFFFFFCFFFFFF00000000FDFFFFFFFAFFFFFFFFFFFFFF060000000200000002000000FCFFFFFF00000000FEFFFFFF0500000000000000010000000000000002000000FFFFFFFF03000000000000000300000005000000FAFFFFFF000000000400000000000000FDFFFFFF06000000FFFFFFFF00000000FDFFFFFF03000000FFFFFFFF0100000000000000FEFFFFFF02000000FEFFFFFF00000000FFFFFFFF040000000400000002000000FDFFFFFF000000000000000000000000FDFFFFFF07000000FDFFFFFF01000000FBFFFFFFFEFFFFFFFFFFFFFF000000000000000004000000010000000100000000000000040000000000000005000000FCFFFFFFFDFFFFFF03000000FCFFFFFF030000000200000000000000FEFFFFFFFFFFFFFF010000000000000000000000FDFFFFFFFEFFFFFF00000000FEFFFFFF010000000100000002000000FCFFFFFFFCFFFFFF04000000FCFFFFFF01000000FBFFFFFF0200000001000000F8FFFFFFFDFFFFFF0100000005000000FEFFFFFF00000000FCFFFFFFFFFFFFFF060000000100000000000000FEFFFFFF0300000001000000"> : tensor<1x125xi32>
    return %0 : tensor<1x125xi32>
  }
}

