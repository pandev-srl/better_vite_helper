import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { defineConfig } from "vite";

const __dirname = dirname(fileURLToPath(import.meta.url));

export default defineConfig({
  publicDir: false, // avoid conflicts with outDir
  emptyOutDir: true,
  css: {
    devSourcemap: true,
  },

  server: {
    port: 5173,
    host: "0.0.0.0",
    cors: true,
    hmr: {
      port: 5173,
    },
  },

  build: {
    outDir: "public/assets",
    manifest: true,
    sourcemap: true,
    emptyOutDir: true,

    rollupOptions: {
      input: {
        application: resolve(
          __dirname,
          "app/javascript/application.js"
        ),
      },
      output: {
        entryFileNames: "application-[hash].js",
        assetFileNames: (info) => {
          if (info.name?.endsWith(".css")) {
            return "application-[hash][extname]";
          }
          return "[name]-[hash][extname]";
        },
      },
      external: [],
    },
  },
});
