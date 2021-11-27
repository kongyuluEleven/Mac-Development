//
//  Binary+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

public extension BinaryFloatingPoint {
    func rounded(
        toDecimalPlaces decimalPlaces: Int,
        rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero
    ) -> Self {
        guard decimalPlaces >= 0 else {
            return self
        }

        var divisor: Self = 1
        for _ in 0..<decimalPlaces { divisor *= 10 }

        return (self * divisor).rounded(rule) / divisor
    }
}
