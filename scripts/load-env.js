/**
 * Custom environment loader that prioritizes system environment variables
 * over .env file values. This ensures that platform-injected variables
 * (CI, EAS Build, hosting platforms) are not overridden by placeholder
 * values in .env files.
 *
 * This script is imported at the top of app.config.ts so that Expo
 * picks up the correct environment when resolving the config.
 */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const envPath = path.resolve(process.cwd(), ".env");

if (fs.existsSync(envPath)) {
  const envContent = fs.readFileSync(envPath, "utf8");
  const lines = envContent.split("\n");

  lines.forEach((line) => {
    // Skip comments and empty lines
    if (!line || line.trim().startsWith("#")) return;

    const match = line.match(/^([^=]+)=(.*)$/);
    if (match) {
      const key = match[1].trim();
      const value = match[2].trim().replace(/^["']|["']$/g, ""); // Remove quotes

      // Only set if not already defined in environment (system env takes priority)
      if (!process.env[key]) {
        process.env[key] = value;
      }
    }
  });
}

// Map common environment variable names to Expo public variables.
// This allows CI/CD systems and hosting platforms to use their own
// naming conventions while still feeding into Expo's public env vars.
const mappings = {
  // OAuth / Auth
  VITE_APP_ID: "EXPO_PUBLIC_APP_ID",
  VITE_OAUTH_PORTAL_URL: "EXPO_PUBLIC_OAUTH_PORTAL_URL",
  OAUTH_SERVER_URL: "EXPO_PUBLIC_OAUTH_SERVER_URL",
  OWNER_OPEN_ID: "EXPO_PUBLIC_OWNER_OPEN_ID",
  OWNER_NAME: "EXPO_PUBLIC_OWNER_NAME",
  // API
  API_BASE_URL: "EXPO_PUBLIC_API_BASE_URL",
};

for (const [systemVar, expoVar] of Object.entries(mappings)) {
  if (process.env[systemVar] && !process.env[expoVar]) {
    process.env[expoVar] = process.env[systemVar];
  }
}
