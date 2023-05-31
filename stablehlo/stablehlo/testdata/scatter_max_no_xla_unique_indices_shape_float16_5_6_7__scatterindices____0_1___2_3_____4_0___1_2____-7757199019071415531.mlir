// RUN: stablehlo-opt -inline %s | stablehlo-translate --interpret
// RUN: diff <(stablehlo-translate --serialize --target=current %s | stablehlo-translate --deserialize | stablehlo-opt) <(stablehlo-opt %s)

module @jit_testcase {
  func.func public @main() -> tensor<i1> {
    %0 = stablehlo.constant dense<[[[0, 1], [2, 3]], [[4, 0], [1, 2]]]> : tensor<2x2x2xi32>
    %1:2 = call @inputs() : () -> (tensor<5x6x7xf16>, tensor<5x2x2xf16>)
    %2 = call @expected() : () -> tensor<5x6x7xf16>
    %3 = "stablehlo.scatter"(%1#0, %0, %1#1) ({
    ^bb0(%arg0: tensor<f16>, %arg1: tensor<f16>):
      %5 = stablehlo.maximum %arg0, %arg1 : tensor<f16>
      stablehlo.return %5 : tensor<f16>
    }) {scatter_dimension_numbers = #stablehlo.scatter<update_window_dims = [0], inserted_window_dims = [1, 2], scatter_dims_to_operand_dims = [1, 2], index_vector_dim = 2>, unique_indices = true} : (tensor<5x6x7xf16>, tensor<2x2x2xi32>, tensor<5x2x2xf16>) -> tensor<5x6x7xf16>
    %4 = stablehlo.custom_call @check.eq(%3, %2) : (tensor<5x6x7xf16>, tensor<5x6x7xf16>) -> tensor<i1>
    return %4 : tensor<i1>
  }
  func.func private @inputs() -> (tensor<5x6x7xf16>, tensor<5x2x2xf16>) {
    %0 = stablehlo.constant dense<"0xD3BFCCC0AAC4AB441C3C143AA8C106C550C383C04140E2BE8A3E30BD4DC64EBA6CC295BBA6B9F6C4973C95BE524080C738BD41C1CDC26341E934C03DFEBA6642F2438B2BFD3CE4BCD6C593B9FEC1844412B5AF431AB52B430AC1EFC151B332BC46BA443D464111BC46B6BF3B36C183404AC6F3B98E2EE84380BF97C101433F44EEBE1237D9B73FBCCB429A36764139BA7D3C413578C6C6412F40923CF93F45B5A4C13BC4553FD1AF043B4F406542983DAE44184067BECFC10FC742B6F8BC6D40DCC0AB44AC3E32455F3DB29D00C12CC85642713C9537F74409C195C2BFBEE3C2113FCFAD422D34BB88AD91401A4503BF2A363C3FC23E0746383E7FC808C0DF3D134096405443D6BB4742D6378E42D439EB450DB9A136B63F63C396403B421E48A6C1EABA563E56C1BB427438E53E31C12C377EB9D83BD3C2FCAF8BC06C41F7369B421E44394082427241F13E23BCA64498C2E145B941CB35043D46C2C433E4BF4BB82ABA964384C225449FBC4D45AC3772C3FA4061C1FEBB74407EC14545BC374FBAA5B853BC0738983D4CB2474072BD28C319BE394508C0E8404B43813D8942F3B030C4"> : tensor<5x6x7xf16>
    %1 = stablehlo.constant dense<[[[4.417970e+00, 1.442380e+00], [-4.507810e+00, 3.208010e-01]], [[3.774410e-01, 1.614990e-01], [-2.236940e-02, 3.154300e+00]], [[7.104490e-01, -2.669920e+00], [3.869140e+00, -8.613280e-01]], [[3.435550e+00, -1.164550e-01], [-1.198240e+00, -7.099610e-01]], [[7.749020e-01, 2.197270e+00], [-2.333980e+00, -2.828130e+00]]]> : tensor<5x2x2xf16>
    return %0, %1 : tensor<5x6x7xf16>, tensor<5x2x2xf16>
  }
  func.func private @expected() -> tensor<5x6x7xf16> {
    %0 = stablehlo.constant dense<"0xD3BF6B44AAC4AB441C3C143AA8C106C550C322354140E2BE8A3E30BD4DC64EBA6CC2C53DA6B9F6C4973C95BE524080C738BD41C1CDC26341E934C03DFEBA6642F2438B2BFD3CE4BCD6C593B9FEC1844412B5AF431AB52B430AC1EFC151B332BC46BA443D46414F4246B6BF3B36C183404AC6F3B98E2EE84380BF97C101433F44EEBE1237D9B73FBCCB429A36764139BA7D3C413578C6C6412F40923CF93F45B5A4C13BC4553FD1AF043B4F406542983DAE44184067BECFC10FC742B6F8BC6D40DCC0AB44AC3E32455F3DB29D00C12CC85642713C9537F74409C195C2BFBEE3C2BD43CFAD422D34BB88AD91401A4503BF2A363C3FC23E0746383E7FC808C0DF42134096405443D6BB4742D6378E42D439EB450DB9A136B63F63C396403B421E48A6C1EABA563E56C1BB427438E53E31C12C377EB9D83BD3C2FCAF8BC06C41F7369B421E44394082427241F13E23BCA64498C2E145B941CB35043D46C2C433E4BF4BB82ABA964384C225449FBC4D45AC3772C3FA4061C1FEBB74407EC14545BC374FBAA5B853BC0738983D4CB2474072BD28C319BE394508C0E8404B43813D8942F3B030C4"> : tensor<5x6x7xf16>
    return %0 : tensor<5x6x7xf16>
  }
}

