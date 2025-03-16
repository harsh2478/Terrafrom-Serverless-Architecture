resource "aws_cloudwatch_log_group" "log_groups" {
  count = length(var.cloudwatch_log_groups)
  name = "${var.cloudwatch_log_groups[count.index]}"
  retention_in_days = 0
}
