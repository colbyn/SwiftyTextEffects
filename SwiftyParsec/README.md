# SwiftyParsec: A Powerful Parser Combinator Library for Swift

[![Swift Version](https://img.shields.io/badge/Swift-5.7-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

SwiftyParsec is a highly versatile and efficient parser combinator library for the Swift programming language. It provides a rich set of tools and combinators to help you build complex parsers easily and declaratively.

## Features

- **Expressive and composable**: SwiftyParsec's parser combinators allow you to build sophisticated parsers by composing smaller, reusable ones.
- **Efficient and performant**: The library is designed with performance in mind, ensuring your parsing tasks run quickly and without unnecessary overhead.
- **Robust error handling**: SwiftyParsec provides detailed error reporting and context, making it easier to debug and refine your parsers.
- **Comprehensive type safety**: The library's type system helps you catch errors at compile-time, ensuring your parsers are type-safe and less prone to runtime errors.
- **Extensive documentation**: The API is thoroughly documented, with examples and explanations to help you get started and master the library.

## Getting Started

To use SwiftyParsec in your Swift project, you can either clone the repository and include the source files directly, or add it as a Swift Package dependency:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/SwiftyParsec.git", from: "1.0.0")
]
```

Once you've set up the dependency, you can start using the library in your code:

```swift
import SwiftyParsec

let parser = SwiftyParsec.TextParser.token("hello").and(next: SwiftyParsec.TextParser.spaces).and(next: SwiftyParsec.TextParser.token("world"))
let result = parser.evaluate(source: "hello  world")
print(result) // Prints "(Optional(SwiftyParsec.Tuple(SwiftyParsec.Text(hello), SwiftyParsec.Text( world))), ParserState(...))"
```

## Documentation

Detailed documentation, including examples and usage guides, can be found in the [Documentation](/Documentation) directory.

## Contributing

We welcome contributions to the SwiftyParsec library! If you've found a bug, have a feature request, or would like to contribute code, please feel free to open an issue or submit a pull request.

## Conclusion

SwiftyParsec is a powerful and flexible parser combinator library that can help you tackle a wide range of text processing and data extraction tasks in your Swift projects. Whether you're building a domain-specific language, parsing configuration files, or extracting data from complex documents, SwiftyParsec provides the tools you need to get the job done efficiently and effectively.