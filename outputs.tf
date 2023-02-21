output "consul_server_dc1" {
  value = "export CONSUL_HTTP_ADDR=http://${aws_instance.dc1_server.public_ip}:8500"
}

output "consul_client_dc1" {
  value = "export CONSUL_HTTP_ADDR=http://${aws_instance.dc1_client.public_ip}:8500"
}

output "consul_server_dc2" {
  value = "export CONSUL_HTTP_ADDR=http://${aws_instance.dc2_server.public_ip}:8500"
}

output "consul_client_dc2" {
  value = "export CONSUL_HTTP_ADDR=http://${aws_instance.dc2_server.public_ip}:8500"
}