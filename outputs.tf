output "Jenkins-Main-Node-Public-IP" {
  value = aws_instance.jenkins-master.public_ip
}

output "Jenkins-Worker-Nodes-Public-IPs" {
  value = {
    for instance in aws_instance.jenkins-worker :
    instance.id => instance.public_ip
  }
}

output "LB-DNS-Name" {
  value       = aws_lb.application-lb.dns_name
  description = "DNS name of the load balancer"
}

output "url" {
  value = aws_route53_record.jenkins.fqdn
}
