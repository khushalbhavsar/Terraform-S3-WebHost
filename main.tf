terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
  }
}

// Configure the AWS Provider
provider "aws" {
  region = "us-east-1" 
}

// Generate a random suffix for the bucket name to ensure uniqueness
resource "random_id" "rand_id" {
  byte_length = 8 // 16 hex characters
}

// Create an S3 bucket for the static website
resource "aws_s3_bucket" "mywebapp-bucket" {
  bucket = "mywebapp-bucket-${random_id.rand_id.hex}"
  # Note: we manage public access via bucket policy + public access block resource below
}

// Configure the bucket to allow public read access
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.mywebapp-bucket.id // Reference to the S3 bucket
  block_public_acls       = false // Allow public ACLs
  block_public_policy     = false // Allow public bucket policies
  ignore_public_acls      = false // Do not ignore public ACLs
  restrict_public_buckets = false // Do not restrict public buckets
}

// Set the bucket policy to allow public read access to all objects
resource "aws_s3_bucket_policy" "mywebapp" {
  bucket = aws_s3_bucket.mywebapp-bucket.id
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Sid       = "PublicReadGetObject", // Statement ID
          Effect    = "Allow", // Allow access
          Principal = "*", // Allow access to everyone
          Action    = "s3:GetObject", // Allow GetObject action
          Resource  = "${aws_s3_bucket.mywebapp-bucket.arn}/*" // All objects in the bucket
        }
      ]
    }
  )
}

// Configure the bucket for static website hosting
resource "aws_s3_bucket_website_configuration" "mywebapp" {
  bucket = aws_s3_bucket.mywebapp-bucket.id

  # Specify index and error documents for static website hosting
  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

// Upload the index.html and styles.css files to the S3 bucket as objects 
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.mywebapp-bucket.bucket // Reference to the S3 bucket
  source       = "./index.html"
  key          = "index.html"
  content_type = "text/html" // Specify content type
  acl          = "public-read"
}

// Upload styles.css file
resource "aws_s3_object" "styles_css" {
  bucket       = aws_s3_bucket.mywebapp-bucket.bucket // Reference to the S3 bucket
  source       = "./styles.css"
  key          = "styles.css"
  content_type = "text/css" // Specify content type
  acl          = "public-read"
}

// Upload a simple error page to serve when a resource is not found
resource "aws_s3_object" "error_html" {
  bucket       = aws_s3_bucket.mywebapp-bucket.bucket
  source       = "./error.html"
  key          = "error.html"
  content_type = "text/html"
  acl          = "public-read"
}

// Output the website endpoint URL
// Output: the S3 website endpoint (useful URL to open in the browser)
output "name" {
  # Use website_domain (non-deprecated); users can prefix with http:// to form the full URL
  value = aws_s3_bucket.mywebapp-bucket.website_domain
  description = "S3 website domain (e.g. mybucket.s3-website-us-east-1.amazonaws.com). Prefix with http:// to open in a browser."
}

// Also output the bucket name for convenience
output "bucket_name" {
  value       = aws_s3_bucket.mywebapp-bucket.bucket
  description = "The name of the S3 bucket created for hosting"
}