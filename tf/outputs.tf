output "address" {
  value = "${aws_eip.web.public_ip}"
}
