table.insert(default_access.rules, {
   matches = {
   {
     { "application.process.binary", "=", "electron" },
     { "application.process.binary", "=", "webcord" },
     { "application.process.binary", "=", "firefox" }
     { "application.process.binary", "=", "legcord" }
     { "application.process.binary", "=", "vesktop" }
     { "application.process.binary", "=", "abaddon" }
   }
   },
   default_permissions = "rx",
})
