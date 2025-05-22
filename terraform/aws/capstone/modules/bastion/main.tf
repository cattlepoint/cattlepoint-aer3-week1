resource "aws_instance" "vm" {
  count             = var.instance_count
  ami               = var.ami_id
  instance_type     = var.instance_type
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name        = "${var.project_id}-bastion-${count.index}"
    Environment = var.environment
  }
}
