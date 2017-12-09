resource "aws_db_instance" "db_instance" {
    identifier = "tf-test-db"
    allocated_storage = "5"
    multi_az = "false"
    engine = "mysql"
    instance_class = "db.t2.small"
    username = "admin"
    password = "password123"
    db_subnet_group_name = "default"
    vpc_security_group_ids = [ "sg-1196246b" ]
    storage_type = "gp2"
    skip_final_snapshot = true
}