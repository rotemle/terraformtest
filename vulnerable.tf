# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}

# AWS Vulnerabilities
resource "aws_s3_bucket" "public_bucket" {
  bucket = "public-bucket"
  acl    = "public-read-write" # Vulnerability: Publicly accessible S3 bucket
}

resource "aws_security_group" "open_sg" {
  name        = "open-sg"
  description = "Security group with open ports"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Vulnerability: Open security group
  }
}

resource "aws_ec2_instance" "unpatched_instance" {
  ami           = "ami-0c94855ba95c71c99" # Vulnerability: Unpatched EC2 instance
  instance_type = "t2.micro"
}

# Configure the GCP Provider
provider "google" {
  project = "your-project-id"
  region  = "us-central1"
}

# GCP Vulnerabilities
resource "google_storage_bucket" "public_bucket" {
  name          = "public-bucket"
  location      = "US"
  storage_class = "REGIONAL"
  public_access_prevention = false # Vulnerability: Publicly accessible GCS bucket
}

resource "google_compute_firewall" "open_firewall" {
  name    = "open-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"] # Vulnerability: Open firewall rule
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "unpatched_instance" {
  name         = "unpatched-instance"
  machine_type = "f1-micro"
  zone         = "us-central1-a"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9" # Vulnerability: Unpatched GCE instance
    }
  }
}

# Configure the Azure Provider
provider "azurerm" {
  features {}
}

# Azure Vulnerabilities
resource "azurerm_storage_account" "public_storage" {
  name                     = "publicstorage"
  resource_group_name      = "your-resource-group"
  location                 = "West US"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = "true"
  public_network_access_enabled = true # Vulnerability: Publicly accessible Azure Storage
}

resource "azurerm_network_security_group" "open_nsg" {
  name                = "open-nsg"
  resource_group_name = "your-resource-group"
  location            = "West US"

  security_rule {
    name                       = "open-rule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*" # Vulnerability: Open NSG rule
  }
}

resource "azurerm_virtual_machine" "unpatched_vm" {
  name                  = "unpatched-vm"
  resource_group_name   = "your-resource-group"
  location              = "West US"
  vm_size               = "Standard_DS2_v2"
  network_interface_ids = [azurerm_network_interface.example.id]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS" # Vulnerability: Unpatched Azure VM
    version   = "latest"
  }
}