# 📱 APK Build & Installation Guide

## ✅ **Debug APK Created Successfully!**

Your APK is located at:
```
d:\Switch To Future\Apps\fans-food-orders\build\app\outputs\flutter-apk\app-debug.apk
```

---

## 📲 **How to Install the APK**

### **Method 1: Direct Install (Recommended)**

1. **Connect your Android device** via USB
2. **Enable USB Debugging** on your phone:
   - Settings → About Phone → Tap "Build Number" 7 times
   - Settings → Developer Options → Enable "USB Debugging"
3. **Install using Flutter:**
   ```bash
   flutter install
   ```

### **Method 2: Transfer & Install**

1. **Copy the APK** to your phone:
   - Via USB cable → Copy `app-debug.apk` to Downloads folder
   - Or email it to yourself
   - Or use Google Drive/Dropbox

2. **Install on phone:**
   - Open the APK file
   - Tap "Install"
   - If blocked: Settings → Security → Enable "Unknown Sources"

---

## 🔐 **For Production Release APK**

If you want a **signed release APK** for distribution:

### **Step 1: Create a Keystore**

Run this command:
```bash
keytool -genkey -v -keystore d:\fans-food-order-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias fans-food-order
```

**Enter when prompted:**
- Password: (choose a strong password)
- Name: Your name
- Organization: Your company
- City, State, Country: Your location

### **Step 2: Create key.properties**

Create file: `d:\Switch To Future\Apps\fans-food-orders\android\key.properties`

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=fans-food-order
storeFile=d:\\fans-food-order-key.jks
```

### **Step 3: Update android/app/build.gradle**

Add before `android {` block:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Add inside `android {` block:
```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}

buildTypes {
    release {
        signingConfig signingConfigs.release
        minifyEnabled true
        shrinkResources true
    }
}
```

### **Step 4: Build Signed Release APK**

```bash
flutter build apk --release
```

---

## 🐛 **Troubleshooting**

### **"App not installed" or "Package appears to be invalid"**

**Solutions:**

1. **Uninstall old version first:**
   - Settings → Apps → Fan Munch → Uninstall
   - Then install new APK

2. **Use debug APK for testing:**
   ```bash
   flutter build apk --debug
   ```

3. **Check storage space:**
   - Make sure phone has enough space (at least 200MB free)

4. **Enable Unknown Sources:**
   - Settings → Security → Unknown Sources → Enable

5. **Try installing via ADB:**
   ```bash
   adb install build\app\outputs\flutter-apk\app-debug.apk
   ```

### **"Signature mismatch"**

This happens when trying to install over an existing app with different signature.

**Solution:**
- Uninstall the old app completely
- Then install the new APK

---

## 📊 **APK Types Comparison**

| Type | Command | Size | Use Case |
|------|---------|------|----------|
| **Debug** | `flutter build apk --debug` | ~75MB | Testing, development |
| **Release** | `flutter build apk --release` | ~40MB | Production, distribution |
| **Split APKs** | `flutter build apk --split-per-abi` | ~20MB each | Play Store (smaller downloads) |

---

## 🚀 **Quick Commands**

### **Build Debug APK:**
```bash
flutter build apk --debug
```

### **Build Release APK:**
```bash
flutter build apk --release
```

### **Build Split APKs (smaller size):**
```bash
flutter build apk --split-per-abi
```

### **Install to connected device:**
```bash
flutter install
```

### **Build and Install:**
```bash
flutter build apk --debug && flutter install
```

---

## 📁 **APK Locations**

After building, find your APKs here:

- **Debug:** `build\app\outputs\flutter-apk\app-debug.apk`
- **Release:** `build\app\outputs\flutter-apk\app-release.apk`
- **Split (arm64):** `build\app\outputs\flutter-apk\app-arm64-v8a-release.apk`
- **Split (armeabi):** `build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk`
- **Split (x86_64):** `build\app\outputs\flutter-apk\app-x86_64-release.apk`

---

## ✅ **Current Status**

✅ **Debug APK built successfully!**
- Location: `build\app\outputs\flutter-apk\app-debug.apk`
- Size: ~75MB
- Ready to install

**Next Steps:**
1. Copy APK to your phone
2. Install and test
3. If everything works, create a signed release APK for production

---

## 💡 **Tips**

- **For testing:** Use debug APK (faster builds)
- **For distribution:** Use signed release APK (smaller, optimized)
- **For Play Store:** Use split APKs (best user experience)
- **Keep your keystore safe:** You'll need it for all future updates!

---

**Your debug APK is ready to install! 🎉**
