use std::rc::Rc;
use colored::Colorize;
use tree_formatter::{PrettyTree, PrettyTreePrinter, ToPrettyTree};
use crate::text::{FatChar, Text};

#[derive(Debug, Clone)]
pub enum ControlFlow {
    NoOp,
    Terminate,
}

impl Default for ControlFlow {
    fn default() -> Self {
        ControlFlow::NoOp
    }
}

impl ToPrettyTree for ControlFlow {
    fn to_pretty_tree(&self) -> tree_formatter::PrettyTree {
        match self {
            ControlFlow::NoOp => PrettyTree::value("ControlFlow::NoOp"),
            ControlFlow::Terminate => PrettyTree::value("ControlFlow::Terminate"),
        }
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// SECTION NAME
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
#[derive(Clone)]
pub struct Parser<T> {
    pub(crate) binder: Rc<dyn Fn(State) -> Output<T>>
}

pub type TextParser = Parser<Text>;
pub type CharParser = Parser<FatChar>;
pub type TupleParser<A, B> = Parser<(A, B)>;
pub type TripleParser<A, B, C> = Parser<(A, B, C)>;
pub type QuadrupleParser<A, B, C, D> = Parser<(A, B, C, D)>;
pub type ControlFlowParser = Parser<ControlFlow>;

impl<T> Parser<T> {
    pub fn evaluate(source: impl AsRef<str>, parser: Self) -> (Option<T>, State) {
        let snippet = State {
            text: Text::initialize_from(source),
        };
        match (parser.binder)(snippet) {
            Output::Ok { value, state } => (Some(value), state),
            Output::Fail { state } => (None, state)
        }
    }
    pub(crate) fn i(f: impl Fn(State) -> Output<T> + 'static) -> Self {
        Self { binder: Rc::new(f) }
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// SECTION NAME
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
#[derive(Debug, Clone)]
pub struct State {
    pub text: Text,
}

impl State {
    pub(crate) fn ok<T>(self, value: T) -> Output<T> {
        Output::Ok { value, state: self }
    }
    pub(crate) fn fail<T>(self) -> Output<T> {
        Output::Fail { state: self }
    }
    pub(crate) fn set_text(&self, text: Text) -> Self {
        Self { text }
    }
}

impl ToPrettyTree for State {
    fn to_pretty_tree(&self) -> PrettyTree {
        PrettyTree::branch_of("State", vec![
            PrettyTree::key_value("text", &self.text)
        ])
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// SECTION NAME
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
#[derive(Debug, Clone)]
pub(crate) enum Output<T> {
    Ok { value: T, state: State},
    Fail { state: State },
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// SECTION NAME
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
impl<T> Parser<T> where T: Clone + 'static {
    pub fn pure(value: T) -> Self {
        Self::i(move |s| s.ok(value.clone()))
    }
}

impl<A> Parser<A> where A: Clone + 'static {
    pub fn and_then<B>(self, right: impl Fn(A) -> Parser<B> + 'static) -> Parser<B> where B: Clone + 'static {
        let left = self.binder.clone();
        Parser::<B>::i(move |s1| {
            match left(s1) {
                Output::Ok { value: t, state: s2 } => (right(t).binder)(s2),
                Output::Fail { state } => state.fail()
            }
        })
    }
    pub fn map<B>(self, right: impl Fn(A) -> B + 'static) -> Parser<B> where B: Clone + 'static {
        self.and_then(move |t| {
            Parser::<B>::pure(right(t))
        })
    }
    pub fn and<B>(self, next: Parser<B>) -> TupleParser<A, B> where B: 'static + Clone {
        TupleParser::<A, B>::i(move |state| {
            match (self.binder)(state) {
                Output::Ok { value: t, state } => {
                    match (next.binder)(state) {
                        Output::Ok { value: u, state } => {
                            return state.ok((t, u))
                        }
                        Output::Fail { state } => state.fail()
                    }
                }
                Output::Fail { state } => state.fail()
            }
        })
    }
    pub fn and2<B, C>(
        self,
        f: Parser<B>,
        g: Parser<C>
    ) -> TripleParser<A, B, C> where B: Clone + 'static, C: Clone + 'static {
        self.and(f).and(g).map(|((a, b), c)| {
            (a, b, c)
        })
    }
    pub fn and3<B, C, D>(
        self,
        f: Parser<B>,
        g: Parser<C>,
        h: Parser<D>
    ) -> QuadrupleParser<A, B, C, D> where B: Clone + 'static, C: Clone + 'static, D: Clone + 'static {
        self.and2(f, g).and(h).map(|((a, b, c), d)| {
            (a, b, c, d)
        })
    }
}

impl CharParser {
    pub fn next() -> Self {
        Self::i(|state| {
            match state.text.uncons() {
                Some((l, r)) => {
                    state.set_text(r).ok(l)
                }
                None => state.fail()
            }
        })
    }
    pub fn char(value: char) -> Self {
        Self::i(move |state| {
            match state.text.uncons() {
                Some((l, r)) if l.value == value => {
                    state.set_text(r).ok(l)
                }
                _ => state.fail()
            }
        })
    }
    pub fn char_if(predicate: impl Fn(char) -> bool + 'static) -> Self {
        Self::i(move |state| {
            match state.text.uncons() {
                Some((l, r)) if predicate(l.value) => {
                    state.set_text(r).ok(l)
                }
                _ => state.fail()
            }
        })
    }
}

impl TextParser {
    pub fn token(value: impl ToString) -> Self {
        let value = value.to_string();
        Self::i(move |state| {
            match state.text.pop_prefix(&value) {
                Some((prefix, rest)) => state.set_text(rest).ok(prefix),
                None => state.fail()
            }
        })
    }
}

#[derive(Default)]
pub struct SequenceSettings {
    allow_empty: Option<bool>,
    until_terminator: Option<ControlFlowParser>,
}

impl SequenceSettings {
    pub fn allow_empty(mut self, flag: bool) -> Self {
        self.allow_empty = Some(flag);
        self
    }
    pub fn until_terminator(mut self, terminator: ControlFlowParser) -> Self {
        self.until_terminator = Some(terminator);
        self
    }
}

impl<A> Parser<A> where A: Clone + 'static {
    pub fn sequence(self, settings: SequenceSettings) -> Parser<Vec<A>> {
        Parser::<Vec<A>>::i(move |state| {
            let mut leading = Vec::<A>::default();
            let mut trailing: State = state.clone();
            'trials : while !trailing.text.is_empty() {
                if let Some(terminator) = settings.until_terminator.as_ref() {
                    match (terminator.binder.as_ref())(trailing.clone()) {
                        Output::Ok { value: ControlFlow::Terminate, state } => {
                            trailing = state;
                            break 'trials;
                        }
                        _ => ()
                    }
                }
                match (self.binder.as_ref())(trailing.clone()) {
                    Output::Ok { value, state } => {
                        trailing = state;
                        leading.push(value);
                        continue 'trials;
                    }
                    Output::Fail { .. } => break 'trials,
                }
            }
            if leading.is_empty() && !settings.allow_empty.unwrap_or(false) {
                return trailing.fail()
            }
            trailing.ok(leading)
        })
    }
    pub fn many(self) -> Parser<Vec<A>> {
        let settings = SequenceSettings::default().allow_empty(true);
        self.sequence(settings)
    }
    pub fn some(self) -> Parser<Vec<A>> {
        let settings = SequenceSettings::default().allow_empty(false);
        self.sequence(settings)
    }
    pub fn many_unless<B>(self, other: Parser<B>) -> Parser<(Vec<A>, Option<B>)> where B: 'static + Clone {
        let settings = SequenceSettings::default()
            .allow_empty(true)
            .until_terminator(ControlFlowParser::terminate_if_ok(&other));
        let parser = self.and(other);
        unimplemented!()
    }
    // pub fn some_unless(self) -> Parser<Vec<T>> {
    //     let settings = SequenceSettings::default().allow_empty(false);
    //     self.sequence(settings)
    // }
}

impl ControlFlowParser {
    pub fn terminate_if_ok<T>(parser: &Parser<T>) -> Self where T: 'static + Clone {
        let parser = parser.to_owned();
        Self::i(move |state| {
            match (parser.binder)(state.clone()) {
                Output::Ok { .. } => state.ok(ControlFlow::Terminate),
                Output::Fail { .. } => state.ok(ControlFlow::NoOp),
            }
        })
    }
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// SECTION NAME
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
pub fn dev() {
    let source = "Hello World";
    let parser = {
        let is_whitespace = CharParser::char_if(|x| x.is_whitespace());
        let settings = SequenceSettings::default()
            .allow_empty(false)
            .until_terminator(ControlFlowParser::terminate_if_ok(&is_whitespace));
        CharParser::next()
            .sequence(settings)
            .map(Text::from_iter)
    };
    let (output, state) = Parser::evaluate(source, parser);
    if let Some(output) = output {
        header("DONE");
        output.to_pretty_tree().print_pretty_tree();
    } else {
        header("ERROR!");
    }
    header("FINAL PARSER STATE");
    state.to_pretty_tree().print_pretty_tree();
}

pub fn header(value: impl AsRef<str>) {
    fn print_boxed_label(label: &str) {
        // - Calculate the length of the label -
        let length = label.chars().count();
        // - -
        let top_border    = format!("╭{}╮", "─".repeat(length + 2));
        let bottom_border = format!("╰{}╯", "─".repeat(length + 2));
        // - -
        let line1 = format!("{}", top_border).cyan();
        let line2 = format!("│ {} │", label).cyan();
        let line3 = format!("{}", bottom_border).cyan();
        // - -
        println!("{line1}");
        println!("{line2}");
        println!("{line3}");
    }
    print_boxed_label(value.as_ref())
}
