# Dev-Box in Hetzner

This repository contains Terraform that I use to provision my devbox on [Hetzner](https://www.hetzner.com/).

It depends on you having:
* a GitHub account
* an [Hetzner account](https://www.hetzner.com/)
* 8 € / month to pay for the server (you can choose a smaller one)

## How to use

1. Fork this repository on GitHub
2. Change the public ssh keys in configuration.yaml to your own and push to main.
3. Create an account in Hetzner, create a new project, and create a new API token on it, storing it as a repo secret named `HCLOUD_TOKEN`
4. Run `openssl rand -hex 32` and store it as a repo secret named `TF_STATE_PASSWORD`
5. (optional for local dev) Create a `.env` file with the same
   ```
   HCLOUD_TOKEN="..."
   TF_STATE_PASSWORD=...
   ```
6. Push or re-trigger the action in main

The TF state is stored encrypted in branch `tfstate`.
The action outputs IP v4, which you can login via `ssh root@IP` with any of your private keys.

## How to get the remote tf state

```bash
export $(cat .env | xargs)
git checkout tfstate
openssl aes-256-cbc -pbkdf2 -d -in terraform.tfstate.enc -out terraform.tfstate -pass pass:${TF_STATE_PASSWORD}
```

## How to update the remote tf state

```bash
export $(cat .env | xargs)
git checkout tfstate
openssl aes-256-cbc -pbkdf2 -salt -in terraform.tfstate -out terraform.tfstate.enc -pass pass:${TF_STATE_PASSWORD}
git commit -a -m "Updated state" && git push
```

## To revert

Change the action to `terraform destroy`, or run it locally (or nuke the project in Hetzner console).
