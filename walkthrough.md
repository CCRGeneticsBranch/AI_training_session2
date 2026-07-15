# Session 2 — VS Code on Biowulf, Git & GitHub, with Copilot

**AI Tools and Best Practices for Researchers — CCR Genetics Branch**


Contacts: Vineela Gangalapudi (vineela.gangalapudi@nih.gov) · Erica Pehrsson (erica.pehrsson@nih.gov)

---


## Before you arrive

- [ ] Biowulf account, unlocked ([user dashboard](https://hpcnihapps.cit.nih.gov/auth/dashboard/))
- [ ] On the NIH network or VPN
- [ ] A GitHub account, with Copilot access confirmed
- [ ] [Mount](https://hpc.nih.gov/docs/hpcdrive.html) your Biowulf data directory to local machine 
- [ ] Basic familiarity with git and Github

---

## Part 1 — Launch VS Code on HPC OnDemand

Go to **<https://hpcondemand.nih.gov/>**

You'll sign in with your PIV card or MFA app. On the left sidebar you'll see the list of **Interactive Apps, GUIs, and Servers** available on Biowulf. Scroll down to **VSCode** and click it.

![OnDemand dashboard with the app sidebar](01-ondemand-dashboard.png)

You'll get a launch form asking for resources — hours, CPUs, memory, scratch space, working directory. **Keep the defaults.** They're plenty for today.

![VS Code launch form](02-vscode-app-form.png)

Click **Launch**.

Your session goes into the Slurm queue. It usually takes a few minutes to fire up.

![Session queued](03-launch-queued.png)

    ⚠️ This job counts against your limit of 2 simultaneous interactive jobs. If you already have `sinteractive` sessions running, close them first or your launch will fail.

When the card turns green and says **Running**, your session is ready. Note the compute node it landed on (e.g. `cn0027`). Click **Connect to VS Code**.

![Session ready — Connect to VS Code](04-session-ready.png)

---

## Part 2 — Open your data directory

The VS Code instance that opens in your browser is nearly identical to the VS Code desktop app we installed in Session 1 — same layout, and same Copilot.

Click **Open Folder**. In the search bar at the top, type your data directory:

```
/data/<your-username>
```

For example, mine is `/data/gangalapudiv2`. Click **OK**.

If anyone doesnt know your username, type the following in vscode terminal.

```bash
whoami
```

Your ```/data/<username>``` folder has the maximum allocated space for a user to run analysis. Additional space can be requested if needed.

You'll see a popup asking whether you trust the authors of the files in this folder:

![Trust the folder dialog](06-trust-folder.png)

This is a normal VS Code safety prompt — it's asking because VS Code can execute code from a workspace. Since this is **your own** `/data` directory, it's safe to click **"Yes, I trust the authors"**.


---

## Part 3 — Get the class repo

### 3a. Fork it (in your browser)

### 3b. Clone your fork (from Helix)




## Part 4 — Build the analysis with Copilot


---

## Part 5 — Commit and push

### Review before you commit

### Commit (compute node — this works fine)


### Push (Helix only)


---

## Part 6 — What never goes in a repo

Look at `.gitignore`:

```
*.bam
*.fastq.gz
*.cram
results/
```

Code, configs, and small reference files belong in git. **Patient data, sequence data, and controlled-access anything do not** — not in a private repo, not in an internal one. Once it's committed, it's in the history even if you delete the file.

---

