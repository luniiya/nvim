local M = {}

local state
local seed_info
local session_offset = 0
local seed_file = vim.fn.stdpath("state") .. "/theme_seed"

local function save_seed(info)
  local dir = vim.fn.fnamemodify(seed_file, ":h")
  vim.fn.mkdir(dir, "p")

  local ok, fd = pcall(io.open, seed_file, "w")
  if ok and fd then
    fd:write(string.format("%s|%d", info.date, info.offset))
    fd:close()
  end
end

local function load_seed()
  local today = os.date("%Y-%m-%d")

  if seed_info and seed_info.date == today then
    return seed_info
  end

  local offset = 1
  local fd = io.open(seed_file, "r")
  if fd then
    local contents = fd:read "*l"
    fd:close()
    if contents then
      local stored_date, stored_offset = contents:match("([^|]+)|([^|]+)")
      if stored_date == today then
        offset = tonumber(stored_offset) or 0
      end
    end
  end

  seed_info = { date = today, offset = offset }
  save_seed(seed_info)

  return seed_info
end

local function list_available_themes()
  local themes = {}
  local base46_dir = vim.fn.stdpath "data" .. "/lazy/base46/lua/base46/themes"
  local handle = vim.loop.fs_scandir(base46_dir)

  if handle then
    while true do
      local name = vim.loop.fs_scandir_next(handle)
      if not name then
        break
      end

      if name:sub(-4) == ".lua" then
        local theme = name:sub(1, -5)
        if theme ~= "init" then
          themes[#themes + 1] = theme
        end
      end
    end
  end

  table.sort(themes)

  if #themes == 0 then
    themes = { "onedark" }
  end

  return themes
end

local function copy_list(list)
  local result = {}
  for _, value in ipairs(list) do
    result[#result + 1] = value
  end
  return result
end

local function split_themes()
  local available = list_available_themes()
  local day, night = {}, {}

  local light_markers = { "light", "day", "latte", "dawn", "morning", "lotus", "sunrise" }

  for _, theme in ipairs(available) do
    local lower = theme:lower()
    local is_day = false

    for _, marker in ipairs(light_markers) do
      if lower:find(marker, 1, true) then
        is_day = true
        break
      end
    end

    if is_day then
      day[#day + 1] = theme
    else
      night[#night + 1] = theme
    end
  end

  if #day == 0 then
    day = copy_list(available)
  end

  if #night == 0 then
    night = copy_list(available)
  end

  return day, night
end

local function deterministic_index(pool, phase, seed, extra_offset)
  if #pool == 0 then
    return 1
  end
  local offset = (seed.offset or 0) + (extra_offset or 0)
  local date_key = string.format("%s:%s:%d", seed.date, phase, offset)
  local hash = vim.fn.sha256(date_key)
  local num = tonumber(hash:sub(1, 12), 16) or 0

  return (num % #pool) + 1
end

local function current_phase()
  local hour = tonumber(os.date "%H") or 12
  return (hour >= 7 and hour < 19) and "day" or "night"
end

local function compute()
  local phase = current_phase()
  local seed = load_seed()
  local day_themes, night_themes = split_themes()
  local main_pool = phase == "day" and day_themes or night_themes
  local secondary_pool = phase == "day" and night_themes or day_themes

  local extra_offset = session_offset

  local primary_idx = deterministic_index(main_pool, phase, seed, extra_offset)
  local secondary_phase = phase == "day" and "night" or "day"
  local secondary_idx = deterministic_index(secondary_pool, secondary_phase, seed, extra_offset)

  local primary = main_pool[primary_idx]
  local secondary = secondary_pool[secondary_idx]

  if primary == secondary and #secondary_pool > 1 then
    secondary_idx = (secondary_idx % #secondary_pool) + 1
    secondary = secondary_pool[secondary_idx]
  end

  vim.o.background = phase == "day" and "light" or "dark"

  state = {
    primary = primary,
    secondary = secondary,
    phase = phase,
    label = string.format(" %s (%s)", primary, phase),
    seed_date = seed.date,
    seed_offset = seed.offset,
  }

  vim.g.dynamic_theme_phase = state.phase
  vim.g.dynamic_theme_primary = state.primary
  vim.g.dynamic_theme_secondary = state.secondary
  vim.g.dynamic_theme_label = state.label

  return state
end

function M.ensure()
  if not state then
    compute()
  end
  return state
end

function M.setup()
  local info = compute()
  return info.primary, info.secondary
end

function M.shuffle()
  session_offset = session_offset + 1
  state = nil
  return compute()
end

function M.apply(theme)
  local ok, base46 = pcall(require, "base46")
  if ok and theme then
    vim.g.nvchad_theme = theme
    pcall(function()
      base46.load_all_highlights()
      vim.cmd.colorscheme(theme)
    end)
  end
end

function M.label()
  return M.ensure().label
end

function M.secondary()
  return M.ensure().secondary
end

function M.phase()
  return M.ensure().phase
end

return M
