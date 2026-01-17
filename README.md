# NixOS Flake Configuration

A principled, flake-based NixOS configuration featuring:

* **Flakes** for reproducibility.
* **Home Manager** for user environment management.
* **Modular Design** to share config between machines (and future MacOS setups).

## 📂 Structure

```text
~/nix-config/
├── flake.nix             # Entry point: defines inputs & machine outputs
├── flake.lock            # Pinned versions (source of truth)
├── modules/              # Reusable logic
│   ├── nixos/            # System modules (e.g., nvidia, gnome, base system)
│   └── home-manager/     # User modules (e.g., git, zsh, neovim)
└── hosts/                # Machine-specific configurations
    └── nixdt/            # Hostname: nixdt
        ├── default.nix   # System entry point (imports hardware & modules)
        ├── home.nix      # User entry point (anthliu's packages & dotfiles)
        └── hardware-configuration.nix

```

## ⚡ Cheatsheet

**Apply Changes (System & Home):**

```bash
# Don't forget to git add new files first!
git add .
sudo nixos-rebuild switch --flake .#nixdt

```

**Update System (flake.lock):**

```bash
nix flake update
sudo nixos-rebuild switch --flake .#nixdt

```

**Clean Garbage (Free disk space):**

```bash
# Delete older generations
sudo nix-collect-garbage -d

```

---

## 🛠 Workflows

### 1. How to Add Packages

* **For the User (You):**
Edit `hosts/nixdt/home.nix`.
* *Best for:* CLI tools, dev utilities, apps you use personally (ripgrep, jq, spotify).


* **For the System (Everyone/Root):**
Edit `modules/nixos/base.nix` (global) or `hosts/nixdt/default.nix` (machine specific).
* *Best for:* System utilities, background services, drivers (wget, curl, drivers).



### 2. How to Add a New Machine

1. **Create Directory:** Copy an existing host folder.
```bash
cp -r hosts/nixdt hosts/new-machine

```


2. **Generate Hardware Config:** Run on the new machine:
```bash
nixos-generate-config --show-hardware-config > hosts/new-machine/hardware-configuration.nix

```


3. **Update Config:** Edit `hosts/new-machine/default.nix` to set the new `networking.hostName`.
4. **Register in Flake:** Open `flake.nix` and duplicate the `nixdt` block under `nixosConfigurations`, renaming it to `new-machine`.
5. **Build:**
```bash
sudo nixos-rebuild switch --flake .#new-machine

```



### 3. How to Modify Desktop/Drivers

* **Nvidia:** Edit `modules/nixos/nvidia.nix`.
* **Gnome/DE:** Edit `modules/nixos/gnome.nix`.
* *To enable/disable:* Comment out the import in `hosts/<name>/default.nix`.

---

## ⚠️ Important Gotchas

**1. "Path does not exist" Error**
Nix Flakes only see files that are **tracked by git**. If you create a new file, you must stage it before rebuilding.

```bash
git add .

```

**3. Home Manager Conflicts**
If Home Manager complains about existing files (e.g., `~/.config/git/config`), delete or back up the existing file manually so Home Manager can link its own version.
