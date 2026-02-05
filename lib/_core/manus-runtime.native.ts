/**
 * Manus Runtime (native) - NO-OP implementation for standalone APK/iOS builds.
 *
 * The full Manus iframe/container integration is only relevant on web previews.
 * For native builds we intentionally export no-op functions so the app can be
 * built and run completely outside any sandbox/container environment.
 */

import type { Metrics } from "react-native-safe-area-context";

type SafeAreaCallback = (metrics: Metrics) => void;

/**
 * Native builds do not receive safe area insets from a parent iframe.
 */
export function subscribeSafeAreaInsets(_callback: SafeAreaCallback): () => void {
  return () => {};
}

/**
 * Native builds do not have a parent container to notify.
 */
export function initManusRuntime(): void {
  // no-op
}

/**
 * Native builds are never running in the web preview iframe.
 */
export function isRunningInPreviewIframe(): boolean {
  return false;
}

