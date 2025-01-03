table.insert(default_access.rules, {
   matches = {
   {
     { "application.process.binary", "=", "electron" },
     { "application.process.binary", "=", "firefox" }
     { "application.process.binary", "=", "vesktop" }
   }
   },
   default_permissions = "rx",
})
