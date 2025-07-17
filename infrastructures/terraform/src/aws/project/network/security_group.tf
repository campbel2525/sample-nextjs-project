# ---------------------------------------------
# db_sg
# ---------------------------------------------
resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "database role security group"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "db-sg"
  }
}

resource "aws_security_group_rule" "db_in_app" {
  security_group_id        = aws_security_group.db_sg.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
  source_security_group_id = aws_security_group.app.id
}

resource "aws_security_group_rule" "db_out_all" {
  security_group_id = aws_security_group.db_sg.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

# ---------------------------------------------
# app
# ---------------------------------------------
resource "aws_security_group" "app" {
  name        = "app-sg"
  description = "app role security group"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "app-sg"
  }
}

resource "aws_security_group_rule" "app_out_all" {
  security_group_id = aws_security_group.app.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}
