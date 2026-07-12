local last_leader_j_cmd = nil
local last_test_filename = nil

local function get_test_file()
  local file = vim.fn.expand("%:t")
  if file:match("%.test%.") or file:match("%.spec%.") then
    last_test_filename = file
    return file
  end
  if last_test_filename then
    vim.notify("Using previous test file: " .. last_test_filename, vim.log.levels.INFO)
    return last_test_filename
  end
  vim.notify("No test/spec file found", vim.log.levels.WARN)
  return nil
end

local function tmux_run(target, test_cmd)
  last_leader_j_cmd = string.format(
    'tmux send-keys -t %q C-c && tmux send-keys -t %q %q C-m && tmux select-window -t %q',
    target, target, "clear && " .. test_cmd, target
  )
  os.execute(last_leader_j_cmd)
end

local function run_test(window, cmd)
  local file = get_test_file()
  if not file then return end
  local repo_root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
  if not repo_root or repo_root == "" then repo_root = vim.fn.getcwd() end
  local session = vim.fn.fnamemodify(repo_root, ":t")
  tmux_run(string.format("=%s:%s", session, window), cmd .. " " .. file)
end

vim.keymap.set("n", "<leader>jf", function() run_test("test", "npx vitest run --no-coverage") end, { desc = "Vitest: run file" })
vim.keymap.set("n", "<leader>je", function() run_test("e2e", "npx playwright test --project=chromium --no-deps") end, { desc = "Playwright: run file" })
vim.keymap.set("n", "<leader>jh", function() run_test("e2e", "npx playwright test --project=chromium --no-deps --headed --workers 1 --timeout 0") end, { desc = "Playwright: headed" })
vim.keymap.set("n", "<leader>jd", function() run_test("e2e", "npx playwright test --project=chromium --no-deps --debug inspector") end, { desc = "Playwright: debug" })
vim.keymap.set("n", "<leader>j.", function()
  if last_leader_j_cmd then
    os.execute(last_leader_j_cmd)
  else
    vim.notify("No previous <leader>j command to repeat", vim.log.levels.WARN)
  end
end, { desc = "Repeat last <leader>j command" })
