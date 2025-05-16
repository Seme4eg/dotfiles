-- to figure out the binary process name:
-- pw-cli list-objects
-- Look for the client ID that corresponds to the application you need
-- pw-cli info <client-id> <- and here you will find the binary stat

table.insert(default_access.rules, {
  matches = {
    {
      { "application.process.binary", "=", "electron" },
      { "application.process.binary", "=", "firefox" }
    }
  },
  default_permissions = "rx",
})
