import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    environment: "node",
    include: ["tests/**/*.test.ts"],
    // Los tests de API comparten la base dev: uno a la vez
    fileParallelism: false,
    testTimeout: 20000,
    hookTimeout: 30000,
  },
});
