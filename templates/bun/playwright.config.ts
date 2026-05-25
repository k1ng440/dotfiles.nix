import { defineConfig } from "@playwright/test";

export default defineConfig({
  use: {
    launchOptions: {
      executablePath: process.env.PLAYWRIGHT_LAUNCH_OPTIONS_EXECUTABLE_PATH,
    },
  },
});
