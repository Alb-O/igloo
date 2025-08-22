local function fzf_grep()
  local script = [[
    RELOAD='reload:rg --column --color=always --smart-case {q} || :'
    fzf --disabled --ansi --multi \
        --bind "start:$RELOAD" --bind "change:$RELOAD" \
        --bind "enter:become:echo {1}:{2}" \
        --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview' \
        --delimiter : \
        --preview 'file-preview {1}:{2}' \
        --preview-window '+{2}/2'
  ]]
  local handle = io.popen("bash -c " .. vim.fn.shellescape(script))
  local result = handle:read("*a")
  handle:close()
  if result and result ~= "" then
    result = result:gsub("\n$", "")
    local parts = vim.split(result, ":")
    if #parts >= 2 then
      local file = parts[1]
      local line = tonumber(parts[2])
      vim.cmd("edit " .. vim.fn.fnameescape(file))
      if line then
        vim.api.nvim_win_set_cursor(0, {line, 0})
      end
    end
  end
end

return fzf_grep