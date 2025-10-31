# Deploy a static website to AWS S3 (Terraform)

This Terraform project creates an S3 bucket configured for static website hosting and uploads the site files (`index.html`, `styles.css`, `error.html`). It also exposes the website endpoint as an output.

Prerequisites
- Terraform installed (v1.0+ recommended).
- AWS credentials configured (via `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY` environment variables, or an AWS CLI profile). On Windows PowerShell you can set env vars like:

```powershell
$env:AWS_ACCESS_KEY_ID = "YOUR_ACCESS_KEY"
$env:AWS_SECRET_ACCESS_KEY = "YOUR_SECRET"
$env:AWS_DEFAULT_REGION = "us-east-1"
```

Or use an AWS CLI named profile and set the `AWS_PROFILE` env var before running Terraform.

Files created/used
- `main.tf` — Terraform configuration (providers, bucket, policy, website configuration, objects).
- `index.html` — existing home page (uploaded to S3).
- `styles.css` — existing stylesheet (uploaded to S3).
- `error.html` — error page (created in this project and uploaded to S3).

Quick usage (PowerShell)

1. Initialize the directory (downloads providers):

```powershell
cd "C:\Users\Khushal Bhavsar\OneDrive\Desktop\Terraform\Project-S3-Static-Website"
terraform init
```

2. Preview the changes:

```powershell
terraform plan -out plan.tfplan
```

3. Apply (create resources):

```powershell
terraform apply "plan.tfplan"
# or directly: terraform apply -auto-approve
```

4. After apply completes, get the website endpoint URL (output named `name`):

```powershell
terraform output name
```

The `name` output will be the S3 website endpoint URL (e.g. `mywebapp-bucket-XXXX.s3-website-us-east-1.amazonaws.com`). Open it in a browser to view your site.

Notes and tips
- The bucket name is generated using a random suffix to ensure uniqueness. You can find the bucket name in the output `bucket_name`.
- If you have a corporate AWS setup or require a specific profile, set `AWS_PROFILE` in PowerShell before running Terraform:

```powershell
$env:AWS_PROFILE = "my-profile"
terraform init; terraform apply
```

- Public access: this project configures a public access block and a bucket policy to allow public reads for website hosting. Review and adjust for your security requirements.

- Cleanup: to remove created resources when you are done:

```powershell
terraform destroy -auto-approve
```

If you want help customizing the bucket name, region, or adding a CloudFront distribution in front of the bucket, tell me what you'd like and I can add it.
