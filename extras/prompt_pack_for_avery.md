# Homelab Prompt Pack
### Getting the most out of your AI assistant — built around your Proxmox / pfSense / WireGuard lab

John had Claude go through your `Virtual_Server` repo, and this is a set of prompts to help you push the build — and your skills — further, faster. They're written to drop straight into ChatGPT since that's your daily driver, but they'll work in any assistant. Fill in the blanks, paste, go.

At the end there's a straight, no-hype rundown of where ChatGPT tends to fight you on this kind of work and what to do about it.

---

## First — 5 rules that make any assistant far better at infrastructure work

These matter more than any single prompt below. Hands-on infra is exactly where generic AI answers fall apart, and these five habits fix most of it:

1. **Feed it your real stuff, not a description.** It can't see your machine. Paste the actual config file, the actual command output, the actual error — not "my pfSense isn't routing." The answer is only as good as what you give it.
2. **Make it show its assumptions.** End prompts with: *"List every assumption you made and flag anything you're not 100% sure about."* That's how you catch the confident-but-wrong answer before it breaks something.
3. **Demand exact commands + what each does.** *"Give me the exact commands and one line on what each does and why."* You learn faster and you catch nonsense flags.
4. **Let it interview you first.** For anything specific to your setup: *"Before you answer, ask me for the exact files or outputs you need."* Stops it from guessing.
5. **Snapshot before you run anything.** Snapshot the VM in Proxmox first. Then a wrong suggestion costs you ten seconds to roll back instead of a rebuild.

---

## Finish the pfSense build & prove it's isolated

**Get WAN / LAN / DHCP / rules right:**
```
I'm running pfSense as a VM on Proxmox. It has two interfaces: vtnet0 = WAN on bridge vmbr0 (my home network, 10.0.0.0/24, gateway 10.0.0.1) and vtnet1 = LAN on bridge vmbr1 (an isolated bridge with no uplink) for a lab network.

Walk me through: (1) assigning the interfaces, (2) setting the LAN to 10.10.10.1/24 with a DHCP range, and (3) the exact firewall rules so lab machines on the LAN can reach the internet but CANNOT reach anything on my home 10.0.0.0/24 network. Give me exact steps and explain the "why" of each firewall rule. List your assumptions and flag anything that depends on my specific pfSense version.
```

**Prove the isolation actually works:**
```
Give me a concrete test plan to prove my pfSense lab network (10.10.10.0/24 on vmbr1) is truly isolated from my home network (10.0.0.0/24). List the exact commands to run from a lab VM and what PASS vs FAIL looks like for each: internet reachability, DNS, pinging the home gateway (should fail), and reaching another home device (should fail). Explain what each result proves.
```

**Networking troubleshooter (paste-your-outputs template):**
```
My lab VM on vmbr1 isn't [getting an IP / reaching the internet / being blocked correctly]. Here's my setup and outputs — diagnose it step by step, most-likely cause first.

pfSense LAN config: [paste]
`ifconfig` on pfSense: [paste]
`ip addr` and `ip route` on the lab VM: [paste]
pfSense LAN firewall rules: [paste or describe]

Before guessing, tell me if you need any other output. Then give me the fix as exact commands and explain why it works.
```

---

## Build the isolated attack range

**Design the range around the skills you want:**
```
I have an isolated lab network (vmbr1, behind pfSense) on Proxmox. I want to build a beginner-to-intermediate cybersecurity range on it. Help me design it: which VMs to run (an attacker box plus a mix of vulnerable/target machines), how to segment them, and — most useful — map each machine to the specific skills it lets me practice (recon, exploitation, privilege escalation, detection, hardening). Everything stays inside the isolated lab. Give me a build order from simplest to most advanced.
```

**Your first full exercise, start to finish:**
```
Design my first hands-on exercise inside my isolated range: a Kali attacker vs one vulnerable target on vmbr1. Take me through the full loop — recon, finding a vulnerability, exploiting it, then switching hats to DETECT what I just did from the logs, and finally hardening the target so it doesn't work anymore. For each phase give me the concept, the exact tools/commands, and what to write down. This is a personal, isolated lab for learning only.
```

**Blue-team the same exercise:**
```
Using the same isolated lab, teach me the defensive side: how to set up logging and monitoring on my target and network so I can actually SEE an attack happening. What should I log, what lightweight tools fit a homelab, and what would the attack from my last exercise look like in those logs? Give me exact setup steps.
```

---

## Automate it & make it reproducible

**Turn the manual build into code:**
```
I want to stop clicking through the Proxmox UI and make my lab reproducible. Given a Proxmox host and pfSense already set up, help me automate spinning up lab VMs on vmbr1. Show me the options (bash + Proxmox CLI vs Terraform with the bpg/proxmox provider vs Ansible), recommend one for a single-node homelab, and write a starter version with placeholders for my values. Comment every block. Important: clearly mark which parts you can't verify, so I test them in a snapshot first.
```

**Snapshot & recovery strategy:**
```
Give me a simple snapshot and backup strategy for my single-node Proxmox homelab so I can experiment fearlessly: when to snapshot vs back up, how to automate it, and how much disk to budget. Keep it practical.
```

---

## Learn faster from what you already built

**Deep-dive the concepts behind your own work:**
```
I just set up [WireGuard VPN with SSH key auth / pfSense with network segmentation] on my homelab. Don't give me setup steps — I did that. Instead teach me the CONCEPTS I just used, deeply enough to explain them in an interview: [WireGuard: public/private key crypto, the handshake, why AllowedIPs matters, NAT traversal] [pfSense: firewall state, NAT, subnets, why segmentation matters]. Then ask me 5 questions to check I actually get it.
```

**Map the homelab to a certs/skills path:**
```
I'm building a cybersecurity homelab (Proxmox, pfSense, WireGuard, an isolated attack range) to break into the field. Map what I'm doing to a concrete skills-and-certs roadmap: which certs my current work already builds ground for (e.g. Network+, Security+), what to add next to prep for each, and the order that gets me job-ready fastest. Be realistic about timelines.
```

**Find my gaps:**
```
Quiz me on the networking and security concepts behind my homelab (subnets, NAT, VPN, firewalls, VLANs, SSH). Ask one question at a time, adapt the difficulty to my answers, and at the end tell me my weak spots and exactly what to study.
```

---

## Turn it into a career asset

**Portfolio + resume + LinkedIn from the lab:**
```
Here are the writeups from my homelab project: [paste your README + the proxmox / wireguard / pfsense docs]. Turn this into a career asset: (1) a punchy portfolio README framing, (2) 3–4 resume bullets that make this sound like the real engineering it is, with the skills named, and (3) a short LinkedIn post announcing the project. Keep my voice, don't oversell, and lead with what I actually built.
```

**Interview prep with the lab as your story:**
```
I want to use my homelab as the centerpiece of cybersecurity job interviews. Play the interviewer: ask me realistic technical and behavioral questions my Proxmox/pfSense/WireGuard project would surface, let me answer, and coach me on each — what was strong, what to add, and the concept to be ready to go deeper on.
```

---

## Where ChatGPT will fight you on this (and what to do)

Straight talk, no tribalism: ChatGPT is genuinely great for a lot of this — brainstorming the range, explaining concepts, quizzing you, the career stuff. Keep using it there. But hands-on infra has a few spots where it hits a wall by design:

**1. It can't touch your machine.** It can't open your `/etc/network/interfaces`, run `wg show`, read the result, and fix the file. You're the copy-paste courier on every step. → *Workaround:* rules #1–#4 above. *Different tool:* Claude Code runs in your terminal — it edits your real config files, runs your real commands, reads the output, and iterates itself. For a build that's 90% "edit a file, run a command, see what happened," that closes the loop you're currently walking by hand.

**2. It only knows what you paste.** It can't see your repo or your setup, so answers stay generic unless you hand-feed every detail — and it'll answer confidently anyway, missing context you forgot to include. → *Workaround:* over-share context and make it interview you first. *Different tool:* Claude Code reads your whole project, so its advice is grounded in your actual files instead of a generic install.

**3. It's confidently wrong on specifics.** The classic failure: it invents a plausible-looking flag, path, or config line, states it with total confidence, and you find out when it errors. → *Workaround:* rule #2 (make it flag uncertainty) + rule #5 (snapshot first). *Different tool:* instead of guessing your syntax, Claude Code can just run the command and see what actually happens.

**4. Long builds drift.** Over a multi-day build the chat loses the thread — earlier decisions fall out of memory and it starts contradicting itself. → *Workaround:* keep a running "state of the lab" note and re-paste it. *Different tool:* Claude holds a lot more context, and Claude Code keeps your project context persistent across the whole build.

**5. Your docs always lag.** Every writeup is you, by hand, after the fact. → *Different tool:* this pack, your network diagram, and the drafted pfSense writeup were all generated by pointing Claude at your public repo — the docs keep up with the build instead of trailing it.

**Bottom line:** keep ChatGPT for thinking and learning. For the hands-on build and the documentation, a terminal-native tool like Claude Code is a different category of thing — and it's free to try. Point it at your repo, give it one real task, and you'll feel the difference in about ten minutes.
