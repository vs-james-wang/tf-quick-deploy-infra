output "instance_security_group_id" {
  description = "ID of the instance security group"
  value       = aws_security_group.instance.id
}
