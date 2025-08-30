-- mod-version:3
--- Keeps track of your jumps (in the file or between files) and let
--- you quickly navigate trought your jump history

local core = require "core"
local command = require "core.command"
local common = require "core.common"
local Doc = require "core.doc"
local keymap = require "core.keymap"


local movestory = {}
movestory.hist = {}
movestory.pos = 0
movestory.len = 0

local doc_set_selection = Doc.set_selection

local function get_last()
  if movestory.pos == 0 or movestory.pos > #movestory.hist then
    return nil
  end
  return movestory.hist[movestory.pos]
end

local function eq(a, b)
  if a ~= nil and b ~= nil then
    return a[1] == b[1] and (
      (a[7] == b[7] and a[3] == b[3] and a[4] == b[4] and a[5] == b[5] and a[6] == b[6]) or
      (a[7] ~= b[7] and a[3] == a[5] and a[4] == b[6] and a[5] == b[3] and a[6] == b[5])
    )
  end
  return a == b
end

local function finite(num)
  return num ~= math.huge
end

function movestory.jump_to(pos)
  local doc = pos[1]
  local doc_view = core.root_view:open_doc(
    core.open_doc(
      common.home_expand(
        doc:get_name()
      )
    )
  )
  local idx, line1, col1, line2, col2, swap = pos[2], pos[3], pos[4], pos[5], pos[6], pos[7]
  doc_set_selection(doc_view.doc, idx, line1, col1, line2, col2, swap)
end

local function add_to_hist(pos)
  local old = get_last()
  if finite(pos[3]) and not eq(pos, old) then
    table.insert(movestory.hist, movestory.pos + 1, pos)
    movestory.pos = movestory.pos + 1
    movestory.len = movestory.pos
  end
end


function Doc:set_selection(idx, line1, col1, line2, col2, swap)
  local pos = { self, idx, line1, col1, line2, col2, swap }
  add_to_hist(pos)
  return doc_set_selection(self, idx, line1, col1, line2, col2, swap)
end

function movestory.prev()
  if movestory.pos > 1 then
    movestory.pos = movestory.pos - 1
    local p = movestory.hist[movestory.pos]
    movestory.jump_to(p)
  end
end

function movestory.next()
  if movestory.pos < movestory.len then
    movestory.pos = movestory.pos + 1
    local p = movestory.hist[movestory.pos]
    movestory.jump_to(p)
  end
end

command.add(nil, {
  ["movestory:prev"] = movestory.prev,
  ["movestory:next"] = movestory.next,
})

keymap.add {
  ["alt+left"] = "movestory:prev",
  ["alt+right"] = "movestory:next",
}

return movestory
