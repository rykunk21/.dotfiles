return {
	"AlphaTechnolog/pywal.nvim",
	config = function()
		require("pywal").setup({
			-- Specify the path to your pywal cache directory
			walPath = "~/.cache/wal/colors.json",
		})

	end
}
