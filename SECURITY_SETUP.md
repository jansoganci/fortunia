# 🔐 Security Setup Guide

## ⚠️ CRITICAL: Never commit secrets to version control!

This guide explains how to properly configure your Fortunia app with secure credential management.

## 🚨 Security Issue Fixed

**Problem:** Hardcoded Supabase credentials were exposed in the codebase.  
**Solution:** Implemented environment-based configuration with proper .gitignore rules.

## 📋 Setup Instructions

### 1. Create Info.plist Configuration

Copy the example file and add your actual credentials:

```bash
cp fortunia/fortunia/Info.plist.example fortunia/fortunia/Info.plist
```

### 2. Add Your Supabase Credentials

Edit `fortunia/fortunia/Info.plist` and replace the placeholder:

```xml
<key>SUPABASE_ANON_KEY</key>
<string>YOUR_ACTUAL_SUPABASE_ANON_KEY_HERE</string>
```

### 3. Environment Variables (Optional)

For CI/CD or advanced setups, you can also use environment variables:

```bash
export SUPABASE_ANON_KEY="your_actual_key_here"
```

## 🔒 Security Best Practices

### ✅ DO:
- Use environment variables or Info.plist for secrets
- Keep `Info.plist` in `.gitignore` (already configured)
- Use `Info.plist.example` as a template
- Rotate keys regularly
- Use different keys for development/production

### ❌ DON'T:
- Hardcode secrets in source code
- Commit `Info.plist` with real credentials
- Share credentials in documentation
- Use production keys in development

## 🛠️ Development Workflow

1. **Clone repository**
2. **Copy Info.plist.example to Info.plist**
3. **Add your actual Supabase credentials**
4. **Build and run the app**

## 🚀 Production Deployment

For production builds, use environment variables:

```bash
export SUPABASE_ANON_KEY="production_key_here"
xcodebuild -scheme fortunia -configuration Release
```

## 🔍 Verification

To verify your setup is secure:

1. Check that `Info.plist` is in `.gitignore`
2. Verify no hardcoded secrets in source code
3. Test that app builds and runs with your credentials

## 📞 Support

If you need help with security setup, contact: support@fortunia.app

---

**Remember:** Security is everyone's responsibility. When in doubt, ask for help rather than taking shortcuts.
