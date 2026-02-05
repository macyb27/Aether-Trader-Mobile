import * as Linking from "expo-linking";
import * as ReactNative from "react-native";

// Extract scheme from bundle ID (last segment timestamp, prefixed with "manus")
// e.g., "space.manus.my.app.t20240115103045" -> "manus20240115103045"
const bundleId = "space.manus.easygeld.pro.t20260107222939";
const timestamp = bundleId.split(".").pop()?.replace(/^t/, "") ?? "";
const schemeFromBundleId = `manus${timestamp}`;

const env = {
  portal: process.env.EXPO_PUBLIC_OAUTH_PORTAL_URL ?? "",
  server: process.env.EXPO_PUBLIC_OAUTH_SERVER_URL ?? "",
  appId: process.env.EXPO_PUBLIC_APP_ID ?? "",
  ownerId: process.env.EXPO_PUBLIC_OWNER_OPEN_ID ?? "",
  ownerName: process.env.EXPO_PUBLIC_OWNER_NAME ?? "",
  apiBaseUrl: process.env.EXPO_PUBLIC_API_BASE_URL ?? "",
  deepLinkScheme: schemeFromBundleId,
};

export const OAUTH_PORTAL_URL = env.portal;
export const OAUTH_SERVER_URL = env.server;
export const APP_ID = env.appId;
export const OWNER_OPEN_ID = env.ownerId;
export const OWNER_NAME = env.ownerName;
export const API_BASE_URL = env.apiBaseUrl;

/**
 * Get the API base URL for network requests.
 *
 * Resolution order:
 * 1. EXPO_PUBLIC_API_BASE_URL env var (recommended for production APK builds)
 * 2. Web: derive from current hostname (development convenience)
 * 3. Empty string (app runs in offline / local-only mode)
 *
 * For standalone APK builds, set EXPO_PUBLIC_API_BASE_URL to your production
 * API server URL (e.g. "https://api.example.com").
 */
export function getApiBaseUrl(): string {
  // If API_BASE_URL is set, use it (production / standalone builds should use this)
  if (API_BASE_URL) {
    return API_BASE_URL.replace(/\/$/, "");
  }

  // Native platforms (Android/iOS) - require explicit API URL configuration
  if (ReactNative.Platform.OS !== "web") {
    // For standalone APK builds without a configured API URL,
    // the app operates in offline mode with local data only.
    console.warn(
      "[OAuth] No API_BASE_URL configured for native platform. " +
      "The app will run in offline mode. " +
      "Set EXPO_PUBLIC_API_BASE_URL for full backend connectivity."
    );
    return "";
  }

  // On web, try to derive from current hostname for development convenience.
  // This handles both sandbox (8081-sandboxid -> 3000-sandboxid) and
  // standard localhost (localhost:8081 -> localhost:3000) patterns.
  if (typeof window !== "undefined" && window.location) {
    const { protocol, hostname, port } = window.location;

    // Standard localhost development: Metro on 8081, API on 3000
    if (hostname === "localhost" || hostname === "127.0.0.1") {
      if (port === "8081") {
        return `${protocol}//${hostname}:3000`;
      }
    }

    // Cloud / hosted development environment pattern:
    // 8081-<id>.<region>.<domain> -> 3000-<id>.<region>.<domain>
    const apiHostname = hostname.replace(/^8081-/, "3000-");
    if (apiHostname !== hostname) {
      return `${protocol}//${apiHostname}`;
    }
  }

  // Fallback to empty (will use relative URL or offline mode)
  return "";
}

export const SESSION_TOKEN_KEY = "app_session_token";
export const USER_INFO_KEY = "app_user_info";

const encodeState = (value: string) => {
  if (typeof globalThis.btoa === "function") {
    return globalThis.btoa(value);
  }
  const BufferImpl = (globalThis as Record<string, any>).Buffer;
  if (BufferImpl) {
    return BufferImpl.from(value, "utf-8").toString("base64");
  }
  return value;
};

export const getLoginUrl = () => {
  let redirectUri: string;

  if (ReactNative.Platform.OS === "web") {
    // Web platform: redirect to API server callback (not Metro bundler)
    // The API server will then redirect back to the frontend with the session token
    redirectUri = `${getApiBaseUrl()}/api/oauth/callback`;
  } else {
    // Native platform: use deep link scheme for mobile OAuth callback
    // This allows the OS to redirect back to the app after authentication
    redirectUri = Linking.createURL("/oauth/callback", {
      scheme: env.deepLinkScheme,
    });
  }

  const state = encodeState(redirectUri);

  const url = new URL(`${OAUTH_PORTAL_URL}/app-auth`);
  url.searchParams.set("appId", APP_ID);
  url.searchParams.set("redirectUri", redirectUri);
  url.searchParams.set("state", state);
  url.searchParams.set("type", "signIn");

  return url.toString();
};
