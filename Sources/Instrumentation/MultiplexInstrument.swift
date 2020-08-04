//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Distributed Tracing open source project
//
// Copyright (c) 2020 Moritz Lang and the Swift Tracing project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Baggage

/// A pseudo-`Instrument` that may be used to instrument using multiple other `Instrument`s across a
/// common `BaggageContext`.
public struct MultiplexInstrument {
    private var instruments: [Instrument]

    /// Create a `MultiplexInstrument`.
    ///
    /// - Parameter instruments: An array of `Instrument`s, each of which will be used to `inject`/`extract`
    /// through the same `BaggageContext`.
    public init(_ instruments: [Instrument]) {
        self.instruments = instruments
    }
}

extension MultiplexInstrument {
    func firstInstrument(where predicate: (Instrument) -> Bool) -> Instrument? {
        self.instruments.first(where: predicate)
    }
}

extension MultiplexInstrument: Instrument {
    public func inject<Carrier, Injector>(
        _ context: BaggageContext, into carrier: inout Carrier, using injector: Injector
    )
        where
        Injector: InjectorProtocol,
        Carrier == Injector.Carrier {
        self.instruments.forEach { $0.inject(context, into: &carrier, using: injector) }
    }

    public func extract<Carrier, Extractor>(
        _ carrier: Carrier, into context: inout BaggageContext, using extractor: Extractor
    )
        where
        Carrier == Extractor.Carrier,
        Extractor: ExtractorProtocol {
        self.instruments.forEach { $0.extract(carrier, into: &context, using: extractor) }
    }
}
