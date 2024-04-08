# SwiftyParsec: A Powerful Parser Combinator Library for Swift (formerly called `MonadoParser`)

[![Swift Version](https://img.shields.io/badge/Swift-5.7-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

SwiftyParsec is a highly versatile and efficient parser combinator library for the Swift programming language. It provides a rich set of tools and combinators to help you build complex parsers easily and declaratively.

## Features

- **Composable**:
    + Build complex parsers from simple, reusable components.
    + SwiftyParsec's parser combinators allow you to build sophisticated parsers by composing smaller, reusable ones.
- **Monadic Interface**: Leverage the power of monads for chaining parsing operations in a declarative manner.
- **Rich State Management**: Track parsing progress and manage state effortlessly across parsing operations.
- **Error Handling**: Capture and handle parsing errors seamlessly, improving debuggability and reliability.
- **Position Tracking**: Annotate parsed characters with their positions for detailed error reporting and analysis.
- **Comprehensive type safety**: The library's type system helps you catch errors at compile-time, ensuring your parsers are type-safe and less prone to runtime errors.

## Getting Started

To use SwiftyParsec in your Swift project, you can either clone the repository and include the source files directly, or add it as a Swift Package dependency:

```swift
dependencies: [
    .package(
        url: "https://github.com/colbyn/SwiftyTextEffects.git",
        from: TODO // check git for the latest version 
    )
]
```

Once you've set up the dependency, you can start using the library in your code:

```swift
import SwiftyParsec

let parser = IO.TextParser
    .token("hello")
    .ignore(next: IO.TextParser.spaces)
    .and(next: IO.TextParser.token("world"))
let (result, unparsed) = parser.evaluate(source: "hello  world")
print(result.asPrettyTree.format())
```

## Documentation

Detailed documentation, including examples and usage guides, can be found in the [Documentation](/Documentation) directory.

### Parser Monad (`IO.Parser<A>`)

The heart of the framework, `IO.Parser<A>`, represents a parsing operation that can consume input and produce a result of type `A`. It encapsulates the logic for parsing tasks, allowing for easy composition and extension.

### Parser State (`IO.State`)

`IO.State` carries the current state of the parsing process ensuring that each parsing step is aware of its context.

### Text (`IO.Text`)

A recursive enumeration that models the input stream as a sequence of annotated characters. It supports efficient, non-destructive input consumption and provides detailed position information for each character.

### Utility Types

- Data Structures:
    + `IO.Either<Left, Right>`: Represents values with two possibilities, commonly used for error handling.
    + `IO.Tuple<A, B>`, `Triple<A, B, C>`, and `Quadruple<A, B, C, D>`: Facilitate grouping of multiple parsed values.
    + Plus Many More...
- Specialized parser typealiases (`IO.UnitParser`, `IO.TextParser`, `IO.CharParser`, etc.) for common parsing patterns.

## Contributing

We welcome contributions to the SwiftyParsec library! If you've found a bug, have a feature request, or would like to contribute code, please feel free to open an issue or submit a pull request.

## Conclusion

SwiftyParsec is a powerful and flexible parser combinator library that can help you tackle a wide range of text processing and data extraction tasks in your Swift projects. Whether you're building a domain-specific language, parsing configuration files, or extracting data from complex documents, SwiftyParsec provides the tools you need to get the job done efficiently and effectively.
