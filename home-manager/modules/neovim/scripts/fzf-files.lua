local function fzf_files()
  local cmd = "rg --files | fzf --preview='file-preview {}'"
  local handle = io.popen(cmd)
  local result = handle:read("*a")
  handle:close()
  if result and result ~= "" then
    result = result:gsub("\n$", "")
    vim.cmd("edit " .. vim.fn.fnameescape(result))
  end
end

return fzf_files