use crate::{PrettyBranch, PrettyFragment, PrettyTree, PrettyValue};
use colored::Colorize;

#[derive(Debug, Clone)]
pub struct Formatter {
    columns: Vec<TreeColumn>,
    use_color: bool,
}

impl Formatter {
    pub const COLUMN_LENGTH: usize = 4;
}
impl Default for Formatter {
    fn default() -> Self {
        Self {
            columns: Default::default(),
            use_color: true,
        }
    }
}

#[derive(Debug, Clone)]
pub(crate) enum TreeColumn {
    UpThenRight,
    VerticalBar,
    DownAndRight,
    DownThenRight,
    Empty,
}

impl std::fmt::Display for TreeColumn {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::UpThenRight => write!(f, "╭"),
            Self::VerticalBar => write!(f, "│"),
            Self::DownAndRight => write!(f, "├"),
            Self::DownThenRight => write!(f, "╰"),
            Self::Empty => write!(f, " ")
        }
    }
}

impl Formatter {
    fn down_then_right(&self) -> Self {
        let mut columns = self.columns
            .clone()
            .into_iter()
            .map(|x| match x {
                TreeColumn::DownAndRight => TreeColumn::VerticalBar,
                TreeColumn::DownThenRight => TreeColumn::Empty,
                x => x
            })
            .collect::<Vec<_>>();
        columns.push(TreeColumn::DownThenRight);
        Self { columns, use_color: self.use_color }
    }
    fn down_and_right(&self) -> Self {
        let mut columns = self.columns
            .clone()
            .into_iter()
            .map(|x| match x {
                TreeColumn::DownAndRight => TreeColumn::VerticalBar,
                TreeColumn::DownThenRight => TreeColumn::Empty,
                x => x
            })
            .collect::<Vec<_>>();
        columns.push(TreeColumn::DownAndRight);
        Self { columns, use_color: self.use_color }
    }
    fn with_column(&self, column: TreeColumn) -> Self {
        let mut columns = self.columns.clone();
        columns.push(column);
        Self { columns, use_color: self.use_color }
    }
    fn replace_last_column(mut self, column: TreeColumn) -> Self {
        if let Some(last) = self.columns.last_mut() {
            *last = column;
        }
        self
    }
    fn drop_last_column(mut self) -> Self {
        self.columns.pop();
        self
    }
    fn color(depth: usize, string: impl ToString) -> impl ToString {
        let string = string.to_string();
        match depth % 4 {
            0 => string.truecolor(255, 0, 0), // RED
            1 => string.truecolor(252, 255, 87), // YELLOW
            2 => string.truecolor(0, 255, 0), // GREEN
            _ => string.truecolor(102, 255, 252), // BLUE
        }
    }
    fn leading(&self) -> impl ToString {
        let depth = self.columns.len();
        let thin_space = "\u{2009}";
        let leading = self.columns
            .iter()
            .enumerate()
            .map(|(ix, c)| Self::color(ix, c).to_string())
            .collect::<Vec<_>>()
            .join("  ");
        let sep = if self.columns.is_empty() {
            String::default()
        } else {
            let depth = if depth > 1 { depth - 1 } else { 0 };
            Self::color(depth, format!("╼{thin_space}")).to_string()
        };
        format!("{leading}{sep}")
    }
    fn leaf(&self, value: impl ToString) -> String {
        let value = value.to_string();
        let depth = self.columns.len();
        let leading = self.leading().to_string();
        let trailing = Self::color(depth, value.bold()).to_string();
        format!("{leading}{trailing}")
    }
    fn branch(&self, label: impl ToString, children: &[PrettyTree]) -> String {
        let label = self.leaf(label);
        if children.is_empty() {
            return label
        }
        if children.len() == 1 {
            let child = children
                .first()
                .unwrap()
                .format(&self.down_then_right());
            return format!("{label}\n{child}")
        }
        let child_count = children.len();
        let last_child_index = child_count - 1;
        let children = children
            .iter()
            .enumerate()
            .map(|(ix, child)| {
                let is_first = ix == 0;
                let is_last = ix == last_child_index;
                if is_first {
                    return child.format(&self.down_and_right())
                }
                if is_last {
                    return child.format(&self.down_then_right())
                }
                return child.format(&self.down_and_right())
            })
            .collect::<Vec<_>>()
            .join("\n");
        format!("{label}\n{children}")
    }
    fn fragment(&self, list: &[PrettyTree]) -> String {
        self.branch("[]", list)
    }
}

impl PrettyTree {
    pub fn format(&self, formatter: &Formatter) -> String {
        match self {
            Self::Empty => String::default(),
            Self::Value(x) => formatter.leaf(x),
            Self::String(x) => formatter.leaf("{x:?}"),
            Self::Branch(x) => x.format(formatter),
            Self::Fragment(x) => x.format(formatter),
        }
    }
}
impl PrettyValue {
    pub fn format(&self, formatter: &Formatter) -> String {
        formatter.leaf(&self.text)
    }
}
impl PrettyBranch {
    pub fn format(&self, formatter: &Formatter) -> String {
        formatter.branch(&self.label, &self.children)
    }
}
impl PrettyFragment {
    pub fn format(&self, formatter: &Formatter) -> String {
        formatter.fragment(&self.nodes)
    }
}
impl std::fmt::Display for PrettyTree {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.format(&Default::default()))
    }
}