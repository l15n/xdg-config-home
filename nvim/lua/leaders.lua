vim.g.mapleader = " "

vim.keymap.set("n", "<Leader>c", "<cmd>lua ColemakToggle()<cr>")
vim.keymap.set("n", "<Leader>ar", "<cmd>lua AutoreadToggle()<cr>")

-- Search functionality
vim.keymap.set("n", "<Leader>fs", "<cmd>lua SearchHlsearch()<cr>")
vim.keymap.set("v", "<Leader>fs", "<cmd>lua SearchVisualSelection()<cr>")
