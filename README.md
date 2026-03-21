# HarborCart SMB Commerce Suite

Responsive SMB storefront and operations dashboard with:

- 10 image-backed products.
- Email invoice workflow placeholders for `[owner]` and `[email]`.
- Inventory visibility and update-ready data structures.
- Delivery/logistics status board.
- Stripe-ready cart handoff messaging.
- Security and compliance guidance aligned to PCI DSS, NIST CSF, CISA, and OWASP.
- Deployment readiness for Flutter/Firebase adaptation, GCP Cloud Run, Cloudflare, and GitHub Actions.
- Terraform automation for repeatable provisioning.

## Files

- `index.html` — responsive single-page SMB commerce app.
- `assets/products/*.svg` — 10 generated product visuals.
- `Dockerfile` + `nginx.conf` — static app containerization for Cloud Run.
- `.github/workflows/deploy-cloud-run.yml` — GitHub Actions deployment pipeline.
- `terraform/` — repeatable GCP infrastructure stack.

## Recommended next integration steps

### Flutter

- Port design tokens and product schema into Flutter widgets.
- Use `GridView` / responsive breakpoints mirroring the web layout.
- Connect cart state to a provider, Riverpod, or Bloc pattern.

### Firebase

- Move `products`, `inventory`, `orders`, and `invoices` into Firestore.
- Use Cloud Functions for invoice generation and Stripe session creation.
- Store hero images in Firebase Storage.

### Cloud Run

```bash
docker build -t harborcart-smb .
docker run -p 8080:8080 harborcart-smb
```

### Terraform

```bash
cd terraform
terraform init
terraform plan -var-file=terraform.tfvars.example
```

## Security reminders

- Keep cardholder data out of your app by using Stripe-hosted payment flows.
- Replace placeholder emails and configure secret management before production.
- Add Cloudflare WAF, bot rules, and DNS before go-live.
- Enable GitHub branch protections, Dependabot, and secret scanning.
