# 🔄 PowerShell Artifact Replacer

A project to **learn PowerShell** by automating the process of replacing artifact files with build files.

---

## 📘 About This Project

This is a small project based on one of our internal activities that involves a set of tasks following a **repetitive template**.  
As such, the conditions and practices used here may **not be suitable for real-world scenarios**.

The purpose of this project is:

- To **automate** a specific, repetitive process under defined conditions.
- To provide a space for **experimenting and learning PowerShell**.
- Fully focused on the **Windows environment**, as that's where these files are hosted.

---

## ⚙️ Setup Instructions

1. **Create a `config.json` file** in the root directory.
   - Use the `config.example.json` file as a reference.
   - You can simply rename `config.example.json` to `config.json` and update the paths accordingly.
   - Make sure to use **double backslashes (`\\`)** for all file paths inside the JSON.
   - Create a log folder and provide it's path in config
   - Example:
     ```json
     "buildPath": "C:\\build\\yourpath"
     ```

2. **Specify 7-Zip path (optional but recommended):**
   - If you have 7-Zip installed, add its path in the config.
   - This can **significantly reduce unzip time**.
   - Example:
     ```json
     "sevenZipPath": "C:\\Program Files\\7-Zip\\7z.exe"
     ```

3. **Do not change the following values** in the config file:
   ```json
   "SourceVersion": "1.0.0.0",
   "TargetVersion": "4.0.0.0"
   ```
---

## 🏃 How to Run

1. Just run artifact-manager.bat
2. Wait for the operation to be completed and check log file for details.

## 🚀 Optimizations & Observations

| Optimization                            | Impact                                      |
|----------------------------------------|---------------------------------------------|
| ✅ Replaced `Copy-Item` with `robocopy` | Saved ~3 minutes during folder cloning      |
| ✅ Used `7-Zip` over `Expand-Archive`   | Reduced unzipping time by ~2 minutes        |

> `Expand-Archive` is used as a fallback if 7-Zip is not available.

---

## 🧹 Useful Rollback Commands that helped for Debugging

### 🔁 Delete a version folder (example: 4.0.0.0 cloned from 1.0.0.0)

```powershell
Remove-Item -Path "$ArtifactFilesPath\*\4.0.0.0" -Recurse -Force
```

> Replace the path with your actual ArtifactFilesPath
> `Example:` C:\project\artifacts\*\4.0.0.0

### 🗑️ Delete unzipped build files (when .zip exists in the same directory)
```powershell
Get-ChildItem -Path "C:\project\buildfiles" -Recurse -Directory |
Where-Object { Test-Path (Join-Path $_.Parent.FullName "$($_.Name).zip") } |
Remove-Item -Recurse -Force
```
> Replace "C:\project\buildfiles" with your actual BuildFilesPath
> ```Example:``` C:\project\artifacts\*\4.0.0.0




