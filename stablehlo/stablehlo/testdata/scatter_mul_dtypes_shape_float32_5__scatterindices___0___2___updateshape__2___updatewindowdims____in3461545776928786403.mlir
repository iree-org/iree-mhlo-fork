// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = stablehlo.constant dense<[[0], [2]]> : tensor<2x1xi32>
    %1:2 = call @inputs() : () -> (tensor<5xf32>, tensor<2xf32>)
    %2 = call @expected() : () -> tensor<5xf32>
    %3 = "stablehlo.scatter"(%1#0, %0, %1#1) ({
    ^bb0(%arg0: tensor<f32>, %arg1: tensor<f32>):
      %5 = stablehlo.multiply %arg0, %arg1 : tensor<f32>
      stablehlo.return %5 : tensor<f32>
    }) {scatter_dimension_numbers = #stablehlo.scatter<inserted_window_dims = [0], scatter_dims_to_operand_dims = [0], index_vector_dim = 1>} : (tensor<5xf32>, tensor<2x1xi32>, tensor<2xf32>) -> tensor<5xf32>
    %4 = stablehlo.custom_call @check.eq(%3, %2) : (tensor<5xf32>, tensor<5xf32>) -> tensor<i1>
    return %4 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<5xf32>, tensor<2xf32>) {
    %0 = stablehlo.constant dense<[2.28717399, 2.35309243, -0.677912354, -4.05427265, 4.16037416]> : tensor<5xf32>
    %1 = stablehlo.constant dense<[-0.849727332, 1.21457267]> : tensor<2xf32>
    return %0, %1 : tensor<5xf32>, tensor<2xf32>
  }
  func.func private @expected() -> tensor<5xf32> {
    %0 = stablehlo.constant dense<[-1.94347429, 2.35309243, -0.823373795, -4.05427265, 4.16037416]> : tensor<5xf32>
    return %0 : tensor<5xf32>
  }
}

