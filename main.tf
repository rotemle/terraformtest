# Create a new VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "example-vpc"
  }
}

# Create a new subnet
resource "aws_subnet" "example" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.example.id
  tags = {
    Name = "example-subnet"
  }
}

# Create a new security group
resource "aws_security_group" "example" {
  name        = "example-sg"
  description = "Allow inbound traffic on port 22"
  vpc_id      = aws_vpc.example.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a new EC2 instance
resource "aws_instance" "example" {
  ami           = "ami-abc123"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.example.id]
  subnet_id = aws_subnet.example.id
}

# Allow the EC2 instance to access the internet
resource "aws_security_group" "example_access" {
  name        = "example-access-sg"
  description = "Allow inbound traffic on port 80"
  vpc_id      = aws_vpc.example.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a new IAM role for the EC2 instance
resource "aws_iam_role" "example" {
  name        = "example-iam-role"
  description = "Allow the EC2 instance to access the internet"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
        Sid      = ""
      }
    ]
  })
}

# Create a new IAM policy for the EC2 instance
resource "aws_iam_policy" "example" {
  name        = "example-iam-policy"
  description = "Allow the EC2 instance to access the internet"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeRegions",
          "ec2:DescribeAvailabilityZones"
        ]
        Resource = "*"
        Effect = "Allow"
      },
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "*"
        Effect = "Allow"
      }
    ]
  })
}

# Attach the IAM policy to the IAM role
resource "aws_iam_role_policy_attachment" "example" {
  role       = aws_iam_role.example.name
  policy_arn = aws_iam_policy.example.arn
}

# Create a new S3 bucket
resource "aws_s3_bucket" "example" {
  bucket = "example-bucket"
  acl    = "private"
}

# Create a new IAM user
resource "aws_iam_user" "example" {
  name        = "example-iam-user"
  username    = "example-iam-user"
}

# Attach the IAM policy to the IAM user
resource "aws_iam_user_policy_attachment" "example" {
  user       = aws_iam_user.example.name
  policy_arn = aws_iam_policy.example.arn
}

# Create a new S3 bucket policy
resource "aws_s3_bucket_policy" "example" {
  bucket = aws_s3_bucket.example.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowS3Access"
        Effect    = "Allow"
        Principal = {
          AWS = aws_iam_user.example.arn
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.example.arn}/*"
      }
    ]
  })
}