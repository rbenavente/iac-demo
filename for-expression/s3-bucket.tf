resource "aws_s3_bucket" "foo" {
  bucket        = "tf-test-trail"
  force_destroy = true
  versioning { enabled = false }
  acl = "public-read-write"
  tags = {
    yor_trace = "24fb5920-01f0-4956-9600-58fa2bc06906"
  }
}

