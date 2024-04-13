#![allow(unused)]

pub mod formatter;
use std::{collections::{BTreeMap, BTreeSet, HashMap, HashSet}, fmt::Display};

pub trait ToPrettyTree {
    fn to_pretty_tree(&self) -> PrettyTree;
}

pub trait PrettyTreePrinter {
    fn print_pretty_tree(&self);
}

impl<Type> PrettyTreePrinter for Type where Type: ToPrettyTree {
    fn print_pretty_tree(&self) {
        let tree = self.to_pretty_tree().format(&Default::default());
        println!("{tree}")
    }
}

#[derive(Debug, Clone)]
pub enum PrettyTree {
    Empty,
    /// A terminal leaf node.
    Value(String),
    /// A terminal leaf node.
    String(String),
    /// A branch node.
    Branch(PrettyBranch),
    /// A fragment node.
    Fragment(PrettyFragment),
}

impl PrettyTree {
    pub fn empty() -> Self { Self::Empty }
    pub fn value(value: impl ToString) -> Self {
        let value = value.to_string();
        Self::Value(format!("{value}"))
    }
    pub fn string<T: ToString>(value: T) -> Self {
        let value = value.to_string();
        Self::Value(format!("{value:?}"))
    }
    pub fn str(value: impl AsRef<str>) -> Self {
        let value = value.as_ref();
        Self::Value(format!("{value:?}"))
    }
    pub fn leaf(value: impl AsRef<str>) -> Self {
        Self::Value(value.as_ref().to_owned())
    }
    pub fn fragment<T: ToPrettyTree>(list: impl IntoIterator<Item = T>) -> Self {
        Self::Fragment(PrettyFragment { nodes: list.into_iter().map(|x| x.to_pretty_tree()).collect() })
    }
    pub fn branch_of<Type: ToPrettyTree>(
        label: impl AsRef<str>,
        children: impl IntoIterator<Item = Type>
    ) -> Self {
        Self::Branch(PrettyBranch {
            label: label.as_ref().to_string(),
            children: children.into_iter().map(|x| x.to_pretty_tree()).collect(),
        })
    }
    pub fn key_value(
        key: impl ToString,
        value: impl ToPrettyTree
    ) -> Self {
        let key = key.to_string();
        match value.to_pretty_tree() {
            PrettyTree::Value(text) => PrettyTree::Value(format!("{key}: {text}")),
            PrettyTree::String(text) => PrettyTree::Value(format!("{key}: {text:?}")),
            tree => {
                Self::Branch(PrettyBranch {
                    label: key,
                    children: vec![ tree ],
                })
            }
        }

    }
    pub fn some_value(value: impl Into<PrettyValue>) -> Self {
        Self::Value(value.into().text)
    }
    pub fn some_branch(branch: impl Into<PrettyBranch>) -> Self {
        Self::Branch(branch.into())
    }
    pub fn some_fragment(fragment: impl Into<PrettyFragment>) -> Self {
        Self::Fragment(fragment.into())
    }
}

impl Default for PrettyTree {
    fn default() -> Self { PrettyTree::Empty }
}

#[derive(Debug, Clone)]
pub struct PrettyValue {
    pub text: String
}

impl PrettyValue {
    pub fn from_str(value: impl AsRef<str>) -> Self {
        Self { text: value.as_ref().to_owned() }
    }
    pub fn from_string(value: impl ToString) -> Self {
        Self { text: value.to_string() }
    }
}

#[derive(Debug, Clone)]
pub struct PrettyBranch {
    pub label: String,
    pub children: Vec<PrettyTree>,
}

impl PrettyBranch {
    pub fn from_iter<Label: ToString, Child: ToPrettyTree>(
        label: Label,
        children: impl IntoIterator<Item = Child>
    ) -> Self {
        PrettyBranch {
            label: label.to_string(),
            children: children.into_iter().map(|x| x.to_pretty_tree()).collect(),
        }
    }
}

#[derive(Debug, Clone)]
pub struct PrettyFragment {
    pub nodes: Vec<PrettyTree>
}

impl PrettyFragment {
    pub fn from_iter<Value: ToPrettyTree>(list: impl IntoIterator<Item = Value>) -> Self {
        Self { nodes: list.into_iter().map(|x| x.to_pretty_tree()).collect() }
    }
}

impl ToPrettyTree for PrettyTree {
    fn to_pretty_tree(&self) -> PrettyTree { self.clone() }
}
impl ToPrettyTree for String {
    fn to_pretty_tree(&self) -> PrettyTree { PrettyTree::string(self) }
}
impl<T> ToPrettyTree for &T where T: ToPrettyTree {
    fn to_pretty_tree(&self) -> PrettyTree { (*self).to_pretty_tree() }
}
impl<Key, Value> ToPrettyTree for (Key, Value) where Key: ToString, Value: ToPrettyTree {
    fn to_pretty_tree(&self) -> PrettyTree {
        PrettyTree::branch_of(self.0.to_string(), &[ self.1.to_pretty_tree() ])
    }
}
impl<T: ToPrettyTree> ToPrettyTree for Vec<T> {
    fn to_pretty_tree(&self) -> PrettyTree {
        let name = std::any::type_name::<Self>();
        let children = self.iter().map(ToPrettyTree::to_pretty_tree).collect::<Vec<_>>();
        PrettyTree::branch_of(name, &children)
    }
}
impl<T: ToPrettyTree> ToPrettyTree for &[T] {
    fn to_pretty_tree(&self) -> PrettyTree {
        let name = std::any::type_name::<Self>();
        let children = self.iter().map(ToPrettyTree::to_pretty_tree).collect::<Vec<_>>();
        PrettyTree::branch_of(name, &children)
    }
}
impl<Key: ToString, Value: ToPrettyTree> ToPrettyTree for HashMap<Key, Value> {
    fn to_pretty_tree(&self) -> PrettyTree {
        let name = std::any::type_name::<Self>();
        let children = self
            .iter()
            .map(|(key, value)| {
                PrettyTree::branch_of(key.to_string(), &[ value.to_pretty_tree() ])
            })
            .collect::<Vec<_>>();
        PrettyTree::branch_of(name, &children)
    }
}
impl<Key: ToString, Value: ToPrettyTree> ToPrettyTree for BTreeMap<Key, Value> {
    fn to_pretty_tree(&self) -> PrettyTree {
        let name = std::any::type_name::<Self>();
        let children = self
            .iter()
            .map(|(key, value)| {
                PrettyTree::branch_of(key.to_string(), &[ value.to_pretty_tree() ])
            })
            .collect::<Vec<_>>();
        PrettyTree::branch_of(name, &children)
    }
}
impl<T: ToPrettyTree> ToPrettyTree for HashSet<T> {
    fn to_pretty_tree(&self) -> PrettyTree {
        let name = std::any::type_name::<Self>();
        let children = self.iter().map(ToPrettyTree::to_pretty_tree).collect::<Vec<_>>();
        PrettyTree::branch_of(name, &children)
    }
}
impl<T: ToPrettyTree> ToPrettyTree for BTreeSet<T> {
    fn to_pretty_tree(&self) -> PrettyTree {
        let name = std::any::type_name::<Self>();
        let children = self.iter().map(ToPrettyTree::to_pretty_tree).collect::<Vec<_>>();
        PrettyTree::branch_of(name, &children)
    }
}

#[cfg(feature = "serde_json")]
impl ToPrettyTree for serde_json::Value {
    fn to_pretty_tree(&self) -> PrettyTree {
        match self {
            Self::Null => PrettyTree::str("Null"),
            Self::Bool(x) => PrettyTree::string(format!("Bool({x})")),
            Self::Number(x) => PrettyTree::string(format!("Number({x})")),
            Self::String(x) => PrettyTree::string(format!("String({x})")),
            Self::Array(xs) => PrettyTree::some_branch(PrettyBranch::from_iter("Array", xs.clone())),
            Self::Object(xs) => PrettyTree::some_branch(PrettyBranch::from_iter("Object", xs)),
        }
    }
}

#[cfg(feature = "indexmap")]
impl<Key: ToString, Value: ToPrettyTree> ToPrettyTree for indexmap::IndexMap<Key, Value> {
    fn to_pretty_tree(&self) -> PrettyTree {
        let name = std::any::type_name::<Self>();
        let children = self
            .iter()
            .map(|(key, value)| (key.to_string(), value.to_pretty_tree()))
            .collect::<Vec<_>>();
        PrettyTree::branch_of(name, children)
    }
}

#[cfg(feature = "indexmap")]
impl<Type: ToPrettyTree> ToPrettyTree for indexmap::IndexSet<Type> {
    fn to_pretty_tree(&self) -> PrettyTree {
        let name = std::any::type_name::<Self>();
        let children = self
            .iter()
            .map(|x| x.to_pretty_tree())
            .collect::<Vec<_>>();
        PrettyTree::branch_of(name, children)
    }
}


