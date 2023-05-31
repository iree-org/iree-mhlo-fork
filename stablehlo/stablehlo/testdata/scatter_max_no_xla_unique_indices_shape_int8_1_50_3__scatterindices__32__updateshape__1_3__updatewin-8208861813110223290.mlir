// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = stablehlo.constant dense<32> : tensor<1xi32>
    %1:2 = call @inputs() : () -> (tensor<1x50x3xi8>, tensor<1x3xi8>)
    %2 = call @expected() : () -> tensor<1x50x3xi8>
    %3 = "stablehlo.scatter"(%1#0, %0, %1#1) ({
    ^bb0(%arg0: tensor<i8>, %arg1: tensor<i8>):
      %5 = stablehlo.maximum %arg0, %arg1 : tensor<i8>
      stablehlo.return %5 : tensor<i8>
    }) {scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [0, 1], inserted_window_dims = [1], scatter_dims_to_operand_dims = [1]>, unique_indices = true} : (tensor<1x50x3xi8>, tensor<1xi32>, tensor<1x3xi8>) -> tensor<1x50x3xi8>
    %4 = stablehlo.custom_call @check.eq(%3, %2) : (tensor<1x50x3xi8>, tensor<1x50x3xi8>) -> tensor<i1>
    return %4 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<1x50x3xi8>, tensor<1x3xi8>) {
    %0 = stablehlo.constant dense<"0xFCFFFCFE000000FF01000001000003FD00FCFD0403FE00000400FFFF050106FF02F8FF0101000000FCFE040503FDFC000101FB04FB0400020101FF01FF03FBF9000000FE030300030300FEFF01FF02FD0301000100000402FEFEFD0106020000FFFCFDFDFF02FC0100FF0100FD00FDFE0202060300FD0002FD020000030000FC0005FAFAFDFDFC01FF04FCFC0004FC00020203030000"> : tensor<1x50x3xi8>
    %1 = stablehlo.constant dense<[[0, 0, -3]]> : tensor<1x3xi8>
    return %0, %1 : tensor<1x50x3xi8>, tensor<1x3xi8>
  }
  func.func private @expected() -> tensor<1x50x3xi8> {
    %0 = stablehlo.constant dense<"0xFCFFFCFE000000FF01000001000003FD00FCFD0403FE00000400FFFF050106FF02F8FF0101000000FCFE040503FDFC000101FB04FB0400020101FF01FF03FBF9000000FE030300030300FEFF01FF02FD0301000100000402FEFEFD01060200000000FDFDFF02FC0100FF0100FD00FDFE0202060300FD0002FD020000030000FC0005FAFAFDFDFC01FF04FCFC0004FC00020203030000"> : tensor<1x50x3xi8>
    return %0 : tensor<1x50x3xi8>
  }
}

