# NixOS Flake Configuration

A vibe-coded modular NixOS configuration:

* **Flakes** for reproducibility.
* **Home Manager** for user environment management.
* **Modular Design** to share config between machines.

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
git add .
sudo nixos-rebuild switch --flake .#nixdt
```

**Apply Changes (Home Only - Faster):**

```bash
home-manager switch --flake .
```

**Clean Garbage (Free disk space):**

```bash
# Delete older generations
sudo nix-collect-garbage -d

```

---

## 🔄 Updates & Maintenance

### How to Update

Updates are manual and explicit. Nothing changes until you run these commands.

1. **Update the Lockfile** (Downloads latest package versions):
```bash
nix flake update

```


2. **Apply the Update**:
```bash
sudo nixos-rebuild switch --flake .#nixdt

```


3. **Commit the State**:
```bash
git commit -am "chore: update system inputs"

```



### 🚑 Recovering from Breakage

If an update breaks your WiFi, Graphics, or Config:

**Option A: Rollback via CLI** (If you can still use the terminal)

```bash
sudo nixos-rebuild switch --rollback

```

**Option B: Rollback via Boot Menu** (If the system won't boot)

1. Reboot the computer.
2. In the systemd-boot menu, select the entry below the current one (e.g., `NixOS - Generation 44`).
3. The system will boot into the exact state it was in before the update.

---

## 🛠 Workflows

### 1. How to Add Packages

* **User Apps (CLI/Dev):** Edit `hosts/nixdt/home.nix`.
* **System Apps (Services/Drivers):** Edit `modules/nixos/base.nix`.
* *Note:* If the package is **Unfree** (e.g. VSCode, Discord), ensure `allowUnfree` covers it in `base.nix`.

### 2. How to Add a New Machine

1. **Copy Host:** `cp -r hosts/nixdt hosts/new-machine`
2. **Hardware Scan:** `nixos-generate-config --show-hardware-config > hosts/new-machine/hardware-configuration.nix`
3. **Flake Registry:** Add `new-machine` to `flake.nix` outputs.
4. **Build:** `sudo nixos-rebuild switch --flake .#new-machine`

### 3. Proprietary Apps (Antigravity/Jetski)

If an app isn't in Nixpkgs or fails to build:

* **Option A:** Use **Flatpak** (`flatpak install ...`).
* **Option B:** Use **Steam-Run** (`steam-run ./my-binary`).

---

## ⚠️ Important Gotchas

**1. "Path does not exist" Error**
Nix Flakes only see files that are **tracked by git**.

```bash
git add .

```

**2. Permission Denied**

* Use `sudo` for `nixos-rebuild`.
* Do **NOT** use `sudo` for `git` commands.

**3. Home Manager & Unfree Packages**
If Home Manager complains about unfree packages, ensure `useGlobalPkgs = true;` is set in the host's `default.nix`.
