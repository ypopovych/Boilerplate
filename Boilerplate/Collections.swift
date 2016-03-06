//===--- Collections.swift ------------------------------------------------------===//
//Copyright (c) 2016 Daniel Leping (dileping)
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.
//===----------------------------------------------------------------------===//

import Foundation

public protocol CopyableCollectionType : CollectionType {
    init<C : SequenceType where C.Generator.Element == Generator.Element>(_ s:C)
}

extension Array : CopyableCollectionType {
}

extension Set : CopyableCollectionType {
}

public extension CopyableCollectionType {
    public typealias EnumeratorCallback = (Generator.Element) -> Void
    public typealias Enumerator = (EnumeratorCallback) -> Void
    
    public init(enumerator:Enumerator) {
        var array = Array<Generator.Element>()
        enumerator { element in
            array.append(element)
        }
        self.init(array)
    }
}

public class ZippedSequence<A, B where A : GeneratorType, B : GeneratorType> : SequenceType {
    public typealias Generator = AnyGenerator<(A.Element, B.Element)>
    
    var ag:A
    var bg:B
    
    public init(ag:A, bg:B) {
        self.ag = ag
        self.bg = bg
    }
    
    public func generate() -> Generator {
        return anyGenerator {
            guard let a = self.ag.next() else {
                return nil
            }
            guard let b = self.bg.next() else {
                return nil
            }
            
            return (a, b)
        }
    }
}

public extension SequenceType {
    public func zip<T : SequenceType>(other:T) -> ZippedSequence<Generator, T.Generator> {
        return ZippedSequence(ag: self.generate(), bg: other.generate())
    }
}