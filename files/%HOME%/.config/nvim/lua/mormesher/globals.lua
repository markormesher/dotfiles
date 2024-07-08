cmd = vim.cmd
keymap = vim.keymap

check_plugin = function(name)
  plugin_ok, plugin = pcall(require, name)
  if (not plugin_ok) then
    vim.notify("Plugin '" .. name .. "' is not available", "error")
  end
  return plugin_ok, plugin
end
