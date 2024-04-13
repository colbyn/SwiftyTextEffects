use itertools::Itertools;
use unicode_segmentation::UnicodeSegmentation;
use std::rc::Rc;
use tree_formatter::{PrettyTree, ToPrettyTree};

pub type FatCharList = im_lists::list::List<FatChar>;

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// SECTION NAME
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
#[derive(Clone)]
pub struct Text {
    data: FatCharList
}

impl Text {
    pub fn initialize_from(source: impl AsRef<str>) -> Self {
        let source = source.as_ref().to_owned();
        Self {
            data: FatCharList::from_iter(to_fat_chars(&source)),
        }
    }
    pub fn from_iter(list: impl IntoIterator<Item=FatChar>) -> Self {
        Self {
            data: list.into_iter().collect()
        }
    }
    pub fn start(&self) -> Option<&FatChar> {
        self.data.first()
    }
    pub fn end(&self) -> Option<&FatChar> {
        self.data.last()
    }
    pub fn start_index(&self) -> Option<PositionIndex> {
        self.data.first().map(|x| x.index)
    }
    pub fn end_index(&self) -> Option<PositionIndex> {
        self.data.last().map(|x| x.index)
    }
    pub fn is_empty(&self) -> bool {
        self.data.is_empty()
    }
    pub fn has_prefix(&self, prefix: impl AsRef<str>) -> bool {
        let prefix = prefix.as_ref();
        let prefix_chars = prefix.chars().collect_vec();
        // - -
        if self.is_empty() && prefix.is_empty() {
            return true
        }
        if self.is_empty() || prefix.is_empty() {
            return false
        }
        if self.data.len() < prefix_chars.len() {
            return false
        }
        let is_match = self.data
            .iter()
            .zip(prefix_chars)
            .all(|(l, r)| {
                l.value == r
            });
        // - -
        return is_match
    }
    pub fn pop_prefix(&self, prefix: impl AsRef<str>) -> Option<(Self, Self)> {
        let prefix = prefix.as_ref();
        let prefix_len = prefix.chars().count();
        if !self.has_prefix(prefix) {
            return None
        }
        let leading = self.data.take(prefix_len);
        let trailing = self.data.tail(prefix_len)?;
        let is_valid = leading
            .iter()
            .zip(prefix.chars())
            .all(|(l, r)| {
                l.value == r
            });
        assert!(is_valid);
        let leading = self.set_data(leading);
        let trailing = self.set_data(trailing);
        Some((leading, trailing))
    }
    pub fn take(&self, count: usize) -> Option<(Self, Self)> {
        if self.data.len() < count {
            return None
        }
        let leading = self.set_data(
            self.data.take(count)
        );
        let trailing = self.set_data(
            self.data.tail(count)?
        );
        Some((leading, trailing))
    }
    pub fn uncons(&self) -> Option<(FatChar, Self)> {
        let mut copy = self.data.clone();
        let first = copy.pop_front()?;
        Some((first, self.set_data(copy)))
    }
    fn set_data(&self, data: FatCharList) -> Self {
        Self { data }
    }
}

impl std::fmt::Debug for Text {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f   .debug_tuple("Snippet")
            .field(&format!("{self}"))
            .finish()
    }
}
impl std::fmt::Display for Text {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let chars = self.data
            .iter()
            .map(|x| x.value)
            .collect::<String>();
        write!(f, "{chars}")
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// SECTION NAME
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
#[derive(Debug, Clone)]
pub struct FatChar {
    pub index: PositionIndex,
    pub value: char,
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// SECTION NAME
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
#[derive(Debug, Clone, Copy)]
pub struct PositionIndex {
    pub grapheme_offset: usize,
    pub scalar_offset: usize,
    pub byte_offset: usize,
    pub line_offset: usize,
    pub column_offset: usize,
}

impl PositionIndex {
    pub const ZERO: Self = PositionIndex {
        byte_offset: 0,
        scalar_offset: 0,
        grapheme_offset: 0,
        line_offset: 0,
        column_offset: 0,
    };
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// SECTION NAME
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
fn to_fat_chars(source: impl AsRef<str>) -> Vec<FatChar> {
    let mut leading_position = PositionIndex::ZERO;
    source
        .as_ref()
        .grapheme_indices(true)
        .flat_map(|(byte_offset, graphme)| {
            // - UPDATE LEADING STATE -
            let mut results: Vec<FatChar> = Vec::new();
            // - -
            leading_position.byte_offset = byte_offset;
            // - -
            for char in graphme.chars() {
                results.push(FatChar {
                    index: leading_position.clone(),
                    value: char
                });
                // - -
                leading_position.scalar_offset += 1;
                if char == '\n' {
                    leading_position.line_offset += 1;
                    leading_position.column_offset = 0;
                }
            }
            // - -
            leading_position.grapheme_offset += 1;
            leading_position.column_offset += 1;
            results
        })
        .collect_vec()
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// DEBUG
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
impl ToPrettyTree for FatChar {
    fn to_pretty_tree(&self) -> PrettyTree {
        PrettyTree::value(format!("{:?}", self.value))
    }
}
impl ToPrettyTree for Text {
    fn to_pretty_tree(&self) -> PrettyTree {
        PrettyTree::value(format!("{:?}", self.to_string()))
    }
}