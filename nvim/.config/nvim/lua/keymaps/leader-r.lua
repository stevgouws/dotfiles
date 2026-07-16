local function repo_root()
  local filepath = vim.fn.expand("%:p")
  local start = filepath ~= "" and filepath or vim.fn.getcwd()
  local root = vim.fs.root(start, ".git")

  if not root then
    vim.notify("Not in a Git repository", vim.log.levels.WARN)
  end

  return root
end

local function git_commit(root, revision)
  local result = vim.system(
    { "git", "rev-parse", "--verify", revision .. "^{commit}" },
    { cwd = root, text = true }
  ):wait()

  if result.code ~= 0 then return nil end
  return vim.trim(result.stdout)
end

local function open_with_gh(root, args, failure_message)
  vim.system(args, { cwd = root, text = true }, vim.schedule_wrap(function(result)
    if result.code ~= 0 then
      local detail = vim.trim(result.stderr)
      vim.notify(detail ~= "" and detail or failure_message, vim.log.levels.ERROR)
    end
  end))
end

local function copy_commit_url(root, commit)
  local result = vim.system(
    { "gh", "browse", commit, "--no-browser" },
    { cwd = root, text = true }
  ):wait()

  if result.code ~= 0 then
    local detail = vim.trim(result.stderr)
    vim.notify(detail ~= "" and detail or "Could not resolve commit URL", vim.log.levels.ERROR)
    return
  end

  local url = vim.trim(result.stdout)
  vim.fn.setreg("+", url)
  vim.notify("Copied commit URL: " .. url, vim.log.levels.INFO)
end

local function open_file_on_remote(start_line, end_line)
  local filepath = vim.fn.expand("%:p")
  if filepath == "" then
    vim.notify("Current buffer has no filepath", vim.log.levels.WARN)
    return
  end

  local root = repo_root()
  if not root then return end

  local relative_path = vim.fs.relpath(root, filepath)
  local commit = git_commit(root, "HEAD")
  if not relative_path or not commit then
    vim.notify("Could not resolve file location", vim.log.levels.WARN)
    return
  end

  vim.system(
    { "gh", "browse", relative_path, "--commit=" .. commit, "--no-browser" },
    { cwd = root, text = true },
    vim.schedule_wrap(function(result)
      if result.code ~= 0 then
        local detail = vim.trim(result.stderr or "")
        vim.notify(detail ~= "" and detail or "Could not open file", vim.log.levels.ERROR)
        return
      end

      local line_fragment = ""
      if start_line and end_line then
        line_fragment = start_line == end_line
            and string.format("#L%d", start_line)
            or string.format("#L%d-L%d", start_line, end_line)
      end
      local _, error = vim.ui.open(vim.trim(result.stdout) .. line_fragment)
      if error then vim.notify(error, vim.log.levels.ERROR) end
    end)
  )
end

vim.keymap.set("n", "<leader>rc", function()
  local root = repo_root()
  if not root then return end

  local commit = git_commit(root, "HEAD")
  if not commit then
    vim.notify("Could not resolve HEAD commit", vim.log.levels.WARN)
    return
  end

  copy_commit_url(root, commit)
end, { desc = "Remote: copy HEAD commit URL" })

vim.keymap.set("n", "<leader>rC", function()
  local filepath = vim.fn.expand("%:p")
  if filepath == "" then
    vim.notify("Current buffer has no filepath", vim.log.levels.WARN)
    return
  end

  local root = repo_root()
  if not root then return end

  local relative_path = vim.fs.relpath(root, filepath)
  if not relative_path then
    vim.notify("Could not resolve relative path", vim.log.levels.WARN)
    return
  end

  local line = vim.fn.line(".")
  local result = vim.system({
    "git", "blame", "--porcelain", "-L", string.format("%d,%d", line, line), "--", relative_path,
  }, { cwd = root, text = true }):wait()
  local commit = result.stdout and result.stdout:match("^([0-9a-fA-F]+)")

  if result.code ~= 0 or not commit then
    vim.notify("Could not find a commit for the current line", vim.log.levels.WARN)
    return
  end

  if commit:match("^0+$") then
    vim.notify("Current line has not been committed", vim.log.levels.WARN)
    return
  end

  copy_commit_url(root, commit)
end, { desc = "Remote: copy current line commit URL" })

vim.keymap.set("n", "<leader>rf", function()
  open_file_on_remote()
end, { desc = "Remote: open file" })

vim.keymap.set("x", "<leader>rf", function()
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  open_file_on_remote(math.min(start_line, end_line), math.max(start_line, end_line))
end, { desc = "Remote: open file at selected lines" })

vim.keymap.set("n", "<leader>rp", function()
  local root = repo_root()
  if not root then return end

  open_with_gh(root, { "gh", "pr", "view", "--web" }, "Could not open pull request")
end, { desc = "Remote: open pull request" })

vim.keymap.set("n", "<leader>rP", function()
  local root = repo_root()
  if not root then return end

  open_with_gh(root, { "gh", "pr", "list", "--web" }, "Could not open pull requests")
end, { desc = "Remote: open pull requests" })

vim.keymap.set("n", "<leader>rr", function()
  local root = repo_root()
  if not root then return end

  open_with_gh(root, { "gh", "browse" }, "Could not open repository")
end, { desc = "Remote: open repository" })
