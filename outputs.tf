output "instance_id" {
  value = aws_instance.ec2.id
}

output "public_ip" {
  value = aws_instance.ec2.public_ip
  description = "Optionnel:IP publique, mais pas nécessaire pour SSM"
}
