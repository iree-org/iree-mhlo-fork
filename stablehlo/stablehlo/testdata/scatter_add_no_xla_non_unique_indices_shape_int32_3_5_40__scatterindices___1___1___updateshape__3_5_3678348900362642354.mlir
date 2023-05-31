// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = stablehlo.constant dense<1> : tensor<2x1xi32>
    %1:2 = call @inputs() : () -> (tensor<3x5x40xi32>, tensor<3x5x2xi32>)
    %2 = call @expected() : () -> tensor<3x5x40xi32>
    %3 = "stablehlo.scatter"(%1#0, %0, %1#1) ({
    ^bb0(%arg0: tensor<i32>, %arg1: tensor<i32>):
      %5 = stablehlo.add %arg0, %arg1 : tensor<i32>
      stablehlo.return %5 : tensor<i32>
    }) {scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [0, 1], inserted_window_dims = [2], scatter_dims_to_operand_dims = [2], index_vector_dim = 1>} : (tensor<3x5x40xi32>, tensor<2x1xi32>, tensor<3x5x2xi32>) -> tensor<3x5x40xi32>
    %4 = stablehlo.custom_call @check.eq(%3, %2) : (tensor<3x5x40xi32>, tensor<3x5x40xi32>) -> tensor<i1>
    return %4 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<3x5x40xi32>, tensor<3x5x2xi32>) {
    %0 = stablehlo.constant dense<"0x0100000002000000000000000000000002000000010000000000000000000000FEFFFFFF00000000FBFFFFFF0100000004000000020000000000000001000000050000000200000000000000000000000100000000000000FDFFFFFFFAFFFFFFFCFFFFFFFDFFFFFFFBFFFFFF0300000001000000FFFFFFFF00000000010000000200000000000000010000000600000000000000FDFFFFFFFEFFFFFFFEFFFFFFFEFFFFFF0300000006000000FAFFFFFFFBFFFFFFFFFFFFFF0000000003000000010000000500000001000000FFFFFFFF05000000FFFFFFFFF9FFFFFF02000000FFFFFFFF01000000010000000100000002000000010000000000000000000000FFFFFFFF03000000FDFFFFFF01000000000000000100000002000000FAFFFFFFFCFFFFFFFDFFFFFFFFFFFFFF00000000FDFFFFFF05000000010000000500000005000000FEFFFFFF04000000060000000300000001000000FEFFFFFF0000000000000000FEFFFFFF02000000020000000200000000000000FDFFFFFFFFFFFFFF0100000004000000FAFFFFFFFFFFFFFFFEFFFFFF03000000FEFFFFFF00000000FDFFFFFFFFFFFFFF0100000000000000FDFFFFFF04000000FEFFFFFF03000000FDFFFFFF000000000000000004000000000000000100000001000000FEFFFFFFFEFFFFFFFDFFFFFFFFFFFFFF0300000004000000FFFFFFFF030000000000000001000000FFFFFFFF0000000003000000FEFFFFFFFDFFFFFF01000000FCFFFFFF03000000FCFFFFFF03000000FCFFFFFFFEFFFFFF03000000FEFFFFFFFDFFFFFF0300000000000000FFFFFFFF00000000010000000200000000000000FFFFFFFF0100000002000000040000000000000000000000000000000800000002000000FEFFFFFFFBFFFFFF02000000FCFFFFFF0200000003000000FEFFFFFF01000000040000000300000001000000FCFFFFFF00000000FDFFFFFFFDFFFFFFFFFFFFFF00000000FFFFFFFFFDFFFFFFFFFFFFFFFDFFFFFF01000000FFFFFFFFFDFFFFFFFDFFFFFF01000000010000000200000000000000FFFFFFFF00000000FFFFFFFF02000000FFFFFFFFFCFFFFFF0000000000000000FCFFFFFF000000000000000003000000FEFFFFFFFCFFFFFFFDFFFFFF01000000000000000000000002000000FDFFFFFF000000000000000003000000FFFFFFFF00000000000000000300000005000000FDFFFFFFFFFFFFFF000000000000000000000000FBFFFFFFF9FFFFFFFDFFFFFF0200000000000000FBFFFFFF0000000004000000FFFFFFFF010000000100000004000000000000000100000002000000FFFFFFFF05000000010000000000000000000000FEFFFFFF03000000FFFFFFFF00000000FEFFFFFF010000000100000000000000FEFFFFFF01000000FBFFFFFF00000000070000000200000002000000000000000200000000000000FFFFFFFF06000000FCFFFFFF02000000FBFFFFFF03000000FDFFFFFFFBFFFFFF00000000FBFFFFFF0000000001000000FBFFFFFFFFFFFFFF020000000200000004000000040000000100000000000000FFFFFFFF000000000000000000000000FDFFFFFF0200000002000000FEFFFFFF050000000000000001000000FBFFFFFF00000000FCFFFFFFFEFFFFFFFCFFFFFF020000000100000003000000FCFFFFFF02000000FEFFFFFFFAFFFFFFFDFFFFFF010000000500000000000000FFFFFFFFFEFFFFFF00000000FAFFFFFF00000000030000000000000006000000FEFFFFFF02000000FAFFFFFFFFFFFFFFFAFFFFFF000000000100000001000000000000000200000000000000FDFFFFFFFCFFFFFF0300000005000000FFFFFFFF00000000FEFFFFFFFFFFFFFF000000000000000002000000FEFFFFFF020000000000000000000000FEFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000FFFFFFFF0100000000000000FEFFFFFF07000000FFFFFFFF020000000200000001000000FFFFFFFF01000000FCFFFFFFFEFFFFFF00000000FFFFFFFF04000000FEFFFFFF0700000002000000FEFFFFFFFFFFFFFF00000000020000000000000000000000020000000000000005000000FDFFFFFF0200000003000000FDFFFFFF010000000000000005000000050000000200000004000000FDFFFFFF00000000FEFFFFFF0500000002000000FDFFFFFF06000000FEFFFFFFFFFFFFFFFEFFFFFF04000000FDFFFFFFFAFFFFFFFDFFFFFF0100000000000000FEFFFFFF04000000FEFFFFFFFEFFFFFF0000000000000000010000000100000003000000FBFFFFFFFCFFFFFF01000000FEFFFFFF02000000FFFFFFFFFFFFFFFFFFFFFFFF02000000000000000400000001000000FBFFFFFF03000000FAFFFFFF0300000000000000FCFFFFFF00000000FFFFFFFF01000000FFFFFFFFFDFFFFFF00000000FFFFFFFFFDFFFFFF0200000004000000FDFFFFFFFCFFFFFF02000000010000000000000001000000FBFFFFFF0400000004000000FFFFFFFF0000000004000000FFFFFFFF00000000FDFFFFFF01000000FDFFFFFF020000000000000001000000FFFFFFFF00000000FFFFFFFFFDFFFFFF00000000FFFFFFFF03000000FDFFFFFFFDFFFFFF0200000001000000FDFFFFFF0000000001000000FDFFFFFF0100000002000000FFFFFFFF03000000020000000700000000000000FFFFFFFFFCFFFFFF04000000FDFFFFFF000000000000000002000000F9FFFFFF0100000002000000010000000000000000000000FAFFFFFF0700000000000000FEFFFFFF0100000002000000FEFFFFFF02000000FDFFFFFF02000000020000000000000001000000010000000200000002000000000000000100000001000000000000000500000000000000020000000500000000000000040000000400000000000000FCFFFFFF00000000FFFFFFFFFCFFFFFF0000000000000000040000000300000000000000FFFFFFFF00000000000000000400000004000000050000000000000001000000FFFFFFFFFCFFFFFF000000000000000000000000FFFFFFFFFDFFFFFF0000000004000000FEFFFFFFFEFFFFFF000000000000000000000000FBFFFFFFFFFFFFFF0100000000000000FFFFFFFFFDFFFFFF0000000005000000FDFFFFFFFFFFFFFFFCFFFFFF00000000FFFFFFFFFEFFFFFF01000000000000000000000004000000000000000100000002000000FFFFFFFF03000000FFFFFFFF0400000000000000FCFFFFFFFFFFFFFF00000000FFFFFFFF0200000004000000FAFFFFFF00000000FEFFFFFF0000000000000000FFFFFFFF00000000070000000000000000000000000000000100000003000000FEFFFFFF00000000FFFFFFFF"> : tensor<3x5x40xi32>
    %1 = stablehlo.constant dense<[[[1, 0], [1, -2], [-2, 2], [3, 0], [-1, 5]], [[0, 0], [-5, 0], [0, -4], [1, -3], [6, 0]], [[6, 1], [1, 1], [-1, -1], [3, -3], [4, -2]]]> : tensor<3x5x2xi32>
    return %0, %1 : tensor<3x5x40xi32>, tensor<3x5x2xi32>
  }
  func.func private @expected() -> tensor<3x5x40xi32> {
    %0 = stablehlo.constant dense<"0x0100000003000000000000000000000002000000010000000000000000000000FEFFFFFF00000000FBFFFFFF0100000004000000020000000000000001000000050000000200000000000000000000000100000000000000FDFFFFFFFAFFFFFFFCFFFFFFFDFFFFFFFBFFFFFF0300000001000000FFFFFFFF00000000010000000200000000000000010000000600000000000000FDFFFFFFFEFFFFFFFEFFFFFFFEFFFFFF0200000006000000FAFFFFFFFBFFFFFFFFFFFFFF0000000003000000010000000500000001000000FFFFFFFF05000000FFFFFFFFF9FFFFFF02000000FFFFFFFF01000000010000000100000002000000010000000000000000000000FFFFFFFF03000000FDFFFFFF01000000000000000100000002000000FAFFFFFFFCFFFFFFFDFFFFFFFFFFFFFF00000000FDFFFFFF05000000010000000500000005000000FEFFFFFF04000000060000000300000001000000FEFFFFFF0000000000000000FEFFFFFF02000000020000000200000000000000FDFFFFFFFFFFFFFF0100000004000000FAFFFFFFFFFFFFFFFEFFFFFF03000000FEFFFFFF00000000FDFFFFFFFFFFFFFF0100000000000000FDFFFFFF04000000FEFFFFFF03000000FDFFFFFF000000000000000004000000000000000100000001000000FEFFFFFFFEFFFFFF00000000FFFFFFFF0300000004000000FFFFFFFF030000000000000001000000FFFFFFFF0000000003000000FEFFFFFFFDFFFFFF01000000FCFFFFFF03000000FCFFFFFF03000000FCFFFFFFFEFFFFFF03000000FEFFFFFFFDFFFFFF0300000000000000FFFFFFFF00000000010000000200000000000000FFFFFFFF0100000002000000040000000000000000000000000000000800000002000000FEFFFFFFFFFFFFFF02000000FCFFFFFF0200000003000000FEFFFFFF01000000040000000300000001000000FCFFFFFF00000000FDFFFFFFFDFFFFFFFFFFFFFF00000000FFFFFFFFFDFFFFFFFFFFFFFFFDFFFFFF01000000FFFFFFFFFDFFFFFFFDFFFFFF01000000010000000200000000000000FFFFFFFF00000000FFFFFFFF02000000FFFFFFFFFCFFFFFF0000000000000000FCFFFFFF000000000000000003000000FEFFFFFFFCFFFFFFFDFFFFFF01000000000000000000000002000000FDFFFFFF000000000000000003000000FFFFFFFF00000000000000000300000005000000FDFFFFFFFFFFFFFF000000000000000000000000FBFFFFFFF9FFFFFFFDFFFFFF0200000000000000FBFFFFFF0000000004000000FFFFFFFF010000000100000004000000000000000100000002000000FFFFFFFF050000000100000000000000FBFFFFFFFEFFFFFF03000000FFFFFFFF00000000FEFFFFFF010000000100000000000000FEFFFFFF01000000FBFFFFFF00000000070000000200000002000000000000000200000000000000FFFFFFFF06000000FCFFFFFF02000000FBFFFFFF03000000FDFFFFFFFBFFFFFF00000000FBFFFFFF0000000001000000FBFFFFFFFFFFFFFF020000000200000004000000040000000100000000000000FFFFFFFFFCFFFFFF0000000000000000FDFFFFFF0200000002000000FEFFFFFF050000000000000001000000FBFFFFFF00000000FCFFFFFFFEFFFFFFFCFFFFFF020000000100000003000000FCFFFFFF02000000FEFFFFFFFAFFFFFFFDFFFFFF010000000500000000000000FFFFFFFFFEFFFFFF00000000FAFFFFFF00000000030000000000000006000000FEFFFFFF02000000FAFFFFFFFFFFFFFFFAFFFFFF00000000FFFFFFFF01000000000000000200000000000000FDFFFFFFFCFFFFFF0300000005000000FFFFFFFF00000000FEFFFFFFFFFFFFFF000000000000000002000000FEFFFFFF020000000000000000000000FEFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000FFFFFFFF0100000000000000FEFFFFFF07000000FFFFFFFF020000000200000001000000FFFFFFFF01000000FCFFFFFFFEFFFFFF000000000500000004000000FEFFFFFF0700000002000000FEFFFFFFFFFFFFFF00000000020000000000000000000000020000000000000005000000FDFFFFFF0200000003000000FDFFFFFF010000000000000005000000050000000200000004000000FDFFFFFF00000000FEFFFFFF0500000002000000FDFFFFFF06000000FEFFFFFFFFFFFFFFFEFFFFFF04000000FDFFFFFFFAFFFFFFFDFFFFFF01000000000000000500000004000000FEFFFFFFFEFFFFFF0000000000000000010000000100000003000000FBFFFFFFFCFFFFFF01000000FEFFFFFF02000000FFFFFFFFFFFFFFFFFFFFFFFF02000000000000000400000001000000FBFFFFFF03000000FAFFFFFF0300000000000000FCFFFFFF00000000FFFFFFFF01000000FFFFFFFFFDFFFFFF00000000FFFFFFFFFDFFFFFF0200000004000000FDFFFFFFFCFFFFFF02000000030000000000000001000000FBFFFFFF0400000004000000FFFFFFFF0000000004000000FFFFFFFF00000000FDFFFFFF01000000FDFFFFFF020000000000000001000000FFFFFFFF00000000FFFFFFFFFDFFFFFF00000000FFFFFFFF03000000FDFFFFFFFDFFFFFF0200000001000000FDFFFFFF0000000001000000FDFFFFFF0100000002000000FFFFFFFF03000000020000000700000000000000FFFFFFFFFAFFFFFF04000000FDFFFFFF000000000000000002000000F9FFFFFF0100000002000000010000000000000000000000FAFFFFFF0700000000000000FEFFFFFF0100000002000000FEFFFFFF02000000FDFFFFFF02000000020000000000000001000000010000000200000002000000000000000100000001000000000000000500000000000000020000000500000000000000040000000400000000000000FCFFFFFF00000000FFFFFFFFFCFFFFFF0000000000000000040000000300000000000000FFFFFFFF00000000000000000400000004000000050000000000000001000000FFFFFFFFFCFFFFFF000000000000000000000000FFFFFFFFFDFFFFFF0000000004000000FEFFFFFFFEFFFFFF000000000000000000000000FBFFFFFFFFFFFFFF0100000000000000FFFFFFFFFDFFFFFF0000000005000000FDFFFFFF01000000FCFFFFFF00000000FFFFFFFFFEFFFFFF01000000000000000000000004000000000000000100000002000000FFFFFFFF03000000FFFFFFFF0400000000000000FCFFFFFFFFFFFFFF00000000FFFFFFFF0200000004000000FAFFFFFF00000000FEFFFFFF0000000000000000FFFFFFFF00000000070000000000000000000000000000000100000003000000FEFFFFFF00000000FFFFFFFF"> : tensor<3x5x40xi32>
    return %0 : tensor<3x5x40xi32>
  }
}

