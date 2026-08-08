# Android Build & Export (Overview)

This document contains the steps to prepare your environment and export an Android App Bundle (.aab) from Godot 4.

1) Install Godot 4.x
   - Download the editor from https://godotengine.org

2) Install Android SDK (Command-line tools)
   - Install Android Studio or the command-line sdkmanager.
   - Ensure "Android SDK Platform 33" (or matching target) is installed along with build-tools.

3) Install Java JDK
   - JDK 11+ is recommended. Set JAVA_HOME accordingly.

4) Godot Android export templates
   - In Godot Editor: Editor > Manage Export Templates and install the official 4.x export templates.

5) Configure Godot Android settings
   - Project > Project Settings > Android
   - Set package/identifier (e.g., `com.yourstudio.africarush`)
   - Set version and version_code
   - Provide path to SDK, JDK, and Android SDK tools in Editor > Editor Settings > Export > Android

6) Creating a release keystore (manual step)
   - Use `keytool` to create a keystore. Do NOT commit your keystore.
   - Example:
     keytool -genkeypair -v -keystore release_key.jks -alias africarush -keyalg RSA -keysize 2048 -validity 10000

7) Exporting AAB
   - In Godot: Project > Export > Add Android
   - Configure signing (select keystore) and export as .aab

8) Test the AAB on a device or with bundletool before uploading to Play Console.

Sensitive files like keystores or passwords must never be committed. See docs/play_store.md for Play Store checklist.
