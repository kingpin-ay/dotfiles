# Pushing this folder to my personal GitHub account (from Windows)

This folder has **no git history**. You'll create a fresh repo on your
personal Windows PC, so every commit uses your personal identity.

Replace `YOUR_USERNAME` and `you@personal.com` with your personal GitHub
username and email. All commands below are for **PowerShell** on Windows.

> These configs are for Linux (Ubuntu). Windows only stores and pushes them.
> Don't run `install.sh` on Windows; run it on your Linux machines after cloning.

---

## 1. Extract the archive

Plug in the pendrive (say it's drive `E:`) and extract into your home folder.
`tar` is built into Windows 10/11:

```powershell
cd $HOME
tar -xzf E:\dotfiles.tar.gz
cd dotfiles
dir -Force          # you should see .gitattributes, .gitignore, install.sh, config, ...
```

---

## 2. Install Git and the GitHub CLI (skip if you already have them)

```powershell
winget install --id Git.Git -e
winget install --id GitHub.cli -e
```

**Close and reopen PowerShell** afterwards so the new commands are found.

---

## 3. Set your personal git identity

```powershell
git config --global user.name  "YOUR_USERNAME"
git config --global user.email "you@personal.com"
```

> Tip: To keep your real email private, use GitHub's noreply address from
> https://github.com/settings/emails (e.g. `12345+YOUR_USERNAME@users.noreply.github.com`).

---

## 4. Create the repo and make the first commit

```powershell
cd $HOME\dotfiles
git init -b main
git add -A

# IMPORTANT on Windows: mark the scripts as executable, otherwise they won't
# run after cloning on Linux (Windows has no "executable" flag).
git update-index --chmod=+x install.sh bin/wallpaper-shuffle

git commit -m "Initial dotfiles"
```

Check:

```powershell
git log --format='%an <%ae>  %s'     # should show YOUR personal name/email
git ls-files -s install.sh bin/wallpaper-shuffle   # both should start with 100755
```

---

## 5. Push to GitHub

```powershell
gh auth login      # GitHub.com -> HTTPS -> "Login with a web browser", using your personal account
gh repo create dotfiles --private --source=. --remote=origin --push
```

Open `https://github.com/YOUR_USERNAME/dotfiles`. All the files should be there.

---

## 6. On any Linux machine: apply the setup

```bash
sudo apt install -y git gh
gh auth login                                   # personal account (the repo is private)
gh repo clone YOUR_USERNAME/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh --packages
```

Then copy your wallpapers into `~/Pictures/wallpapers` (they're not in the
repo; see README).

---

## Everyday use

After changing a config on a Linux machine:

```bash
cd ~/dotfiles
git add -A
git commit -m "describe the change"
git push
```

On another machine: `git pull` to get the latest.

---

## If something goes wrong

| Problem | Fix |
|---|---|
| `tar` not found on Windows | Use Windows 10 (1803+) or 11, or extract with 7-Zip. |
| `git` / `gh` not recognized after installing | Close and reopen PowerShell. |
| `Author identity unknown` on commit | Step 3 was skipped. |
| `./install.sh: Permission denied` on Linux | The chmod in step 4 was skipped. Fix on Linux: `chmod +x install.sh bin/wallpaper-shuffle && git add -A && git commit -m "make scripts executable" && git push` |
| `bash\r: No such file or directory` on Linux | Line endings got converted to Windows style. `.gitattributes` prevents this; make sure it was extracted (`dir -Force`). |
| `rejected ... fetch first` | The GitHub repo was created with a README. Run `git pull --rebase origin main`, then push again. |
