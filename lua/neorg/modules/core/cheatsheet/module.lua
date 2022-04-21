require("neorg.modules.base")

local module = neorg.modules.create("core.cheatsheet")
local log = require("neorg.external.log")

module.setup = function()
    return {
        success = true,
        requires = {
            "core.neorgcmd",
            "core.ui",
        },
    }
end

module.private = {
    ns = nil,
    win = nil,
    buf = nil,
    lines = {
        [[* Norg Syntax]],
        [[  -> {# Basic Markup}]],
        [[  -> {# Things which you can nest}]],
        [[  --> {# Unordered lists}]],
        [[  --> {# Ordered lists}]],
        [[  --> {# Tasks}]],
        [[  --> {# Quotes}]],
        [[  --> {# Headings}]],
        [[  ---> {# ... prepare to have your mind blown!}]],
        [[  ----> {# Indentation reversion}]],
        [[  -----> {# Final heading level}]],
        [[  -> {# Links}]],
        [[  --> {# Link Targets}]],
        [[  --> {# Pure link location}]],
        [[  --> {# Custom link text}]],
        [[  --> {# Anchors}]],
        [[  --> {# Link Lists}]],
        [[  --> {# Examples:}]],
        [[  -> {# Markers}]],
        [[  -> {# Definitions}]],
        [[  --> {# Single-paragraph definitions}]],
        [[  --> {# Multi-paragraph definitions}]],
        [[  -> {# Footnotes}]],
        [[  --> {# Single-paragraph footnotes}]],
        [[  --> {# Multi-paragraph footnotes}]],
        [[  -> {# Data Tags}]],
        [[  --> {# Carryover}]],
        [[  --> {# Comments}]],
        [[  --> {# Name}]],
        [[  --> {# List ordering}]],
        [[  --> {# Tables}]],
        [[  --> {# Code Blocks}]],
        [[  --> {# Media}]],
        [[  --> {# Math}]],
        [[  -> {# Advanced markup}]],
        [[  --> {# The Link modifier}]],
        [[  --> {# Nested markup}]],
        [[  --> {# Object continuation}]],
        [[  --> {# Variables}]],
        [[  --> {# Insertions}]],
        [[]],
        [[** Basic Markup]],
        [[   Here is how you can do very basic markup. First you see it raw, then rendered:]],
        [[   - \*bold\*: *bold*]],
        [[   - \/italic\/: /italic/]],
        [[   - \_underline\_: _underline_]],
        [[   - \-strikethrough\-: -strikethrough-]],
        [[   - \|spoiler\|: |spoiler|]],
        [[   - \`inline code\`: `inline code`]],
        [[   - \^superscript\^: ^superscript^  (when nested into `subscript`, will highlight as an error)]],
        [[   - \,subscript\,: ,subscript,  (when nested into `superscript`, will highlight as an error)]],
        [[   - \$inline math\$: $f(x) = y$ (see also {# Math})]],
        [[   - \=variable\=: =variable= (see also {# Variables})]],
        [[   - \+inline comment\+: +inline comment+]],
        [[]],
        [[   This also immediately shows you how to escape a special character using the backslash, \\.]],
        [[]],
        [[** Things which you can nest]],
        [[   Neorg generally does *NOT* care about indentation! 🎉]],
        [[   Thus, nesting is done via repeating modifiers like you are used to it from Markdown headings.]],
        [[   Note, that this allows you to start at an arbitrary nesting level if you so desire!]],
        [[]],
        [[*** Unordered lists]],
        [[    @code norg]],
        [[        - Unordered list level 1]],
        [[        -- Unordered list level 2]],
        [[    @end]],
        [[    - Unordered list level 1]],
        [[    -- Unordered list level 2]],
        [[    --- Unordered list level 3]],
        [[    ---- Unordered list level 4]],
        [[    ----- Unordered list level 5]],
        [[    ------ Unordered list level 6]],
        [[]],
        [[*** Ordered lists]],
        [[    @code norg]],
        [[        ~ Unordered list level 1]],
        [[        ~~ Unordered list level 2]],
        [[    @end]],
        [[    ~ Ordered list level 1]],
        [[    ~~ Ordered list level 2]],
        [[    ~~~ Ordered list level 3]],
        [[    ~~~~ Ordered list level 4]],
        [[    ~~~~~ Ordered list level 5]],
        [[    ~~~~~~ Ordered list level 6]],
        [[]],
        [[*** Tasks]],
        [[    @code norg]],
        [[      - [ ] Undone -> not done yet]],
        [[      - [x] Done -> done with that]],
        [[      - [?] Needs further input]],
        [[]],
        [[      - [!] Urgent -> high priority task]],
        [[      - [+] Recurring task with children]],
        [[]],
        [[      - [-] Pending -> currently in progress]],
        [[      - [=] Task put on hold]],
        [[      - [_] Task cancelled (put down)]],
        [[    @end]],
        [[    - [ ] Undone]],
        [[    - [x] Done]],
        [[    - [?] Needs further input]],
        [[]],
        [[    - [!] Urgent]],
        [[    - [+] Recurring task]],
        [[]],
        [[    - [-] Pending]],
        [[    - [=] Task put on hold]],
        [[    - [_] Task cancelled]],
        [[]],
        [[    You can also nest tasks:]],
        [[    -- [ ] Nested task level 2]],
        [[    --- [ ] Nested task level 3]],
        [[    ---- [ ] Nested task level 4]],
        [[    ----- [ ] Nested task level 5]],
        [[    ------ [ ] Nested task level 6]],
        [[]],
        [[    @code norg]],
        [[        - [ ] Undone Task, Nested level 1]],
        [[      -- [-] Pending Task, Nested level 2]],
        [[        --- [x] Done Task, Nested level 3]],
        [[    @end]],
        [[]],
        [[*** Quotes]],
        [[    @code norg]],
        [[        > 1. level quote]],
        [[        >> 2. level quote]],
        [[    @end]],
        [[    > 1. level quote]],
        [[    >> 2. level quote]],
        [[    >>> 3. level quote]],
        [[    >>>> 4. level quote]],
        [[    >>>>> 5. level quote]],
        [[    >>>>>> 6. level quote]],
        [[]],
        [[*** Headings]],
        [[    You already saw headings up to the third out of six levels. I assume by now you know how they]],
        [[    work. But now...]],
        [[]],
        [[**** ... prepare to have your mind blown!]],
        [[     Because here is something very special and unique to Neorg:]],
        [[]],
        [[***** Indentation reversion]],
        [[      As you would expect, this paragraph belongs to the fifth level heading.]],
        [[]],
        [[****** Final heading level]],
        [[       And this paragraph belongs to the sixth level. But by using the following modifier:]],
        [[       @code norg]],
        [[             ---]],
        [[       @end]],
        [[       ---]],
        [[]],
        [[      We can move this text to the fifth level again! 🤯]],
        [[      ---]],
        [[]],
        [[     So using 3 or more `-` signs not followed by anything, you move *one* level backwards in the]],
        [[     indentation.]],
        [[     ---]],
        [[    @code norg]],
        [[        **** 4. level heading]],
        [[        ***** 5. level heading]],
        [[        ---]],
        [[        back to level 4]],
        [[        ===]],
        [[        back to root level]],
        [[    @end]],
        [[]],
        [[    And using 3 or more `=` signs will drop you right back to the root level!]],
        [[]],
        [[    You can also place horizontal lines using three or more underscores like so:]],
        [[]],
        [[    This will never affect the indentation level of the following text, but it will immediately]],
        [[    terminate the paragraph which is why this is a new paragraph despite the absence of two (or more)]],
        [[    consective new lines.]],
        [[]],
        [[** Links]],
        [[   For more info on links check the]],
        [[   {https://github.com/nvim-neorg/neorg/blob/main/docs/NFF-0.1-spec.md#links}[spec].]],
        [[]],
        [[*** Link Targets]],
        [[    The following things can be used as link /targets/:]],
        [[    - `* Heading1` (+ nesting levels)]],
        [[    - `| Marker`]],
        [[    - `> Quote` (+ nesting levels)]],
        [[    - `^ Footnote`]],
        [[    - `$ Definition`]],
        [[    - `# magic` (any of the above)]],
        [[    - `:path:# magic` (target in another norg file at a given path)]],
        [[    - `:path:` (another norg file at a given path without specific target)]],
        [[    - `@path` (a non-norg file at a given path)]],
        [[    - `https://github.com`]],
        [[    - `file:///some/path` (any file, opened via `(xdg-)open`)]],
        [[]],
        [[    Any of the paths used in `:path:` or `@path` can be formatted in either of the following ways:]],
        [[    - `:path/to/norg/file:` relative to the file which contains this link]],
        [[    - `:/path/from/root:` absolute w.r.t. the entire filesystem]],
        [[    - `:~/path/from/user/home:` relative to the user's home directory (e.g. `/home/user` on Linux machines)]],
        [[    - `:../path/to/norg/file:` these paths also understand `../`]],
        [[    - `:$/path/from/current/workspace:` relative to current workspace root]],
        [[    - `:$gtd/path/in/gtd/workspace:` relative to `gtd`-workspace root]],
        [[]],
        [[    (All of the above can also use `@...` instead of `:...:` when linking to non-norg files.)]],
        [[]],
        [[    There are multiple ways of using links.]],
        [[*** Pure link location]],
        [[    @code norg]],
        [[      An inline link to {| my marker}.]],
        [[    @end]],
        [[    An inline link to {| my marker}.]],
        [[]],
        [[    The text used for this link can be inferred from the /target/.]],
        [[    If it is not a norg-target, this falls back to the URL or filename, etc.]],
        [[]],
        [[*** Custom link text]],
        [[    @code norg]],
        [[      An inline link {| my marker}[with custom text].]],
        [[    @end]],
        [[    An inline link {| my marker}[with custom text].]],
        [[]],
        [[    This links to the same marker but uses a custom link text.]],
        [[]],
        [[*** Anchors]],
        [[    @code norg]],
        [[      A link to [our website].]],
        [[]],
        [[      [our website]{https://github.com/nvim-neorg/neorg}]],
        [[    @end]],
        [[    A link to [our website].]],
        [[]],
        [[    [our website]{https://github.com/nvim-neorg/neorg}]],
        [[]],
        [[    The standalone link /text/ is called an *anchor declaration*.]],
        [[    It requires an *anchor definition* (last line in the code block) which defines where an anchored link points to.]],
        [[    This is very useful when you find yourself refering to the same target often.]],
        [[]],
        [[*** Link Lists]],
        [[]],
        [[    @code norg]],
        [[      +unordered links+]],
        [=[      -> {* The `.norg` file-format}[link to a level 1 heading]]=],
        [=[      --> {** links}[link to a level 2 heading]]=],
        [=[      -> {| some marker}[link to a marker]]=],
        [=[      -> {# definitions}[link to any element with the text definitions]]=],
        [[      +these links will be ordered:+]],
        [=[      ~> {https://github.com/vhyrro/taurivim}[link to a cool plugin]]=],
        [=[      ~> {https://github.com/danymat/neogen}[another cool plugin]]=],
        [[      +links to files+]],
        [=[      {:file:}[link to file.norg]]=],
        [=[      {:file_2:# target}[link to target in file_2.norg]]=],
        [=[      {:/my/file:# target}[link to a target from the root of the workspace]]=],
        [=[      {@ notes.txt}[link to non neorg file notes.txt]]=],
        [[    @end]],
        [[]],
        [[*** Examples:]],
        [[    {* Heading 1}]],
        [[    {** Heading 2}]],
        [[    {*** Heading 3}]],
        [[    {**** Heading 4}]],
        [[    {***** Heading 5}]],
        [[    {****** Heading 6}]],
        [[    {******* Heading level above 6}]],
        [[    {# Generic}]],
        [[    {| Marker}]],
        [[    {$ Definition}]],
        [[    {^ Footnote}]],
        [[    {:norg_file:}]],
        [[    {:norg_file:* Heading 1}]],
        [[    {:norg_file:** Heading 2}]],
        [[    {:norg_file:*** Heading 3}]],
        [[    {:norg_file:**** Heading 4}]],
        [[    {:norg_file:***** Heading 5}]],
        [[    {:norg_file:****** Heading 6}]],
        [[    {:norg_file:******* Heading level above 6}]],
        [[    {:norg_file:# Generic}]],
        [[    {:norg_file:| Marker}]],
        [[    {:norg_file:$ Definition}]],
        [[    {:norg_file:^ Footnote}]],
        [[    {https://github.com/}]],
        [[    {file:///dev/null}]],
        [[    {@ external_file.txt}]],
        [[    Note, that the following links are malformed:]],
        [[    {:norg_file:@ external_file.txt}]],
        [[    {:norg_file:https://github.com/}]],
        [[]],
        [[** Markers]],
        [[   You can mark specific locations in your file with markers:]],
        [[   @code norg]],
        [[     | some marker]],
        [[   @end]],
        [[| some marker]],
        [[]],
        [[** Definitions]],
        [[   There are two kinds of defintions:]],
        [[]],
        [[*** Single-paragraph definitions]],
        [[    @code norg]],
        [[      $ Object to be defined]],
        [[    @end]],
        [[    $ Object to be defined]],
        [[    The definition of the object in a single paragraph.]],
        [[]],
        [[    This is already the next paragraph.]],
        [[]],
        [[*** Multi-paragraph definitions]],
        [[    @code norg]],
        [[      $$ Object to be defined]],
        [[    @end]],
        [[    $$ Object to be defined]],
        [[    Here, I can place any number of paragraphs or other format objects.]],
        [[]],
        [[    Even a code example:]],
        [[    @code lua]],
        [[    print("Hello world!")]],
        [[    @end]],
        [[    $$]],
        [[    @code]],
        [[      $$]],
        [[    @end]],
        [[    This is no longer part of the definition because the `$$` on the previous line marked its end.]],
        [[]],
        [[** Footnotes]],
        [[   There are also two kinds of footnotes:]],
        [[]],
        [[*** Single-paragraph footnotes]],
        [[    @code norg]],
        [[      ^ This is the title of my footnote. I can use this as a link target.]],
        [[    @end]],
        [[    ^ This is the title of my footnote. I can use this as a link target.]],
        [[    This is the actual footnote content.]],
        [[]],
        [[    This is no longer part of the footnote.]],
        [[]],
        [[*** Multi-paragraph footnotes]],
        [[    @code norg]],
        [[      ^^ This is a multi-paragraph footnote.]],
        [[    @end]],
        [[    ^^ This is a multi-paragraph footnote.]],
        [[    Here go the actual contents...]],
        [[]],
        [[    ... which I can even continue down here.]],
        [[    ^^]],
        [[    @code norg]],
        [[      ^^]],
        [[    @end]],
        [[    Now, the footnote has ended.]],
        [[]],
        [[** Data Tags]],
        [[   Neorg supports a number of tags. The general format is:]],
        [[   @data possible parameters]],
        [[    contents]],
        [[   @end]],
        [[]],
        [[*** Carryover]],
        [[    There is also an infectious carryover variant which allows shorter syntax. Its format is:]],
        [[    `#data possible parameters`, which will apply the `data` tag *only* to the following]],
        [[    paragraph or element.]],
        [[]],
        [[*** Comments]],
        [[    #comment]],
        [[    This is a comment.]],
        [[    This is also still a comment because the paragraph has not ended, yet.]],
        [[]],
        [[    The double line break ended the paragraph so this is no longer part of the comment.]],
        [[]],
        [[    Note, that you can also add in-line comments using the `#`-attached modifier. #E.g. like this#]],
        [[]],
        [[*** Name]],
        [[    #name quotes]],
        [[    > This is a quote.]],
        [[    > We can talk about anything we like]],
        [[]],
        [[    This quote now has a /name/!]],
        [[]],
        [[*** List ordering]],
        [[    You can affect ordered lists and specify their /start/, /step/ and /spacing/ values (all of]],
        [[    them default to 1).]],
        [[]],
        [[    #ordered 2 2 2]],
        [[    ~ First entry]],
        [[    ~ Second entry]],
        [[]],
        [[    This will render as:]],
        [[    @code]],
        [[      2. First entry]],
        [[]],
        [[      4. Second entry]],
        [[    @end]],
        [[]],
        [[*** Tables]],
        [[    @table]],
        [[      Column 1 | Column 2]],
        [[      -]],
        [[      This is in a new row | which got separated by a horizontal line]],
        [[      And check this out: I can span the columns!]],
        [[    @end]],
        [[]],
        [[    Tables will become OP in the future!]],
        [[]],
        [[*** Code Blocks]],
        [[    @code]],
        [[      console.log("But I want syntax highlighting...")]],
        [[    @end]],
        [[]],
        [[    @code javascript]],
        [[      console.log("Thank you!")]],
        [[    @end]],
        [[]],
        [[*** Media]],
        [[    You can embed images directly in base64 format like so:]],
        [[    @image png svg jpeg jfif exif]],
        [[      <base64-encoded image data>]],
        [[    @end]],
        [[    Obviously you need to pick one of the available formats.]],
        [[]],
        [[    You can embed external image or video files like so:]],
        [[    @embed image]],
        [[      https://github.com/vhyrro/neorg/blob/main/res/neorg.svg]],
        [[    @end]],
        [[]],
        [[*** Math]],
        [[    There are two ways of typesetting mathematics:]],
        [[    ~ Inline mathematics using the `$` attached modifier like so: $f(x) = y$.]],
        [[    ~ Multiline mathematics using the `math` ranged tag which supports any LaTeX-typeset math.]],
        [[    @math]],
        [[    f(x) = y]],
        [[    @end]],
        [[    A `numbered` carryover tag in a similar vain to the `ordered` one for lists is planned to add]],
        [[    easy equation numbering support.]],
        [[]],
        [[** Advanced markup]],
        [[   There are some more advanced markup features:]],
        [[]],
        [[*** The Link modifier]],
        [[    If you want to mark-up text which is not surrounded by punctuation or whitespace, you need to]],
        [[    use the *link* modifier, `:`, like so:]],
        [[]],
        [[    W:*h*:y w:/oul/:d a:_nyon_:e w:-an-:t to do t:`hi`:s?]],
        [[]],
        [[*** Nested markup]],
        [[    You can nest multiple markup groups to combine their effect. Some examples:]],
        [[    - *Text can be bold _and underlined_!*]],
        [[    - You can create ,/italic subscripts/,.]],
        [[    - If you want to shout in the internet, use */_DOUBLY EMPHASIZED AND UNDERLINED CAPS_/*]],
        [[]],
        [[    Note: You can:*not* combine sub- and superscripts like so:]],
        [[    @code norg]],
        [[      ^,This should be super- and subscript.,^ Why though?]],
        [[    @end]],
        [[    You will notice that this get's highlighted as an error:]],
        [[    ^,This should be super- and subscript.,^]],
        [[]],
        [[*** Object continuation]],
        [[    The `~` trailing modifier causes the line break to be ignored. This allows you to do things]],
        [[    like this:]],
        [[]],
        [[**** This is a super duper long heading which I am so proud of and I absolutely cannot shorten~]],
        [[     to fit onto a single line]],
        [[]],
        [[*** Variables]],
        [[    You can define variables which you can access later in your document like so:]],
        [[    @code norg]],
        [[      = <variable name> <values>]],
        [[    @end]],
        [[    For a reason explained in the next section, variable names *must* be lowercase!]],
        [[    You can refer to this variable later in your document using the `=` attached modifier like so:]],
        [[    @code norg]],
        [[      Insert my =variable=.]],
        [[    @end]],
        [[]],
        [[*** Insertions]],
        [[    These are dynamically expanded objects which you can add to your document.]],
        [[    The simplest example of an insertion is the /table of contents/ which looks like]],
        [[    @code norg]],
        [[      = ToC Table of Contents]],
        [[    @end]],
        [[    This shows the basic syntax `= <capitalized insertion name> <arguments>` and it also explains]],
        [[    why {# Variables} have to be lowercased.]],
    },
    heading_lines = {},
    displayed = false,
    show_cheatsheet = function()
        if module.private.displayed then
            return
        end
        local width = vim.o.columns
        local height = vim.o.lines
        module.private.buf = module.required["core.ui"].create_norg_buffer("cheatsheet", "nosplit")
        vim.api.nvim_buf_set_option(module.private.buf, "bufhidden", "wipe")
        vim.api.nvim_buf_set_lines(module.private.buf, 0, -1, false, module.private.lines)
        vim.api.nvim_buf_set_option(module.private.buf, "modifiable", false)
        local nore_silent = { noremap = true, silent = true, nowait = true }
        if type(module.config.public.keybinds.close) == "table" then
            for _, keybind in ipairs(module.config.public.keybinds.close) do
                vim.api.nvim_buf_set_keymap(module.private.buf, "n", keybind, "<cmd>q<CR>", nore_silent)
            end
        elseif type(module.config.public.keybinds.close) == "string" then
            vim.api.nvim_buf_set_keymap(
                module.private.buf,
                "n",
                module.config.public.keybinds.close,
                "<cmd>q<CR>",
                nore_silent
            )
        else
            log.warn("[cheatsheet]: Invalid option for module.config.public.keybinds.close")
            vim.api.nvim_buf_set_keymap(module.private.buf, "n", "q", "<cmd>q<CR>", nore_silent)
        end
        vim.api.nvim_buf_set_keymap(
            module.private.buf,
            "n",
            "<cr>",
            "<cmd>Neorg keybind norg core.norg.esupports.hop.hop-link<CR>",
            nore_silent
        )
        vim.api.nvim_buf_set_option(module.private.buf, "filetype", "norg")
        module.private.win = vim.api.nvim_open_win(module.private.buf, true, {
            relative = "editor",
            width = math.floor(width * 0.6),
            height = math.floor(height * 0.9),
            col = math.floor(width * 0.2),
            row = math.floor(height * 0.1),
            border = "single",
            style = "minimal",
        })
        for i = 0, #module.private.lines do
            vim.api.nvim_buf_add_highlight(module.private.buf, module.private.ns, "NormalFloat", i, 0, -1)
        end
        module.private.displayed = true
    end,
    close_cheatsheet = function()
        if not module.private.displayed then
            return
        end
        vim.api.nvim_win_close(module.private.win, true)
        module.private.displayed = false
    end,
    toggle_cheatsheet = function()
        if module.private.displayed then
            module.private.close_cheatsheet()
        else
            module.private.show_cheatsheet()
        end
    end,
}

module.config.public = {
    keybinds = {
        close = { "q", "<esc>" },
    },
}

module.public = {
    version = "0.0.1",
}

module.load = function()
    vim.cmd([[highlight default NeorgCheatSectionContent guibg = #353b45]])
    vim.cmd([[highlight default NeorgCheatHeading guifg = #8bcd5b]])
    vim.cmd([[highlight default NeorgCheatBorder guifg = #617190 guibg = #353b45]])
    local section_title_colors = {
        "#41a7fc",
        "#ea8912",
        "#f65866",
        "#ebc275",
        "#c678dd",
        "#34bfd0",
    }
    for i, color in ipairs(section_title_colors) do
        vim.cmd("highlight default NeorgCheatTopic" .. i .. " guifg = " .. color)
    end
    module.private.ns = vim.api.nvim_create_namespace("neorg_cheatsheet")
    module.required["core.neorgcmd"].add_commands_from_table({
        definitions = {
            cheatsheet = {
                open = {},
                close = {},
                toggle = {},
            },
        },
        data = {
            cheatsheet = {
                min_args = 1,
                max_args = 1,
                subcommands = {
                    open = { args = 0, name = "cheatsheet.open" },
                    close = { args = 0, name = "cheatsheet.close" },
                    toggle = { args = 0, name = "cheatsheet.toggle" },
                },
            },
        },
    })
end

module.on_event = function(event)
    if vim.tbl_contains({ "core.keybinds", "core.neorgcmd" }, event.split_type[1]) then
        if event.split_type[2] == "cheatsheet.open" then
            module.private.show_cheatsheet()
        elseif event.split_type[2] == "cheatsheet.close" then
            module.private.close_cheatsheet()
        elseif event.split_type[2] == "cheatsheet.toggle" then
            module.private.toggle_cheatsheet()
        end
    end
end

module.events.subscribed = {
    ["core.neorgcmd"] = {
        ["cheatsheet.open"] = true,
        ["cheatsheet.close"] = true,
        ["cheatsheet.toggle"] = true,
    },
}

return module
