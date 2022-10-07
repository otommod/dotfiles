local function ensure_installed(repo_url)
  local plugin_name = vim.fn.fnamemodify(repo_url, ":t")
  local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/" .. plugin_name
  if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.fn.system({"git", "clone", repo_url, install_path})
  end
end

ensure_installed("https://github.com/wbthomason/packer.nvim")
ensure_installed("https://github.com/rktjmp/hotpot.nvim")

require("hotpot").setup {
  compiler = {
    modules = {
      useBitLib = true,
    },
  },
}

require("rc")
