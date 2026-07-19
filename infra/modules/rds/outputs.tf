output "endpoint" {
  value = aws_db_instance.this.endpoint
}

output "security_group_id" {
  value = aws_security_group.db.id
}

output "secret_arn" {
  value = aws_secretsmanager_secret.db_credentials.arn
}

output "kms_key_arn" {
  value = aws_kms_key.rds.arn
}
