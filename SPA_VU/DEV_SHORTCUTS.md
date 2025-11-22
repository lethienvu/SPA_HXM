# Paradise HR - Development Shortcuts

## 🔄 Clear Cache

### Quick Methods

| Action       | macOS              | Windows/Linux      |
| ------------ | ------------------ | ------------------ |
| Hard Refresh | `Cmd + Shift + R`  | `Ctrl + Shift + R` |
| Alternative  | `Cmd + Option + R` | `Ctrl + F5`        |

### Chrome DevTools Method

1. Open DevTools: `Cmd + Option + I` (Mac) / `F12` (Win)
2. **Right-click Reload** button → "Empty Cache and Hard Reload"

### Best for Development

1. Open DevTools: `Cmd + Option + I`
2. Settings (⚙️) → Check "Disable cache (while DevTools is open)"
3. Keep DevTools open while developing

## 🛠️ Useful DevTools Shortcuts

| Action          | macOS                        | Windows/Linux               |
| --------------- | ---------------------------- | --------------------------- |
| Open DevTools   | `Cmd + Option + I`           | `F12` or `Ctrl + Shift + I` |
| Console         | `Cmd + Option + J`           | `Ctrl + Shift + J`          |
| Elements        | `Cmd + Shift + C`            | `Ctrl + Shift + C`          |
| Network         | `Cmd + Option + I` → Network | Same                        |
| Command Palette | `Cmd + Shift + P`            | `Ctrl + Shift + P`          |
| Search Files    | `Cmd + P`                    | `Ctrl + P`                  |
| Search Code     | `Cmd + Shift + F`            | `Ctrl + Shift + F`          |

## 🎯 Development Tips

### Prevent Caching Issues

```javascript
// Icons có cache busting tự động trong dev mode
UI.icon.create("home"); // Tự động thêm ?v=timestamp
```

### Force Reload Script

```javascript
// Console command để reload page và clear cache
location.reload(true);
```

### Clear All Browser Data (Nuclear Option)

1. Chrome: `Cmd + Shift + Delete` (Mac) / `Ctrl + Shift + Delete` (Win)
2. Select "Cached images and files"
3. Time range: "All time"
4. Click "Clear data"

## 📱 Mobile/Responsive Testing

| Action                | Shortcut                                           |
| --------------------- | -------------------------------------------------- |
| Toggle Device Toolbar | `Cmd + Shift + M` (Mac) / `Ctrl + Shift + M` (Win) |
| Rotate Device         | `Cmd + Shift + M` then click rotate icon           |

## 🔍 Debugging

| Action       | Shortcut                           |
| ------------ | ---------------------------------- |
| Pause/Resume | `F8` or `Cmd + \`                  |
| Step Over    | `F10` or `Cmd + '`                 |
| Step Into    | `F11` or `Cmd + ;`                 |
| Step Out     | `Shift + F11` or `Cmd + Shift + ;` |

## 💾 VS Code Shortcuts (Helpful)

| Action          | macOS                | Windows/Linux      |
| --------------- | -------------------- | ------------------ |
| Save All        | `Cmd + K, S`         | `Ctrl + K, S`      |
| Format Document | `Shift + Option + F` | `Shift + Alt + F`  |
| Go to File      | `Cmd + P`            | `Ctrl + P`         |
| Command Palette | `Cmd + Shift + P`    | `Ctrl + Shift + P` |
| Multi-cursor    | `Option + Click`     | `Alt + Click`      |
| Find in Files   | `Cmd + Shift + F`    | `Ctrl + Shift + F` |

## 🚀 Live Server Tips

### Python HTTP Server (Current Setup)

```bash
# Start server
cd /Users/lethienvu/Source\ Code/SPA_HXM/SPA_VU
python3 -m http.server 8000

# View in browser
open http://localhost:8000/SPA_VU/
```

### Check if Port is in Use

```bash
lsof -ti:8000
```

### Kill Process on Port

```bash
lsof -ti:8000 | xargs kill -9
```

## 📝 Quick Console Commands

### Clear Console

```javascript
clear(); // or Cmd + K (Mac) / Ctrl + L (Win)
```

### Inspect Element

```javascript
inspect(document.querySelector(".paradise-icon"));
```

### Get all Paradise Icons

```javascript
UI.icon.list();
```

### Test Icon

```javascript
document.body.innerHTML += UI.icon.create("home", {
  size: "xl",
  color: "primary",
});
```

### Monitor Network

```javascript
performance.getEntriesByType("resource").forEach((r) => console.log(r.name));
```

## ⚡ Pro Tips

1. **Always keep DevTools open** during development (auto-disables cache)
2. **Use Cmd + Shift + P** in DevTools for command palette
3. **Network tab** → Check "Disable cache" checkbox
4. **Application tab** → Clear Storage → "Clear site data" for nuclear option
5. **Use incognito/private mode** for clean slate testing

---

**Quick Reference Card - Print This!**

```
HARD REFRESH:    Cmd + Shift + R  (Mac)  |  Ctrl + Shift + R  (Win)
DEVTOOLS:        Cmd + Option + I (Mac)  |  F12             (Win)
CONSOLE:         Cmd + Option + J (Mac)  |  Ctrl + Shift + J (Win)
DISABLE CACHE:   DevTools → Settings → ✓ Disable cache
```
