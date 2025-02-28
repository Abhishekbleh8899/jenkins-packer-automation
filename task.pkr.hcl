variable "aws_region" {
  default = "ap-south-1"
}

variable "aws_ami_name" {
  default = "ubuntu-docker-jenkins-terraform-elasticsearch-ami"
}

variable "aws_instance_type" {
  default = "t2.micro"
}

variable "aws_source_ami" {
  default = "ami-00bb6a80f01f03502"  # Change this to the latest Ubuntu AMI ID for your region
}

variable "aws_ssh_username" {
  default = "ubuntu"
}


# Define the Amazon EC2 builder
source "amazon-ebs" "ubuntu_ami" {
  ami_name      = var.aws_ami_name
  instance_type = var.aws_instance_type
  region        = var.aws_region
  source_ami    = var.aws_source_ami
  ssh_username  = var.aws_ssh_username

  # Define the block for EBS volume size
  launch_block_device_mappings {
    device_name = "/dev/sda1"
    volume_size = 30  # Adjust this value as needed
    volume_type = "gp2"
  }
}
# Provisioners to install required software
build {
  sources = ["source.amazon-ebs.ubuntu_ami"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y git htop",
      
      # Install Docker
      "sudo apt-get install -y ca-certificates curl gnupg",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo usermod -aG docker ubuntu",
      
      # Install OpenJDK 17
      "sudo apt-get install -y openjdk-17-jdk",

      # Install Jenkins
      "sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key",
      "echo \"deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/\" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install -y jenkins",
      "sudo systemctl enable jenkins",
      "sudo systemctl start jenkins",

      # Install Ansible
      "sudo apt-add-repository --yes --update ppa:ansible/ansible",
      "sudo apt-get install -y ansible",

      # Install Terraform
      "wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg",
      "echo \"deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main\" | sudo tee /etc/apt/sources.list.d/hashicorp.list",
      "sudo apt-get update",
      "sudo apt-get install -y terraform",

      # Install MongoDB
      "curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-8.0.gpg",
      "echo \"deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/8.0 multiverse\" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list",
      "sudo apt-get update",
      "sudo apt-get install -y mongodb-org",
      "sudo systemctl enable mongod",
      "sudo systemctl start mongod",
      #Install Elasticsearch
      "wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.17.2-linux-x86_64.tar.gz",
      "wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.17.2-linux-x86_64.tar.gz.sha512",
      "shasum -a 512 -c elasticsearch-8.17.2-linux-x86_64.tar.gz.sha512",
      "tar -xzf elasticsearch-8.17.2-linux-x86_64.tar.gz",
      "cd elasticsearch-8.17.2/",
      "sudo apt-get update",
      "sudo apt-get install -y elasticsearch",
      "sudo systemctl enable elasticsearch",
      "sudo systemctl start elasticsearch",
     

      # Final verification
      "git --version",
      "docker --version",
      "java -version",
      "jenkins --version",
      "ansible --version",
      "terraform --version",
      "mongosh --version"
    ]
  }
}
