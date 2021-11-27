//
//  Optional+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

// MARK: - Methods

public extension Optional {
    /// 获取self的默认值(如果self是nil)。
    ///
    ///        let foo: String? = nil
    ///        print(foo.unwrapped(or: "bar")) -> "bar"
    ///
    ///        let bar: String? = "bar"
    ///        print(bar.unwrapped(or: "foo")) -> "bar"
    ///
    /// - Parameter defaultValue: 如果self是nil则返回默认值。
    /// - Returns: self if非nil, default value if nil。
    func unwrapped(or defaultValue: Wrapped) -> Wrapped {
        // http://www.russbishop.net/improving-optionals
        return self ?? defaultValue
    }

    /// 获取可选对象的包装值。如果可选参数是' nil '，抛出一个自定义错误。
    ///
    ///        let foo: String? = nil
    ///        try print(foo.unwrapped(or: MyError.notFound)) -> error: MyError.notFound
    ///
    ///        let bar: String? = "bar"
    ///        try print(bar.unwrapped(or: MyError.notFound)) -> "bar"
    ///
    /// - Parameter error: 如果可选对象是' nil '，抛出的错误。
    /// - Returns: 由可选参数包装的值。
    /// - Throws: 传入的错误。
    func unwrapped(or error: Error) throws -> Wrapped {
        guard let wrapped = self else { throw error }
        return wrapped
    }

    /// 运行一个块，如果不是nil，则对其进行包装
    ///
    ///        let foo: String? = nil
    ///        foo.run { unwrappedFoo in
    ///            // block will never run sice foo is nill
    ///            print(unwrappedFoo)
    ///        }
    ///
    ///        let bar: String? = "bar"
    ///        bar.run { unwrappedBar in
    ///            // block will run sice bar is not nill
    ///            print(unwrappedBar) -> "bar"
    ///        }
    ///
    /// - Parameter block: 一个要运行的block，如果self不是nil。
    func run(_ block: (Wrapped) -> Void) {
        // http://www.russbishop.net/improving-optionals
        _ = map(block)
    }

    /// 只有当变量的值不为空时，才给变量赋值。
    ///
    ///     let someParameter: String? = nil
    ///     let parameters = [String: Any]() // 附加到GET请求的一些参数
    ///     parameters[someKey] ??= someParameter // 它不会被添加到dict参数中
    ///
    /// - Parameters:
    ///   - lhs: Any?
    ///   - rhs: Any?
    static func ??= (lhs: inout Optional, rhs: Optional) {
        guard let rhs = rhs else { return }
        lhs = rhs
    }

    /// 只有当变量为空时，才为变量赋值。
    ///
    ///     var someText: String? = nil
    ///     let newText = "Foo"
    ///     let defaultText = "Bar"
    ///     someText ?= newText // someText现在是Foo，因为它之前是nil
    ///     someText ?= defaultText // someText不会改变它的值，因为它不是nil
    ///
    /// - Parameters:
    ///   - lhs: Any?
    ///   - rhs: Any?
    static func ?= (lhs: inout Optional, rhs: @autoclosure () -> Optional) {
        if lhs == nil {
            lhs = rhs()
        }
    }
}

// MARK: - Methods (Collection)

public extension Optional where Wrapped: Collection {
    /// 检查可选集合是nil还是空集合。
    var isNilOrEmpty: Bool {
        guard let collection = self else { return true }
        return collection.isEmpty
    }

    /// 仅当集合非null且非空时才返回集合。
    var nonEmpty: Wrapped? {
        guard let collection = self else { return nil }
        guard !collection.isEmpty else { return nil }
        return collection
    }
}

// MARK: - Methods (RawRepresentable, RawValue: Equatable)

public extension Optional where Wrapped: RawRepresentable, Wrapped.RawValue: Equatable {

    /// 返回一个布尔值，该值指示两个值是否相等。
    ///
    /// 等式是不等式的反义词。对于任意值a和b，
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: 要比较的值。
    ///   - rhs: 另一个比较值。
    @inlinable static func == (lhs: Optional, rhs: Wrapped.RawValue?) -> Bool {
        return lhs?.rawValue == rhs
    }

    /// 返回一个布尔值，该值指示两个值是否相等。
    ///
    /// 等式是不等式的反义词。对于任意值a和b，
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: 要比较的值。
    ///   - rhs: 另一个比较值。
    @inlinable static func == (lhs: Wrapped.RawValue?, rhs: Optional) -> Bool {
        return lhs == rhs?.rawValue
    }

    /// 返回一个布尔值，指示两个值是否不相等。
    ///
    /// 不等式是等式的反义词。对于任意值a和b，
    /// `a != b` implies that `a == b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: 要比较的值。
    ///   - rhs: 另一个比较值。
    @inlinable static func != (lhs: Optional, rhs: Wrapped.RawValue?) -> Bool {
        return lhs?.rawValue != rhs
    }

    /// 返回一个布尔值，指示两个值是否不相等。
    ///
    /// 不等式是等式的反义词。对于任意值a和b，
    /// `a != b` implies that `a == b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: 要比较的值。
    ///   - rhs: 另一个比较值。
    @inlinable static func != (lhs: Wrapped.RawValue?, rhs: Optional) -> Bool {
        return lhs != rhs?.rawValue
    }

}

// MARK: - Operators

infix operator ??=: AssignmentPrecedence
infix operator ?=: AssignmentPrecedence

