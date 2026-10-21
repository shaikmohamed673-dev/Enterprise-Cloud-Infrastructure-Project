# TEACH_ME — Student Learning & Viva Preparation Guide

> [!IMPORTANT]
> **DELETE this entire `TEACH_ME/` folder before pushing to GitHub!**
> This folder contains personal learning notes and interview prep — it is NOT part of the professional project repository.
> Run: `Remove-Item -Recurse -Force TEACH_ME` on Windows (or `rm -rf TEACH_ME/` on Linux) before your final `git add . && git push`.

---

## What's Inside This Folder?

| File | What It Teaches You |
|:---|:---|
| `01_PROJECT_EXECUTIVE_SUMMARY.md` | The big picture — what was built and why, in plain English |
| `02_STEP_BY_STEP_HOW_IT_WAS_BUILT.md` | File-by-file technical breakdown of every component |
| `03_LOCAL_DEMO_WALKTHROUGH.md` | Exact commands to run a live local demo for your evaluator |
| `04_VIVA_QA_INTERVIEW_PREP.md` | 35+ expected examiner questions with complete model answers |
| `05_CONCEPTS_GLOSSARY.md` | Plain-English glossary of every technical term used |
| `06_ARCHITECTURE_EXPLAINED.md` | Annotated walkthrough of each architecture diagram |

---

## How To Use This Guide

1. **Before your viva**: Read `01_PROJECT_EXECUTIVE_SUMMARY.md` first. Know how to explain the project in 2 minutes.
2. **For live demos**: Follow `03_LOCAL_DEMO_WALKTHROUGH.md` step by step — it works on your Windows PC with Docker Desktop.
3. **For tough questions**: Study `04_VIVA_QA_INTERVIEW_PREP.md`. These are real questions professors and internship evaluators actually ask.
4. **For terminology**: Keep `05_CONCEPTS_GLOSSARY.md` open during your presentation.
5. **Before pushing to GitHub**: DELETE this entire folder! See the warning above.

---

## Quick 2-Minute Project Pitch (Memorize This!)

> *"I built a scalable, automated cloud infrastructure on AWS for an enterprise use case. I used Terraform to provision the entire AWS network (VPC, subnets, load balancer, autoscaling) as reusable code. Docker Swarm orchestrates containerized microservices with zero-downtime rolling deployments and automatic self-healing. GitHub Actions handles continuous integration and delivery — it runs tests, security scans, builds Docker images, and deploys automatically on every code change. Prometheus and Grafana provide real-time monitoring with production alert rules. Finally, AES-256 encrypted database backups are automatically uploaded to AWS S3 for disaster recovery."*
