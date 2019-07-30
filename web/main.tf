module "base" {
  source = "../base"
  public_key_path = "${var.public_key_path}"
  key_name = "${var.key_name}"
  aws_region = "${var.aws_region}"
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
}

# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "elb" {
  name        = "image_translator_elb"
  description = "ImageTranslator - ELB SG"
  vpc_id      = "${module.base.default_vpc_id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "web" {
  name = "image-translator-elb"

  subnets         = ["${module.base.default_subnet_id}"]
  security_groups = ["${aws_security_group.elb.id}"]
  instances       = ["${aws_instance.image-translation-server.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  provisioner "local-exec" {
    command = "echo http://${self.dns_name}"
  }

}


resource "aws_instance" "image-translation-server" {
  ami             = "${module.base.amazon_ami_id}"
  instance_type   = "t2.micro"

  # The name of our SSH keypair we created above.
  key_name = "${var.key_name}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${module.base.default_security_group_id}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${module.base.default_subnet_id}"

  tags            = {
    Name = "ImageTranslationServer"
  }

  provisioner "remote-exec" {
    connection {
      host     = self.public_ip
      type     = "ssh"
      user     = "ec2-user"
      password = ""
      private_key = "${file("${var.public_key_path}")}"
    }
    inline = [
      "echo 'Hello World'"
    ]

    // Terraform
//    inline = [
//      "sudo yum update -y",
//      "sudo yum install httpd -y",
//      "sudo service httpd start",
//      "sudo chkconfig httpd on",
//      "echo '<html><h1>Hello Cloud Gurus Welcome To My Webpage</h1></html>' | sudo tee /var/www/html/index.html"
//    ]

  }

  // Ansible via commandline
//  provisioner "local-exec" {
//    command = <<EOT
//    printf "http:\n  hosts: "${self.public_ip}"\n  vars:\n    ansible_ssh_user: ec2-user" > web/inventory.yml && \
//    ansible-playbook -i web/inventory.yml --private-key ${var.public_key_path} web/httpd.yml
//EOT
//  }


  // Shell
  //  user_data       = "${file("setup.sh")}"

}

// Ansible using plugin
resource "null_resource" "image-translation-server" {
  depends_on = ["aws_instance.image-translation-server"]
  connection {
    host        = "${aws_instance.image-translation-server.public_ip}"
    type        = "ssh"
    user        = "ec2-user"
    password    = ""
    private_key = "${file("${var.public_key_path}")}"
  }
  provisioner "ansible" {
     plays {
      playbook {
        file_path = "web/httpd.yml"
      }
      hosts = ["${aws_instance.image-translation-server.public_ip}"]
      groups = ["http"]
    }
  }
}




