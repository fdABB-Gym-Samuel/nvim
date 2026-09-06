-- On NixOS Mason's prebuilt binaries can't run (no global dynamic linker),
-- so it is disabled entirely. Every LSP/linter/formatter comes from the
-- flake instead (see flake.nix) and is found on $PATH.
return {
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },
}
