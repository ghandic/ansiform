output "default_vpc_id" {
  value = "${aws_vpc.default.id}"
}

output "default_security_group_id" {
  value = "${aws_security_group.default.id}"
}

output "default_subnet_id" {
  value = "${aws_subnet.default.id}"
}

output "amazon_ami_id" {
  value = "${data.aws_ami.amazon2.id}"
}

output "ubuntu_ami_id" {
  value = "${data.aws_ami.ubuntu.id}"
}

