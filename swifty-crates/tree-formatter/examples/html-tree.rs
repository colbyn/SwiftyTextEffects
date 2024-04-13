use tree_formatter::{PrettyTree, PrettyTreePrinter, ToPrettyTree};

fn main() {
    let tree1 = HtmlTree::element("div", vec![
        HtmlTree::element("header", vec![
            HtmlTree::text("Hello World")
        ]),
        HtmlTree::element("main", vec![
            HtmlTree::element("article", vec![
                HtmlTree::element("section", vec![
                    HtmlTree::element("p", vec![ HtmlTree::text("Hello World") ]),
                ]),
                HtmlTree::element("section", vec![
                    HtmlTree::element("p", vec![ HtmlTree::text("Hello World") ]),
                ]),
                HtmlTree::element("section", vec![
                    HtmlTree::element("p", vec![ HtmlTree::text("Hello World") ]),
                ]),
                HtmlTree::element("section", vec![
                    HtmlTree::element("p", vec![ HtmlTree::text("Hello World") ]),
                ]),
            ]),
        ]),
        HtmlTree::element("footer", vec![
            HtmlTree::text("Hello World")
        ]),
    ]);
    tree1.print_pretty_tree();
}

#[derive(Debug, Clone)]
pub enum HtmlTree {
    Element { name: String, children: Vec<HtmlTree> },
    Text { value: String },
}

impl HtmlTree {
    pub fn text(str: impl AsRef<str>) -> Self {
        Self::Text { value: str.as_ref().to_owned() }
    }
    pub fn element(name: impl AsRef<str>, children: impl IntoIterator<Item = Self>) -> Self {
        Self::Element {
            name: name.as_ref().to_owned(),
            children: children.into_iter().collect(),
        }
    }
}

impl ToPrettyTree for HtmlTree {
    fn to_pretty_tree(&self) -> tree_formatter::PrettyTree {
        match self {
            HtmlTree::Element { name, children } => {
                let children = children
                    .iter()
                    .map(|x| x.to_pretty_tree())
                    .collect::<Vec<_>>();
                PrettyTree::branch_of(name, &children)
            }
            HtmlTree::Text { value } => {
                PrettyTree::str(value)
            }
        }
    }
}