# The Neorg 0.1 Specification
~~Yes I know it's ironic to have this file in markdown.~~

This file details all of the rules, concepts and design choices that went into creating the first true
iteration of the Neorg File Format version 0.1. Note that this version is still not final and may undergo
some small changes.

### Table of Contents
- [Theory](#theory)
- [Design decisions](#design-decisions)
    - [Parsing order](#parsing-order)
    - [Attached Modifiers and Their Functions](#attached-modifiers-and-their-functions)
    - [Detached Modifiers and Their Functions](#detached-modifiers-and-their-functions)
    - [Trailing modifiers](#trailing-modifiers)
    - [Escaping special characters](#escaping-special-characters)
    - [Defining data](#defining-data)
        - [Tag parameters](#tag-parameters)
        - [Carryover tags](#carryover-tags)
            - [Quirks](#quirks)
    - [Single-line paragraphs](#single-line-paragraphs)
    - [Intersecting modifiers](#intersecting-modifiers)
    - [Lists](#lists)
    - [Nesting](#nesting)
    - [TODO Lists](#todo-lists)
    - [Links](#links)
        - [The first segment](#the-first-segment)
        - [The second segment](#the-second-segment)
    - [Anchors](#anchors)
    - [Markers](#markers)
- [Data tags](#data-tags)
    - [Unsupported tags](#unsupported-tags)

# Theory
There are a few concepts that must be grasped in order to flawlessly interpret the specification, they
will be defined here.
- Paragraphs - paragraphs are portions of the file that simply represent text. Paragraphs only terminate
whenever two consecutive newlines are encountered, or whenever a paragraph-breaking `detached modifier` is encountered on the next line, *or*
if the current paragraph was a single-line paragraph.
More information about modifiers and detached modifiers can be found below.
- Punctuation - punctuation is any character that controls the intonation, flow or meaning of a sentence. Additional
punctuation marks are those that represent e.g. currencies. Currently punctuation is defined as `?!:;,.<>()[]{}'"/#%&$£€-`,
where each individual character denotes a valid punctuation mark. This list will grow with newer specifications.
- Modifiers - modifiers are characters or sequences of characters that change the way a segment of text **within a paragraph** is displayed.
This can be the `*` modifier, which makes some text bold, the `/` modifier, which makes text italic, and so on. Every modifier
must form a pair, where the first modifier `*in this text*` is the _opening modifier_, and the second (last) modifier is the
_closing modifier_. Modifiers that do not form a pair are called detached modifiers, and have a different set of rules. Here are
the rules for regular (attached) modifiers:
    - An opening modifier may only be preceded by whitespace or by a punctuation mark, and may be followed by another modifier or by
      an alphanumeric character. An opening modifier cannot have whitespace after itself.
    - A closing modifier may only be preceded with an alphanumeric character or by a modifier and may only be followed by whitespace
      or by a punctuation mark.
- Detached modifiers - detached modifiers, similarly to regular modifiers, are characters that modify the behaviour of Neorg. However,
  rather than changing the way text is displayed, they change the way text is interpreted. Detached modifiers do not consist of an opening and closing modifier, but only of one single character,
  hence the name "detached". Such a modifier can be the `*` modifier, signalling a heading, or the `-` modifier, signalling an unordered list.
  The rules for detached modifiers are as follows:
    - A detached modifier may exist at the very beginning of a line and may only be preceded by whitespace.
      It must have at least one character of whitespace or another detached modifier of the same type afterwards.
- Trailing modifiers - trailing modifiers are those that exist at the end of a line, and impact how the next line should be interpreted. Trailing modifiers have a very
  few simple rules, and they are:
    - A trailing modifier may only exist at the end of a line, and may not have any characters after itself.
    - A trailing modifier may have either a punctuation mark or an alphanumeric character before itself but **not** whitespace.
  Currently there is only one trailing modifier, and it is `~`. Its meaning will be discussed later on.
- Delimiting modifiers - delimiting modifiers are those that delimit one paragraph from another and change where the paragraph
  resides in the syntax tree. A delimiting modifier must exist at the beginning of a line (with optional whitespace beforehand), must consist of *at least* 3 consecutive modifiers
  of the same type and must *not* be followed by any extra characters (this includes whitespace but excludes a newline).

### Examples:

Considering the above rules, we can say that for regular modifiers:
- `* Something cool *` - INVALID, first modifier has a whitespace character afterwards and closing modifier has whitespace before itself
- `*Something cool*` - VALID
- `* Something cool*` - INVALID
- `*_Something cool_*` - VALID
- `*_Something cool_ *` - INVALID
- `*Something cool` - INVALID, no closing modifier

As for detached modifier rules:
- `*A heading` - INVALID, must have whitespace or a modifier afterwards
- `** A heading` - VALID, the first detached modifier is followed by another detached modifier which is followed by whitespace
- `Some* interesting text` - INVALID, will not yield any special result and will be treated as a regular `*` character.
- `- A list` - VALID
- ` - A list` - VALID, has preceding whitespace and also whitespace afterwards, treated as an unordered list
- `A list-` - INVALID, will be treated as a regular `-` character

Regarding trailing modifier rules:
- `Some text~` - VALID, trailing modifier has an alphanumeric character before itself and is at the end of a line
- `Some text~ ` - INVALID, trailing modifier has an alphanumeric character before itself but it is not at the end of the line (has trailing whitespace)
- `Some text ~` - INVALID, trailing modifier does not an alphanumeric character **or** punctuation mark before itself
- `Some text,~` - VALID, trailing modifier has an alphanumeric character or punctuation mark before itself and is at the end of a line

And - finally - as for delimiting modifier rules:
- `==` - INVALID, needs at least 3 consecutive chars
- ` ===` - VALID, has whitespace beforehand, 3 consecutive characters and no text afterwards
- `--- ` - INVALID, trailing whitespace, treated as a detached modifier
- `text ---` - INVALID, has text beforehand
- `------------------------` - VALID, consist of more than 3 consecutive characters and no text afterwards

### Different Rules for Different Modifiers
Whilst all modifiers must adhere to the rules presented above, some modifiers may only be valid if the above rules are fulfilled _and_
some extra conditions are met. There will be a few modifiers that don't adhere to the presented rules above and add extra constraints - note the keyword
here, **add**. Extra rules can be only that - "extra"; they cannot change any of the rules that are presented above, but only provide extra constraints.

# Design decisions
Neorg's design goals are simplistic in nature - simplify existing concepts from other formats and allow for easy extensibility - be deterministic,
do not allow any extra side effects and be as explicit as possible.
Rather than operating on the principles of markdown, where some things work except they sometimes don't and the rest is up to the
implementation, Neorg works on a single principle: Things either work fully or don't work at all. Think of it as being simply more strict
with the rules we impose without limiting creativity and freedom. I, personally, would much rather something not work than it work
only in certain situations and only with hacky layouts.
Because of this, every feature is carefully looked over and all possible changes that could be made to that feature are considered.
If the feature is very fundamental then little to no changes are made so people can quickly familiarize themselves with the format, however -
certain, more complex elements will be treated more harshly in terms of changes.
After a long term massive brain thinking session, the current concepts are proposed, alongside explanations as to why they are beneficial
changes:
### Parsing Order

  The Neorg lexer should read every modifier from left to right in the most logical order possible.
  This means that `*This bit* of text*` should be interpreted as "**This bit** of text\*", where the last asterisk
  is treated as regular text because it does not form a pair. Doing so avoids several edge cases and several problems
  that the parser may have to overcome. Several other formats implement this same parsing order.

### Attached Modifiers and Their Functions
  Attached modifiers are those that change the look of a piece of text. Their symbols and functions are described here:
  - `*some text*` - marks text as **bold**
  - `/some text/` - marks text as _italic_
  - `_some text_` - marks text as underline
  - `-some text-` - marks text as ~~strikethrough~~.
  - `^some text^` - superscript
  - `,some text,` - subscript
  - `!some text!` - spoilers
  - \`some text\` - inline code block (verbatim)
  - `$some text$` - inline mathematics
  - `+some text+` - inline comment
  - `=variable=` - accesses a previously defined variable

### Detached Modifiers and Their Functions
  Detached modifiers are those that change the way text is interpreted. Their symbols and functions are described in the following text:

  - `* Some text` - marks text as a heading. Headings are one-line paragraphs
  - `** Some text` - marks text as a subheading. Subheadings are one-line paragraphs
  - `*** Some text` - marks text as a subsubheading. Subsubheadings are one-line paragraphs
  - `**** Some text` - marks text as a subsubsubheading. Subsubsubheadings are one-line paragraphs
  - `***** Some text` - marks text as a subsubsubsubheading. Subsubsubsubheadings are one-line paragraphs
  - `****** Some text` - marks text as a ..., you get the idea. Neorg can only go up to 6-level headings
  - `- Do something` - marks an unordered list
  - `~ Do something` - marks an ordered list
  - `- [ ]` - marks an undone task
  - `- [-]` - marks a pending task
  - `- [x]` - marks a complete (done) task
  - `- [=]` - marks an on-hold item
  - `- [_]` - marks a cancelled item
  - `- [!]` - marks an urgent item
  - `- [+]` - marks a recurring item
  - `- [?]` - marks an uncertain item
  - `| Important Information` - symbolizes a marker
  - `> That's what she said` - marks a quote

  - ```
    @document.meta
        <data>
    @end
    ```
    Marks a data tag, which you can read more about [here](#defining-data).

  - ```
    A {# My Link}[link]
    ```
    Marks a link to another segment of a document or to a link on the web. More about it can be read [here](#links).

  - ```
    #comment
    This is a comment!
    ```
    Marks a carryover tag, which is essentially syntax sugar for a regular tag.
    You can read more about it [here](#carryover-tags).

  - ```
    = ToC Table Of Contents:
    ```
    Marks an `insertion`. Insertions, well, insert text into a document dynamically. You can read more about them [here](#insertions).

### Trailing Modifiers
  Trailing modifiers serve one purpose: change the way the next line is interpreted. This allows us to break some of the limitations
  that other markup formats impose and allows us to further finely control the behaviour of the Neorg parser with little added complexity.
  Neorg currently supports one of these trailing modifiers: `~`.

  So, why do we need these trailing modifiers? Let's say you want to do this:
  ```
  * A heading that talks about some really super duper awesome things that I'm really excited to share
    with you tonight.
    Today I will be talking about...
  ```
  The issue? Your heading is really long, and you'd like to divide it into two lines. Although you shouldn't make your headings this long,
  it would be really nice to be able to tell Neorg to carry over to the next line and still treat is as part of that one line.
  Enter the `~` trailing modifier which, when placed at the end of a line, will allow you to concatenate two different lines and treat them
  as if they were one line. `~` adds one whitespace character just like a regular soft line break would.
  This feature is very useful to prevent the parser from interpreting a bit of raw text as a modifier, for example:
  ```
    And then I ventured through the forest~
    - I couldn't believe what I saw
  ```
  Using the `~` trailing modifier we prevent Neorg from interpreting the next line as an unordered list, and cause it to interpret
  the line as raw text instead, so the line becomes: `And then I ventured through the forest - I couldn't believe what I saw`.

### Escaping Special Characters
  Sometimes you'll find yourself not wanting to have a certain character format your text, you can directly prevent this
  by prefixing that character with a backslash `\`. *All* characters are escapable in this fashion.

### Defining Data
  What divides simple markup files from more complex implementations is the ability to morph the document and define data inside the document.
  Neorg has a few ways of defining data, however it is not ultimately that complex. Let's review the methods of defining data:
  ```
  @my_data
    <any form of data>
  @end
  ```
  The `@` symbol, which defines the beginning of a **data tag** (more commonly referred to simply as a **tag** or **ranged tag**), allows the user to specify any bit of arbitrary data
  and label it with said tag. Different modules can then access this data and perform different actions based on it.
  One of the most notable inbuilt tags for Neorg is the `@document.meta` tag. Metadata is defined as such:
  ```
    @document.meta
        title: My Document
        description: Document description
        author: Vhyrro
        created: 2021-06-23
        categories: [
            personal
            blogs
            neorg
        ]
        version: 0.1
    @end
  ```
  Tags must appear at the beginning of a line, and may optionally be preceded by whitespace. After that, any sort of text may be entered on as many lines
  as the user sees fit. The end of the data tag must be signalled with an `@end` token that must appear at the beginning of a line (with optional whitespace before it)
  and may not have any extra tokens after itself other than whitespace.
   
  Will all that said: 
  ```
    VALID:
        @some.tag
            data goes here
            blah blah blah
        @end
    ALSO VALID:
        @some.tag
        data goes here
        blah blah blah
        @end
    VALID:
            @some.tag
            more data
            blah blah blah
                @end
    INVALID (last line gets treated as a continuation of the data and no end marker gets located):
        @some.tag
            text
        @end right now
    INVALID (tag definition has non-whitespace characters before itself):
        some pretext @some.tag
            text here
        @end
    ALSO INVALID (end token has non-whitespace characters beforehand):
        @some.tag
            text here
        the @end
    INVALID (content cannot be indented less than the starting tag):
        @some.tag
       content
        @end
  ```

#### Tag Parameters
  Tags may take in a certain amount of parameters, and these parameters can be supplied in a few different ways.
  For example, let's say we have a tag called `code` (which is a real tag btw!), and it takes in an optional parameter denoting
  the language. Neorg does not have multiline code blocks \`\`\`like this\`\`\` because such modifiers would directly break
  the imposed rules for attached modifiers, instead it uses the code tag:
  ```
    No parameter supplied, treated as a regular code block:
    @code
        console.log("Wow some code.")
    @end

    Parameter supplied, denotes the language via a parameter:
    @code lua
        print("Some awesome lua code!")
    @end
  ```
  Several parameters can be provided via space separation if the tag wants more than one parameter.

#### Carryover Tags
  Neorg provides a more convenient method of defining tags, one that does not require an `@end` token. These are called carryover tags,
  because they carry over and apply only to the next paragraph. They can be denoted with a `#` token, rather than a `@` token.
  Inside of a carryover tag everything after the tag till the end of the line is counted as a
  parameter for that tag, and the body for that tag is the next element, be it a paragraph or detached
  modifier.

##### Quirks
  One of the interesting quirks about carryover tags is how they can sometimes be advantageous over
  ranged tags when it comes to directly modifying markup. Ranged tags are basically *long range verbatim blocks*.
  This means that anything within those tags won't be treated as Neorg markup - this makes sense.
  Carryover tags, however, do allow for markup to naturally exist since they don't have a range, they
  simply attach to whatever is below them in the document. Since the document is, well, markup, whatever
  the carryover tag attaches to is still treated as normal markup.

  Another feature of carryover tags is their ability to carry themselves over and chain a bunch of
  tags together. For example, if I were to do:

  ```
    #color red
    #name my-heading
    * I like tomatoes
  ```

  The `#color` carryover tag will carry over to the `#name` tag, which will in turn carry over to the heading,
  creating a chain reaction.

### Single-line Paragraphs
  Single-line paragraphs are a special type of paragraph as they only exist for one line.
  We actually just had an encounter with such a paragraph with the data tags we discussed earlier.
  A data tag definition (like `@document.meta`) instantly breaks off as soon as the end of the line
  is reached, meaning that:
  ```
    @document
        .meta
  ```
  Will **not** result in the concatenation of both values to `@document.meta`, like it would in a normal paragraph,
  where:
  ```
    Some awesome
    text
  ```
  Gets concatenated into `Some awesome text`. This rule doesn't only apply to single-line paragraphs, as having to use a hard line-break
  like so:
  ```
    @document.meta

        key: value
    @end
  ```
  Would look incredibly ugly and would make it very confusing to people familiar with something called "logic".
  There are a few elements that use single-line paragraphs, these being:
  - Heading and all types of subheadings
  - Tag and carryover tag definitions
  - Marker definitions
  - Quotes

  This design decision is very logical, as writing:
  ```
    * Heading one
    This is some subtext for heading one
  ```
  Is a lot cleaner than having to place a hard line break:
  ```
    * Heading one

    This is some subtext for heading one
  ```
  Obviously, it is still possible to supply a hard line break, however both options are permitted.

### Intersecting Modifiers
  Sometimes you may want to use modifiers while they're inside of a piece of text, like t**hi**s. Note how the **hi** is in bold.
  Neorg allows this, however it requires an extra step. According to the rules there must be whitespace/punctuation before
  an opening modifier and there must be whitespace/punctuation after a closing modifier. This means simply putting our modifiers inbetween
  our word l\*ik\*e so will not result in anything, as the modifiers break the defined rules. There is one extra rule, however - not only
  can these modifiers be prefixed/postfixed with whitespace or a punctuation mark, but they can also be prefixed/postfixed with *another modifier*.
  This is where the fun begins, enter the `:` modifier, except it's no ordinary modifier. It's a one-of-a-kind, in fact.
  This is the only modifier that does not fall into any of the 4 categories of modifiers (attached, detached, trailing and delimiting). The `:`
  symbol is marked the **link modifier**. It exists to link different "categories" of text together.
  The rules for the link modifier are a twist on the rules of the attached modifier, meaning a link modifier must form a pair.
  The opening link modifier must be immediately followed by an attached modifier.
  Accordingly, the closing link modifier must be immediately preceded by one.
  Note that the link modifier is **not** an attached modifier, so chaining
  them like `::<attached modifier>` will simply result in the first colon being
  treated as punctuation.
  There are no other constraints on the placement of link modifiers.
  Let's give some quick examples comparing with Markdown:

| Markdown       | Neorg            |
|----------------|------------------|
| `so*me*thing`  | `so:*me*:thing`  |
| `*im*possible` | `:*im*:possible` |
| `can*not*`     | `can:*not*:`     |

  At first it looks weird, doesn't it? Hah.
  We believe that since you will find yourself injecting modifiers into a word rather infrequently it is worth trading some
  extra characters for infinitely more syntactical stability in the file format. Want to do something like `t**his black** magic`? You also can,
  like so: `t:*his black*: magic`. The imposed rules for both the opening and closing link modifier are still fulfilled, and as such
  you will get the result you'd expect - t**his black** magic.

  An important thing to note is that a modifier opened via a link modifier must also be closed via a link modifier, that is:
  `t:*his is some* text` will be *invalid* and will not render as you'd expect, because the opening `:*` does not have a corresponding closing `*:`.
  This, however, would be valid: `t:*his is some*: text`. As always you can use `\` to escape a character if you don't want it to have special meaning to Neorg.

### Lists
  Lists are ways of organizing text into several bullet points. There are two main types of lists - unordered and ordered lists.
  Let's talk about them.

  To describe an unordered list, you may use the `-` detached modifier, which will result in this:
  ```
    - Do something
    - Do something else!
  ```
  There must be at least one bit of whitespace between the hyphen and the `D` for the unordered list to be considered as such.

  Ordered lists operate a bit differently from your average markup language. Instead of using numbers, you use a special detached modifier. You can then use tags and [infectious](#quirks)
  properties to control how the ordering happens.
  ```
  ~ Ordered item
  ~ Second ordered item
  ```
  This will render as:

  1. Ordered item
  2. Second ordered item

  The `#ordered` tag controls how the ordered list will get rendered and has a few parameters, and they are:
  `#ordered start step spacing`.
  - `start` - signifies where to start counting from, default is `1`.
  - `step` - signifies how much to add between each list element, default step is `1`,
    if it were e.g. `2`, then the numbering would look like:
    ```
    1. First element
    3. Second element
    5. Third element
    ```
  - `spacing` - signifies how many newlines to add between each list element during the render,
    default is `1`.

  Example:
  ```
  #ordered 2 2 2
  ~ Item 1
  ~ Item 2
  ```

  Yields:
  ```
  2. Item 1

  4. Item 2
  ```

### Nesting
  Nesting information can be very important to determine the layout of a document.
  Only items that contain a detached modifier can be nested in the way we will describe below.
  It is nice to be able to create e.g. nested lists, like so:
  ```
  - Do something
    -- Another important thing
    -- Another very important thing
  ```

  In Neorg you repeat the modifier up to 6 times in order to mimic 6 different indentation levels.
  This comes with several benefits. The first is that you, as the writer, *do not need to worry about indentation*.
  This is actually a great thing, you should be focusing on the text, not about whether it's indented properly. This
  approach also allows the computer to do more thinking for you, as it doesn't have to guess how indented an item is, it just *knows*
  and can auto-indent based off of how many repetitions of the modifier there is. Additionally it allows you to start on an already indented
  list item:

  ```
  -- Second level list item
  ```

  Which may or may not be something you may want, but the fact that you have such flexibility empowers you and doesn't limit how you can write a document.

  Other examples include:

  ```
  Todo Items:
  - [x] Done item
  -- [x] Nested done item

  Unordered links:
  -> {# To a location}[link]
  --> {# To another location}[nested link]

  Ordered lists:
  ~ Ordered list item
    ~~ Nested ordered list

  Ordered links:
  ~> {# To a location}[link]
  ~~> {# To another location}[nested link]

  Quotes:
  > A quote
  >> A nested quote
  ```

  You can read more about Neorg's indentation philosophy [here](#indentation).

### TODO Lists
  TODO Items should be fairly intuitive. Here are the three basic TODO item types:

  ```
  - [ ] Do the dishes <- undone task
  - [-] Do the dishes <- pending task
  - [x] Do the dishes <- done task
  ```

  It is also possible to nest these in the same way as described [above](#nesting).

Apart from those basic types existing we've also created *several* different TODO items to express
several different occasions. Here they are:
```
- [ ] I am an undone task
- [-] I am a pending task (in-progress)
- [x] I am a done task
- [=] I am an on-hold task (more on this later)
- [_] I am a cancelled task
- [!] I am an urgent task
- [+] I am a generic recurring task
- [?] I am an uncertain task (will I ever have to complete this?)
```

Let's expand on some of the TODO item types, as well as explain why we chose the characters we chose:
- On-hold tasks (`[=]`). These are tasks that used to be pending, however you had to stop doing at this moment
and postpone it to a later date. It's an equals sign because it's one step
further (two horizontal lines (`=`)) than a pending item (which is a single horizontal line (`-`)).
- Cancelled tasks (`[_]`). This one's pretty self-explanatory. It's a task that you end up cancelling (i.e. you won't do it)
but you want to keep it around for future reference. We use an underscore here because an underscore looks
like it's been "put down", which is exactly what a cancelled task is.
- Urgent tasks (`[!]`). Simply marks a task that you should want to do ASAP.
- Recurring tasks (`[+]`). This is an interesting type of task, as it requires children. If it doesn't have any
children then it can be treated as a pending task instead. All children will be reset once every subtask
becomes complete. This is only really useful within Neorg itself, and not while rendering to e.g. HTML.
- Uncertain tasks (`[?]`). Sometimes you don't know whether or not you will have to perform a task.
This task type is exactly a way to express that.

### Links
  Links are ways to connect several documents together and give the user access to special clickable hyperlinks.
  The syntax for links is very unique, however we've tried making it as unobtrusive, simple and powerful as possible,
  all at the same time.
  ```
    This is a {<anything here>}[link]!
  ```

  The modifiers that comprise the link syntax are attached modifiers, as they should be.
  It's just that they have one [additional](#different-rules-for-different-modifiers) rule that states that
  the closing `}` modifier and optional opening `[` modifier must be directly next to each other, that's it.

  There are several things that can go into a link, so let's discuss:

#### The Link Location
  The first segment of a link is the curly brackets (`{<location>}`). This is referred to as
  the *link location*.

  Neorg uses the first set of non-alphanumeric characters to determine what type of element it should link to.
  Afterwards, it will check the document from top to bottom for that element and provide the first found match as the link.
  If there is no special non-alphanumeric character after the opening bracket `{` then the text is counted as a hyperlink,
  even if it is an incorrect hyperlink.

  Searching is case insensitive but punctuation sensitive, meaning `{# Example heading}` and `{# example heading}` link to the same
  location. Since it's punctuation sensitive though `{# Example, heading}` and `{# Example heading}` will **not**
  link to the same location.

  Apart from linking to just any element (which is what you saw with the `#` symbol),
  Neorg can also narrow down the scope of what you can link to.
  Here are some examples:
  ```
  {# A link to any element (you've seen this before)}

  {* A link to a heading-1 element only}
  {** A link to a heading-2 element only}
  {*** A link to a heading-3 element only}
  {**** A link to a heading-4 element only}
  {****** A link to a heading-5 element only}
  {******* A link to a heading-6 element only}

  {$ A link to a definition only}
  {^ A link to a footnote only}
  {@ link-to-a-non-neorg-file.txt}
  {| Link to a marker only}
  {https://github.com/nvim-neorg/neorg}
  ```

  This can help whenever you have several types of objects in your document with the same name and you'd like
  to address each one individually.

  Apart from just providing a location, you can also provide a file at any moment. To do this, prepend your link location
  with two colons and the filepath inbetween, like so:
  ```
  {:file:* This is a link location}
  ```

  Whenever you use this syntax Neorg (and the parser) will *always* assume you're referencing a .norg file. You cannot
  link to a non-neorg file using this syntax, and that's also why you don't provide the file extension at the end (i.e. `{:file.norg:* This is a link location}`).
  To reference a non-neorg file you should use the designated syntax (`{@ my/custom/file.txt}`) instead.

  Filepaths are relative to the norg file they're contained in by default, *unless* you decide on directly specifying a root.
  There are three ways of defining a root:
  - The first way of defining a root is the `/` symbol, which you know very well - it simply means *the root of your filesystem*.
    i.e. if you were to do `{:/some/file:}` then Neorg will search at the very root of your computer's FS.
  - The second way of defining a root is the `$` symbol, and this denotes a *workspace root*. This means if I do
    `{:$/file/somewhere:}` I will be referencing `file/somewhere` from the root of the current workspace Neorg is in.
  - You can also specify a root of a *different* workspace by providing a name inbetween the `$` and the `/`: `{:$my_workspace/my/file:}`.

  As you may have seen, you can also entirely omit the location whenever you provide a filepath. `{:my_file:}` is perfectly
  valid syntax, as it will simply point to `my_file.norg` *without* pointing to any element within it. Note that whenever
  you supply a file you can no longer supply a URL nor an external file.

#### The Link Description
You may have realized this, however a link can actually be constructed with two different components.
The first required component is the link location, which we've just described above. There is an optional segment, however,
and that is the link description. When a link description isn't provided the content of the item the link was pointing to will
be used as the text to render (i.e. if I did `{* a location}` during an export to html you will see the hyperlink render `a location`).
You can obviously just provide a custom text to display using the below syntax:
```
{* Some location}[some custom text]
```

Now during an export you'll see the generated hyperlink have the text [some custom text]().

### Anchors
Anchors are basically a twist on links. They're there to reduce the duplication of link locations, should you want to link to the same place
several times.

Let's talk a little about their syntax:
```
Hello, would you like to visit my [website]?
...
If you have any problems, feel free to contact me via my [website]{https://some.website}.
```

You may notice something interesting here: the order of elements in the anchor is swapped!
Instead of having a location first and then an optional description, you now have the description
first and the optional location second.
Anchors without the optional second location are called *anchor declarations*
whilst full anchors with the location are called *anchor definitions*.
You can have as many anchor declarations as you like within a document
but should only have one anchor definition. In the case where several anchor
definitions have been made the first anchor definition in the document should
be prioritised.

Clicking on an anchor declaration should take you to the anchor definition, and
clicking the anchor definition should take you to the location that was defined
there.

### Insertions
  Insertions can be thought of as a motion of sorts. It inserts some text either into the document or into a variable.
  Insertions happen through the `=` detached modifier, and can exist anywhere in the document.
  The syntax looks like this:

  ```
  = single_word Parameters go here
  ```

  This can be used to set a variable (must be lowercase):

  `= variable_name value`

  Variables can be accessed at a later point in your document via the `=` **at**tached modifier like so: `Insert my =variable=`.

  Or can be used to place an element like a dynamically generated Table of Contents in the file (note how the "T" in TOC is uppercase; the rest of the casing doesn't matter):

  `= TOC Table of Contents:`

### Markers
  Markers are ways to create easy "checkpoints" within your document. These can be referenced in [links](#links)
  and can be jumped to at any time. To define a marker, we may use a single pipe symbol `|`.

  ```
    I have some cool text here. You may be interested in checking out [this other cool text](|my-special-marker).

    * You won't believe how much money she made with this one simple trick!

| My Special Marker

    * Actual important things you should know about
        I have some more cool text here.
    * Work stuff:
      - [x] Throw banana at boss's massive 4head
  ```

  It is also possible to give your marker a special name by using the `#name` tag to reference it in links, like so:
  ```
    #name marker1
    | My Special Marker

    #comment
    Reference the marker with its custom name

    I have a link to my marker right [here](#marker1).
  ```

### Definitions
Defintions provide an easy syntax to define any kind of object.
The norg format supports two such kinds:

#### Single-paragraph definitions
These look like the following:
```
$ Object to be defined
A single-paragraph definition of the object.

This paragraph is no longer part of the definition.
```

#### Multi-paragraph definitions
```
$$ Object to be defined
Here you have the freedom to write your definition in multiple paragraphs.

You can even include other syntax elements:
@code lua
print("Hello world!")
@end
$$
This is no longer part of the definition.
```

### Indentation
One of our design goals when developing this format was "focus on the text, not the outcome". Whilst most markdownesque languages
have this goal they always fail to fulfill it one way or another. One of those ways, we realized, was indentation! The user has to care
about how their documents are indented! If they're incorrectly indented then the parser could misinterpret them. As you've probably read above
we've aimed to partially fix that with *repeating modifiers*, aka `-- Nested list item` and so on. That's not the end of it though! There's one more thing we need to tell you,
and that's the use for delimiting modifiers - what they are and how they are used. In Neorg, once you start a heading, you need to end it manually.

Neorg will not look at indent levels in order to determine whether or not something belongs to the heading or not, it'll just keep treating *all* paragraphs
as part of the heading until the user manually says "hey, break me out of the heading" or until a [consecutive heading](#consecutive-headings) is met.
This is what both the `---` and `===` delimiting modifiers are for.
Take this as an example:

```
* A heading!
  Some text underneath

  More text

Even more text
```

What you may be inclined to think is that `Even more text` should not belong to the heading anymore, but this is where you'd be wrong. It's still part of the heading in Neorg!
So, uh, how do we break out? If you want to break out directly into the root of the document use the strong delimiting modifier aka `===`:

```
* A heading!
  Some text underneath

  More text

===
Even more text
```

What we've done is terminated the heading and started out a new paragraph that is no longer "underneath" the heading itself.

#### Consecutive Headings
One good thing is that you don't need to tell Neorg to break out of a heading *every. single. time*.
Let's say you have this scenario:

```
* A heading
  Text underneath the heading

Text also underneath the heading

* Another heading
  More text
```

Notice how I don't need to place a `===` between the two headings. Neorg infers that since we've started another heading of the same type
it must mean that we're terminating the "indented" text. This may seem obvious to some but not to others so I'd rather mention it.

As we've said previously the strong delimiting modifier takes you back to the root of the document, and as such:

```
* A heading
  ** A subheading
     Text

     More text

===
Extra text
```

The `Extra text` does not belong under any of the two headings since we've returned to the document root. What if I'd like to escape the second-level heading
and return to the first-level heading? For this we use the weak delimiting modifiers (aka `---`):

```
* A heading
  ** A subheading
     Text

More text on a different indentation level (still belongs to the second-level heading)

  ---
  This text belongs to the first-level heading

This also belongs to the first-level heading

===
This text belongs to the root of the document
```

**Main benefits**:
- Means that Neorg can autoindent text for you! It doesn't need to guess anymore.
- Text that belongs and doesn't belong to the heading is easier to distinguish, especially if you have headings that span over a few screens in your neovim session.
  It can give you insight into the document's structure at a glance.

#### Horizontal Lines
There is one more delimiting modifier: the horizontal line. It looks like this: `___` (or any higher number of underscores).
This modifier will get rendered as a horizontal line and as such is equivalent to Markdown's `---` syntax.
Note, that this modifier does *NOT* affect the indentation of the following paragraphs!
If you want to also change the heading level you should combine this with one of the aforementioned delimiting modifiers.
It does however immediately terminate the current paragraph resulting in the following:
```
This is a paragraph.
___
This is an entirely different paragraph despite of the absence of two (or more) consecutive new lines because of the `___` delimiter.
```

# Tags
Neorg provides several inbuilt tags to represent different things. Those exact things will be detailed here:
- `@document.meta` - describes metadata about the document. Attributes are stored as key-value pairs. Values may have
  attached and trailing modifiers in them. The trailing modifiers should be respected and the attached modifiers
  should only really be taken into account if that metadata is being rendered somewhere.

  Example:
    ```
    @document.meta
        title: My Document <- The title of the document
        description: This is my document that details the reasons~
        why Neorg is the best file format. <- The description of the document
        author: Vhyrro <- The name of the author
        created: 2021-06-23 <- The date of creation in the Y-M-D format
        categories: personal blogs neorg <- Space separated list of categories
        version: 0.1 <- The version of the file format used to create the document
    @end
    ```

  It is not recommended to use the `#` equivalent for this tag but hey, you do you.

- `@table` - defines a Neorg table. Tables do not currently have the immense power of org-mode tables,
  however serve a basic function for now. They simply contain some text. Here's the format for said tables:
    ```
    @table
        This is a row | And another element of that row
        This is a row on a new column | And another element of that row
        -
        The above line marks a delimiter
    @end
    ```

  After rendering the table it should look like:
  ```
  |         This is a row         | And another element of that row |
  | This is a row on a new column | And another element of that row |
  | ----------------------------- | ------------------------------- |
  |                The above line marks a delimiter                 |
  ```

  If you wanted to prevent the bottom line from filling up the entire space, you'd do:
  ```
    @table
        This is a row | And another element of that row
        This is a row on a new column | And another element of that row
        -
        The above line marks a delimiter |
    @end
  ```

  And you'd get:
  ```
  |          This is a row           | And another element of that row |
  |  This is a row on a new column   | And another element of that row |
  | -------------------------------- | ------------------------------- |
  | The above line marks a delimiter |                                 |
  ```

  If the content of the cell has a newline then that newline gets converted into a `\n` sequence.

- `#ordered` - changes the way that ordered lists are viewed during render

  The `#ordered` tag has a few parameters, and they are:
  `#ordered start step spacing`.
  - `start` - signifies where to start counting from, default is `1`.
  - `step` - signifies how much to add between each list element, default step is `1`,
    if it were e.g. `2`, then the numbering would look like:
    ```
    1. First element
    3. Second element
    5. Third element
    ```
  - `spacing` - signifies how many newlines to add between each list element during the render,
    default is `1`.

  The carryover tag version can be used with "infecting" to achieve a nice result.

- `#name name` - gives the next element with a detached modifier a custom name that can then be used to
  reference it in links if that next element has a detached modifier.

  Example:
  ```
  #name mycustomname
  #name anothername
  * My Heading

  You can reference the document [here](#mycustomname) and [here](#anothername).
  ```

- `@image format` - stores an image within the file. The content of this image should be a base64 encoded jpeg, png, svg, jfif or exif file.
  The only parameter, `format`, specifies which format the image was encoded in. Defaults to `PNG` if unspecified.

- `@code language` - creates a mulitiline code block. The only parameters, `language`, is optional.
Code placed within this tag will be rendered with the language's own syntax highlighter or simply rendered verbatim if no language parameter was given.

- `@math` - creates a multline LaTeX-typesetting environment for easy mathmatical equations.
  This may be enhanced further with the `#numbered` carryover tag in a similar vain to the `#ordered` tag.

### Unsupported Tags
  If a tag is encountered that is invalid it should simply be ignored and never showed in any render of the document.
