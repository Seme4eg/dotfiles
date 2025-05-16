table.insert(default_access.rules, {
  matches = {
    {
      { "application.process.binary", "=", "electron" },
      { "application.process.binary", "=", "firefox" }
    }
  },
  default_permissions = "rx",
})
