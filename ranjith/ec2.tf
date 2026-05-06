resource "aws_instance" "dasa" {
    ami = "ami-0fcc78c828f981df2"
    instance_type = "t3.micro"

    tags = {
      name = "demo_machine123"
    }
}