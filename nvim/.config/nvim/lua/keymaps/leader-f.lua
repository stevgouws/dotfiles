local function copy(value, label)
  vim.fn.setreg("+", value)
  vim.notify("Copied " .. label .. ": " .. value, vim.log.levels.INFO)
end

vim.keymap.set("n", "<leader>fa", function()
  local filepath = vim.fn.expand("%:p")
  if filepath == "" then
    vim.notify("Current buffer has no filepath", vim.log.levels.WARN)
    return
  end

  copy(filepath, "absolute path")
end, { desc = "File: copy absolute path" })

vim.keymap.set("n", "<leader>ff", function()
  local filename = vim.fn.expand("%:t")
  if filename == "" then
    vim.notify("Current buffer has no filename", vim.log.levels.WARN)
    return
  end

  copy(filename, "filename")
end, { desc = "File: copy filename" })

vim.keymap.set("n", "<leader>fr", function()
  local filepath = vim.fn.expand("%:p")
  if filepath == "" then
    vim.notify("Current buffer has no filepath", vim.log.levels.WARN)
    return
  end

  local repo_root = vim.fs.root(filepath, ".git")
  if not repo_root then
    vim.notify("Current file is not in a Git repository", vim.log.levels.WARN)
    return
  end

  local relative_path = vim.fs.relpath(repo_root, filepath)
  if not relative_path then
    vim.notify("Could not resolve relative path", vim.log.levels.WARN)
    return
  end

  copy(relative_path, "relative path")
end, { desc = "File: copy relative path" })
