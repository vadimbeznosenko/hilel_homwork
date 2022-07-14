output "alb" {
  value = aws_security_group.alb_sg.id
}

output "alb_sg_ingress_443" {
  value = aws_security_group_rule.alb_sg_ingress_443.id
}

output "alb_sg_egress_instance" {
  value = aws_security_group_rule.alb_sg_egress_instance.id
}

output "instance_sg" {
  value = aws_security_group.instance_sg.id
}

output "instance_sg_ingress_alb" {
  value = aws_security_group.instance_sg.id
}

output "instance_sg_ingress_ssh" {
  value = aws_security_group_rule.instance_sg_ingress_ssh.id
}

output "instance_sg_egress_all" {
  value = aws_security_group_rule.instance_sg_egress_all.id
}

