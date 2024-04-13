#![allow(unused)]
// use tree_formatter::{DisplayTree, ToDisplayTree};

use tree_formatter::*;

#[derive(Debug, Clone)]
enum AstNode {
    BinaryOperation {
        operator: BinaryOperator,
        left: Box<AstNode>,
        right: Box<AstNode>,
    },
    UnaryOperation {
        operator: UnaryOperator,
        operand: Box<AstNode>,
    },
    Number(i32),
}

#[derive(Debug, Clone)]
enum BinaryOperator {
    Add,
    Subtract,
    Multiply,
    Divide,
}

#[derive(Debug, Clone)]
enum UnaryOperator {
    Negate,
}

impl ToPrettyTree for AstNode {
    fn to_pretty_tree(&self) -> PrettyTree {
        match self {
            AstNode::BinaryOperation { operator, left, right } => {
                let op_label = match operator {
                    BinaryOperator::Add => "Add",
                    BinaryOperator::Subtract => "Subtract",
                    BinaryOperator::Multiply => "Multiply",
                    BinaryOperator::Divide => "Divide",
                };
                PrettyTree::branch_of(
                    op_label,
                    &[
                        left.as_ref().to_pretty_tree(),
                        right.as_ref().to_pretty_tree(),
                    ],
                )
            }
            AstNode::UnaryOperation { operator, operand } => {
                let op_label = match operator {
                    UnaryOperator::Negate => "Negate",
                };
                PrettyTree::branch_of(op_label, &[operand.as_ref().to_pretty_tree()])
            }
            AstNode::Number(n) => PrettyTree::string(n.to_string()),
        }
    }
}

fn main() {
    // Simple number
    let simple_number = AstNode::Number(42);
    println!("Simple Number: 42");
    simple_number.print_pretty_tree();
    println!("--------------------------");

    // Simple unary operation: -(5)
    let simple_unary = AstNode::UnaryOperation {
        operator: UnaryOperator::Negate,
        operand: Box::new(AstNode::Number(5)),
    };
    println!("Simple Unary Operation: -(5)");
    simple_unary.print_pretty_tree();
    println!("--------------------------");

    // Simple binary operation: 7 + 3
    let simple_binary = AstNode::BinaryOperation {
        operator: BinaryOperator::Add,
        left: Box::new(AstNode::Number(7)),
        right: Box::new(AstNode::Number(3)),
    };
    println!("Simple Binary Operation: 7 + 3");
    simple_binary.print_pretty_tree();
    println!("--------------------------");

    // Nested operations: (1 + 2) * (3 - 4)
    let nested_binary = AstNode::BinaryOperation {
        operator: BinaryOperator::Multiply,
        left: Box::new(AstNode::BinaryOperation {
            operator: BinaryOperator::Add,
            left: Box::new(AstNode::Number(1)),
            right: Box::new(AstNode::Number(2)),
        }),
        right: Box::new(AstNode::BinaryOperation {
            operator: BinaryOperator::Subtract,
            left: Box::new(AstNode::Number(3)),
            right: Box::new(AstNode::Number(4)),
        }),
    };
    println!("Nested Operations: (1 + 2) * (3 - 4)");
    nested_binary.print_pretty_tree();
    println!("--------------------------");

    // Complex expression: -((5 + 3) * (10 - 2))
    let complex_expression = AstNode::UnaryOperation {
        operator: UnaryOperator::Negate,
        operand: Box::new(AstNode::BinaryOperation {
            operator: BinaryOperator::Multiply,
            left: Box::new(AstNode::BinaryOperation {
                operator: BinaryOperator::Add,
                left: Box::new(AstNode::Number(5)),
                right: Box::new(AstNode::Number(3)),
            }),
            right: Box::new(AstNode::BinaryOperation {
                operator: BinaryOperator::Subtract,
                left: Box::new(AstNode::Number(10)),
                right: Box::new(AstNode::Number(2)),
            }),
        }),
    };
    println!("Complex Expression: -((5 + 3) * (10 - 2))");
    complex_expression.print_pretty_tree();
    println!("--------------------------");

    // Deeply nested expression for testing the formatter: ((1 - (2 * 3)) + (4 / (5 + 6)))
    let deeply_nested = AstNode::BinaryOperation {
        operator: BinaryOperator::Add,
        left: Box::new(AstNode::BinaryOperation {
            operator: BinaryOperator::Subtract,
            left: Box::new(AstNode::Number(1)),
            right: Box::new(AstNode::BinaryOperation {
                operator: BinaryOperator::Multiply,
                left: Box::new(AstNode::Number(2)),
                right: Box::new(AstNode::Number(3)),
            }),
        }),
        right: Box::new(AstNode::BinaryOperation {
            operator: BinaryOperator::Divide,
            left: Box::new(AstNode::Number(4)),
            right: Box::new(AstNode::BinaryOperation {
                operator: BinaryOperator::Add,
                left: Box::new(AstNode::Number(5)),
                right: Box::new(AstNode::Number(6)),
            }),
        }),
    };
    println!("Deeply Nested Expression: ((1 - (2 * 3)) + (4 / (5 + 6)))");
    deeply_nested.print_pretty_tree();
}
