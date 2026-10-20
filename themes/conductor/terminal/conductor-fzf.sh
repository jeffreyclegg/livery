# ============================================================
# CONDUCTOR · MOFFAT — fzf
# The build machine's theme, Rev H. JDC.
#
# Source from ~/.zshrc or ~/.bashrc. Appends to FZF_DEFAULT_OPTS, so
# set any layout options before this.
#
# Matched characters are sodium: the figure you were looking for.
# The cursor line sits on the inset with sodium marks. A marked item is
# CLEAR (brunswick). Counts and headers are hudson: measurement.
# The faintest ink tier is not used: everything here is a label.
# ============================================================

export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
--color=fg:#DADBDE,bg:#130B0B,hl:#F2A33C \
--color=fg+:#DADBDE,bg+:#241817,hl+:#F2A33C:bold \
--color=info:#A9B3C1,header:#A9B3C1,label:#A4A6AB \
--color=prompt:#F2A33C,pointer:#F2A33C,spinner:#F2A33C,marker:#7DB592 \
--color=border:#352423,separator:#352423,scrollbar:#4D3532,gutter:#130B0B \
--color=query:#DADBDE,disabled:#A4A6AB \
--color=preview-fg:#DADBDE,preview-bg:#130B0B,preview-border:#352423"

# Stainless. Use this block instead of the one above on a light terminal.
# The cursor line is the panel (raised), not the inset: sodium on the
# inset measures 4.2:1, on the panel it clears 4.7.
# export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
# --color=fg:#16181C,bg:#DDE0E2,hl:#8C5306 \
# --color=fg+:#16181C,bg+:#EAECED,hl+:#8C5306:bold \
# --color=info:#3F5468,header:#3F5468,label:#454B53 \
# --color=prompt:#8C5306,pointer:#8C5306,spinner:#8C5306,marker:#2A5E41 \
# --color=border:#BCC1C5,separator:#BCC1C5,scrollbar:#969CA2,gutter:#DDE0E2 \
# --color=query:#16181C,disabled:#454B53 \
# --color=preview-fg:#16181C,preview-bg:#DDE0E2,preview-border:#BCC1C5"
