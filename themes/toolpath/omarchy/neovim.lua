-- TOOLPATH · SHOP FLOOR — Neovim (Omarchy lazy.nvim spec)
-- Personal design system, Rev H. JDC.
--
-- Toolpath has no published colorscheme plugin, so the scheme lives here:
-- LazyVim accepts a function as its colorscheme and calls it at startup.
-- Self-contained; no plugin to fetch.
--
-- Roles: bronze = keywords, cursor, the action. Dykem = types, structure,
-- directories. Dykem light (starship's dykem_light) = strings, a literal
-- reading. Anneal violet = constants and numbers. Ink annotation = comments
-- only; the faintest tier never labels. Toolpath has no red: errors take
-- bronze (as ANSI red does), warnings temper amber. Verdigris = additions.

local p = {
  ground = "#14161B",
  panel = "#1C1F26",
  inset = "#22262F",
  line = "#2E333D",
  strong = "#3D4450",
  ink = "#E8EAEE",
  label = "#9AA1AD",
  annot = "#7E8694",
  dykem = "#5B8FBF",
  dykem_light = "#8FB4D4",
  bronze = "#CE7A46",
  violet = "#B87AAD",
  amber = "#E0A036",
  verdigris = "#8CBA98",
  -- DERIVED diff grounds: verdigris and bronze at 14% over the ground
  plus = "#252D2C",
  minus = "#2E2421",
  ansi = {
    "#14161B", "#9C5530", "#6E9B7A", "#E0A036", "#35617F", "#7E4A74", "#4E86B8", "#9AA1AD",
    "#3D4450", "#CE7A46", "#8CBA98", "#E9C86A", "#5B8FBF", "#B87AAD", "#6FAEC0", "#E8EAEE",
  },
}

local function toolpath()
  vim.cmd("hi clear")
  if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
  vim.g.colors_name = "toolpath"
  vim.o.termguicolors = true
  vim.o.background = "dark"

  local groups = {
    -- core UI
    Normal = { fg = p.ink, bg = p.ground },
    NormalNC = { fg = p.ink, bg = p.ground },
    NormalFloat = { fg = p.ink, bg = p.panel },
    FloatBorder = { fg = p.strong, bg = p.panel },
    FloatTitle = { fg = p.bronze, bg = p.panel, bold = true },
    Cursor = { fg = p.ground, bg = p.bronze },
    TermCursor = { link = "Cursor" },
    CursorLine = { bg = p.panel },
    ColorColumn = { bg = p.panel },
    CursorLineNr = { fg = p.bronze, bold = true },
    LineNr = { fg = p.label },
    SignColumn = { bg = p.ground },
    Folded = { fg = p.label, bg = p.inset },
    WinSeparator = { fg = p.line },
    StatusLine = { fg = p.ink, bg = p.inset },
    StatusLineNC = { fg = p.label, bg = p.panel },
    TabLine = { fg = p.label, bg = p.panel },
    TabLineFill = { bg = p.panel },
    TabLineSel = { fg = p.ink, bg = p.ground, bold = true },
    Visual = { bg = p.strong },
    Search = { fg = p.ink, bg = p.inset, underline = true, sp = p.bronze },
    IncSearch = { fg = p.ground, bg = p.bronze },
    CurSearch = { link = "IncSearch" },
    MatchParen = { fg = p.bronze, bold = true, underline = true },
    Pmenu = { fg = p.ink, bg = p.panel },
    PmenuSel = { fg = p.ink, bg = p.strong, bold = true },
    PmenuThumb = { bg = p.strong },
    PmenuMatch = { fg = p.bronze },
    NonText = { fg = p.line },
    Whitespace = { fg = p.line },
    EndOfBuffer = { fg = p.ground },
    Directory = { fg = p.dykem },
    Title = { fg = p.bronze, bold = true },
    ErrorMsg = { fg = p.bronze, bold = true },
    WarningMsg = { fg = p.amber },
    MoreMsg = { fg = p.dykem },
    ModeMsg = { fg = p.bronze, bold = true },
    Question = { fg = p.dykem },
    SpellBad = { undercurl = true, sp = p.bronze },
    SpellCap = { undercurl = true, sp = p.dykem },

    -- syntax
    Comment = { fg = p.annot, italic = true },
    Constant = { fg = p.violet },
    String = { fg = p.dykem_light },
    Character = { fg = p.dykem_light },
    Number = { fg = p.violet },
    Boolean = { fg = p.violet },
    Identifier = { fg = p.ink },
    Function = { fg = p.ink },
    Statement = { fg = p.bronze },
    Keyword = { fg = p.bronze },
    PreProc = { fg = p.bronze },
    Operator = { fg = p.label },
    Type = { fg = p.dykem },
    Special = { fg = p.dykem },
    SpecialChar = { fg = p.violet },
    Delimiter = { fg = p.label },
    Tag = { fg = p.bronze },
    Underlined = { fg = p.dykem_light, underline = true },
    Error = { fg = p.bronze },
    Todo = { fg = p.amber, bold = true },
    Added = { fg = p.verdigris },
    Removed = { fg = p.bronze },
    Changed = { fg = p.amber },

    -- treesitter: only where it departs from the links above
    ["@variable"] = { fg = p.ink },
    ["@variable.builtin"] = { fg = p.dykem, italic = true },
    ["@property"] = { fg = p.ink },
    ["@module"] = { fg = p.dykem },
    ["@constructor"] = { fg = p.dykem },
    ["@punctuation"] = { fg = p.label },
    ["@string.escape"] = { fg = p.violet },
    ["@string.regexp"] = { fg = p.violet },
    ["@tag.attribute"] = { fg = p.dykem },
    ["@markup.heading"] = { fg = p.bronze, bold = true },
    ["@markup.link.url"] = { fg = p.dykem_light, underline = true },
    ["@markup.raw"] = { fg = p.dykem_light },
    ["@markup.list"] = { fg = p.dykem },
    ["@comment.todo"] = { link = "Todo" },
    ["@comment.warning"] = { fg = p.amber, bold = true },
    ["@comment.error"] = { fg = p.bronze, bold = true },

    -- diagnostics: status is color plus text, and the sign carries the text
    DiagnosticError = { fg = p.bronze },
    DiagnosticWarn = { fg = p.amber },
    DiagnosticInfo = { fg = p.dykem },
    DiagnosticHint = { fg = p.dykem_light },
    DiagnosticOk = { fg = p.verdigris },
    DiagnosticUnderlineError = { undercurl = true, sp = p.bronze },
    DiagnosticUnderlineWarn = { undercurl = true, sp = p.amber },
    DiagnosticUnderlineInfo = { undercurl = true, sp = p.dykem },
    DiagnosticUnderlineHint = { undercurl = true, sp = p.dykem_light },
    DiagnosticUnnecessary = { fg = p.label },
    LspReferenceText = { bg = p.inset },
    LspReferenceRead = { bg = p.inset },
    LspReferenceWrite = { bg = p.inset, underline = true },
    LspInlayHint = { fg = p.label, bg = p.panel },

    -- diff / git
    DiffAdd = { bg = p.plus },
    DiffDelete = { fg = p.bronze, bg = p.minus },
    DiffChange = { bg = p.panel },
    DiffText = { bg = p.inset, underline = true, sp = p.amber },
    GitSignsAdd = { fg = p.verdigris },
    GitSignsChange = { fg = p.amber },
    GitSignsDelete = { fg = p.bronze },
  }
  for name, spec in pairs(groups) do vim.api.nvim_set_hl(0, name, spec) end
  for i, c in ipairs(p.ansi) do vim.g["terminal_color_" .. (i - 1)] = c end
end

return {
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = toolpath },
  },
}
