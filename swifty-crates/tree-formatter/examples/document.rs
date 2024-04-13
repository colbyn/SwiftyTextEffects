#![allow(unused)]
// use tree_formatter::{DisplayTree, ToDisplayTree};
use tree_formatter::*;

// fn main() {
//     println!("TODO")
// }

#[derive(Debug, Clone)]
struct DocumentSection {
    title: String,
    subsections: Vec<DocumentSection>,
}

impl DocumentSection {
    fn new(title: impl Into<String>, subsections: Vec<DocumentSection>) -> Self {
        Self {
            title: title.into(),
            subsections,
        }
    }
}

impl ToPrettyTree for DocumentSection {
    fn to_pretty_tree(&self) -> PrettyTree {
        let children = self.subsections
            .iter()
            .map(|x| x.to_pretty_tree())
            .collect::<Vec<_>>();
        if children.is_empty() {
            return PrettyTree::value(&self.title)
        }
        PrettyTree::branch_of( &self.title, &children )
    }
}


fn main() {
    let section = DocumentSection::new(
        "Chapter 1: Introduction",
        vec![
            DocumentSection::new("Section 1.1: Overview", vec![]),
            DocumentSection::new(
                "Section 1.2: Background",
                vec![
                    DocumentSection::new("Subsection 1.2.1: History", vec![]),
                    DocumentSection::new("Subsection 1.2.2: Motivation", vec![
                        DocumentSection::new("Subsection 1.2.2.1: The Need for Speed", vec![]),
                        DocumentSection::new("Subsection 1.2.2.2: Efficiency Matters", vec![]),
                    ]),
                ],
            ),
            DocumentSection::new(
                "Section 1.3: Objectives",
                vec![
                    DocumentSection::new("Subsection 1.3.1: Goal Setting", vec![]),
                    DocumentSection::new("Subsection 1.3.2: Scope", vec![]),
                ],
            ),
        ],
    );

    let section2 = DocumentSection::new(
        "Chapter 2: Methodology",
        vec![
            DocumentSection::new("Section 2.1: Research Design", vec![]),
            DocumentSection::new("Section 2.2: Data Collection", vec![
                DocumentSection::new("Subsection 2.2.1: Surveys", vec![]),
                DocumentSection::new("Subsection 2.2.2: Interviews", vec![]),
            ]),
            DocumentSection::new("Section 2.3: Analysis", vec![
                DocumentSection::new("Subsection 2.3.1: Qualitative Analysis", vec![]),
                DocumentSection::new("Subsection 2.3.2: Quantitative Analysis", vec![]),
            ]),
        ],
    );

    let section3 = DocumentSection::new(
        "Chapter 3: Results",
        vec![
            DocumentSection::new("Section 3.1: Overview of Findings", vec![]),
            DocumentSection::new("Section 3.2: Discussion", vec![
                DocumentSection::new("Subsection 3.2.1: Interpretation", vec![]),
                DocumentSection::new("Subsection 3.2.2: Limitations", vec![]),
            ]),
        ],
    );

    let final_document = DocumentSection::new(
        "Final Document",
        vec![section, section2, section3],
    );

    // Convert to a DisplayTree and pretty print
    final_document.print_pretty_tree();
}
