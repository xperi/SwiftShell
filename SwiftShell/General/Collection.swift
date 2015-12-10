/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
*/

public struct LazySplitSequence <Base: CollectionType where Base.Generator.Element: Equatable, Base.SubSequence: CollectionType,
	Base.SubSequence.Generator.Element==Base.Generator.Element, Base.SubSequence==Base.SubSequence.SubSequence>: GeneratorType, LazySequenceType {

	private var remaining: Base.SubSequence?
	private let separator: Base.Generator.Element
	private let allowEmptySlices: Bool

	public init (base: Base, separator: Base.Generator.Element, allowEmptySlices: Bool = false) {
		self.separator = separator
		self.remaining = base[base.startIndex..<base.endIndex]
		self.allowEmptySlices = allowEmptySlices
	}

	public mutating func next() -> Base.SubSequence? {
		guard let remaining = self.remaining else { return nil }
		let (head,tail) = remaining.splitOnce(separator, allowEmptySlices: allowEmptySlices)
		self.remaining = tail
		return head
	}

	public func generate() -> LazySplitSequence { return self }
}

extension CollectionType where Generator.Element: Equatable, SubSequence: CollectionType, SubSequence.Generator.Element==Generator.Element, SubSequence==SubSequence.SubSequence {

	public func splitOnce (separator: Generator.Element, allowEmptySlices: Bool = false) -> (head: SubSequence, tail: SubSequence?) {
		guard let nextindex = indexOf(separator) else { return (self[startIndex..<endIndex], nil) }
		let head = self[startIndex..<nextindex]
		let tail = self[nextindex.successor()..<endIndex]
		if !allowEmptySlices && head.isEmpty { return tail.splitOnce(separator, allowEmptySlices: false) }
		return (head, tail.isEmpty && !allowEmptySlices ? nil : tail)
	}
}

extension LazyCollectionType where Elements.Generator.Element: Equatable, Elements.SubSequence: CollectionType, Elements.SubSequence.Generator.Element==Elements.Generator.Element, Elements.SubSequence==Elements.SubSequence.SubSequence {

	public func split (separator: Self.Elements.Generator.Element, allowEmptySlices: Bool = false) -> LazySplitSequence<Self.Elements> {
		 return LazySplitSequence(base: self.elements, separator: separator, allowEmptySlices: allowEmptySlices)
	}
}
