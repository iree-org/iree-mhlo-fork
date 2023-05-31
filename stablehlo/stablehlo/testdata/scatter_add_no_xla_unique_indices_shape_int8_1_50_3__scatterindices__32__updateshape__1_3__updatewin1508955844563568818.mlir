// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = stablehlo.constant dense<32> : tensor<1xi32>
    %1:2 = call @inputs() : () -> (tensor<1x50x3xi8>, tensor<1x3xi8>)
    %2 = call @expected() : () -> tensor<1x50x3xi8>
    %3 = "stablehlo.scatter"(%1#0, %0, %1#1) ({
    ^bb0(%arg0: tensor<i8>, %arg1: tensor<i8>):
      %5 = stablehlo.add %arg0, %arg1 : tensor<i8>
      stablehlo.return %5 : tensor<i8>
    }) {scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [0, 1], inserted_window_dims = [1], scatter_dims_to_operand_dims = [1]>, unique_indices = true} : (tensor<1x50x3xi8>, tensor<1xi32>, tensor<1x3xi8>) -> tensor<1x50x3xi8>
    %4 = stablehlo.custom_call @check.eq(%3, %2) : (tensor<1x50x3xi8>, tensor<1x50x3xi8>) -> tensor<i1>
    return %4 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<1x50x3xi8>, tensor<1x3xi8>) {
    %0 = stablehlo.constant dense<"0xFE010001000503FE07010003FEFF02010003FD0000FB0000FF05FFFFFC000303FF03FFFFFF0000FF0301FE0101FB00030101FF030204FE00FB00FF020000FFFF00FEFF01F9010503FE04FCFDFFFD0404FFFAF9000305030101010504FDF9FEFEFD0202FF02FD01FEFDFF010002FFF805FD00010101FF040302FD03FD00FF02FE01FD02FC0200000304FF0100010000FD060002040001"> : tensor<1x50x3xi8>
    %1 = stablehlo.constant dense<[[3, -2, 0]]> : tensor<1x3xi8>
    return %0, %1 : tensor<1x50x3xi8>, tensor<1x3xi8>
  }
  func.func private @expected() -> tensor<1x50x3xi8> {
    %0 = stablehlo.constant dense<"0xFE010001000503FE07010003FEFF02010003FD0000FB0000FF05FFFFFC000303FF03FFFFFF0000FF0301FE0101FB00030101FF030204FE00FB00FF020000FFFF00FEFF01F9010503FE04FCFDFFFD0404FFFAF9000305030101010504FDF9FEFE000002FF02FD01FEFDFF010002FFF805FD00010101FF040302FD03FD00FF02FE01FD02FC0200000304FF0100010000FD060002040001"> : tensor<1x50x3xi8>
    return %0 : tensor<1x50x3xi8>
  }
}

