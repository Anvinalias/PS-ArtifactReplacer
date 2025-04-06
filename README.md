A project to learn Powershell by automating the process of replacing artifact files with build files.

This is a small project based on one of our internal activities that involves a set of tasks following a repetitive template. As such, the conditions and practices used here may not be suitable for real-world scenarios. The purpose of this project is to automate that specific process under defined conditions and to give me space to experiment along the way.
The project is entirely focused on the Windows environment, as that's where these files are hosted.

Steps to note: 

1. Make sure to create a config.json file and add corresponding paths as given in config.example.json file or you can rename config.example.json to config.json and add paths accordingly.

2. If you have 7-zip installed specify it in config.json. This can reduce unzip time significantly.

Observations & Optimization:

1. Replacing builtin Copy-Items cmdlet with robocopy for folder cloning saved almost 3 minutes

2. Using 7-zip instead of Expand-Archive cmdlet reduced the unzipping time by 2 minutes.
Still Expand-Archive is used if 7-zip is not available.


Some commands that helped me to rollback while debugging:

1. Delete version folder 4.0.0.0, if cloned from 1.0.0.0 (replace "$ArtifactFilesPath" with correct path, example: "C:\project\artifacts\*\4.0.0.0")
Remove-Item -Path "$ArtifactFilesPath\*\4.0.0.0" -Recurse -Force

2. Delete Unzipped buildfiles (replace "$BuildFilesPath" with correct path, example: "C:\project\buildfiles")
Get-ChildItem -Path "$BuildFilesPath" -Recurse -Directory | Where-Object { Test-Path (Join-Path $_.Parent.FullName "$($_.Name).zip") } | Remove-Item -Recurse -Force