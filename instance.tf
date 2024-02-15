resource "aws_key_pair" "bhardwaj-tf" {
  key_name   = "bhardwaj-tf"
  public_key = file("${path.module}/id_rsa.pub")
}
resource "aws_security_group" "test" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"

  dynamic "ingress" {
    for_each = [22,80,443,704]
    iterator = port
    content {
      description = "TLS from VPC"
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}
resource "aws_instance" "web" {
  ami             = var.ami
  instance_type   = var.instance_type
  key_name        = "${aws_key_pair.bhardwaj-tf.key_name}"
  vpc_security_group_ids  = ["${aws_security_group.test.id}"]

  root_block_device {
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    encrypted             = true
    delete_on_termination = true
  }


  tags = {
    Name = "Terraform_instance"
  }
}



