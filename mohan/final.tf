# terraform {
#     required_providers {
#         aws = {
#             source = "hashicorp/aws"
#             version = "~> 3.0"
#         }
#     }
# }

# provider "aws" {
#     region = "us-west-1"
# }

# resource "aws_lb" "ElasticLoadBalancingV2LoadBalancer" {
#     name = "dentalx-selenium-grid-alb"
#     internal = false
#     load_balancer_type = "application"
#     subnets = [
#         "subnet-04ac0f0df7be8c8b7",
#         "subnet-0de0d78ca91d25953"
#     ]
#     security_groups = [
#         "${aws_security_group.EC2SecurityGroup2.id}"
#     ]
#     ip_address_type = "ipv4"
#     access_logs {
#         enabled = false
#         bucket = ""
#         prefix = ""
#     }
#     idle_timeout = "60"
#     enable_deletion_protection = "false"
#     enable_http2 = "true"
#     enable_cross_zone_load_balancing = "true"
# }

# resource "aws_lb_listener" "ElasticLoadBalancingV2Listener" {
#     load_balancer_arn = "arn:aws:elasticloadbalancing:us-west-1:778525181753:loadbalancer/app/dentalx-selenium-grid-alb/eea5ca7b48d7bf6c"
#     port = 80
#     protocol = "HTTP"
#     default_action {
#         target_group_arn = "arn:aws:elasticloadbalancing:us-west-1:778525181753:targetgroup/dental-Denta-IDL5QTCY1MWQ/8832a22b3bbc26b2"
#         type = "forward"
#     }
# }

# resource "aws_security_group" "EC2SecurityGroup" {
#     description = "dentalx-selenium-automation-stack/DentalXChangeSeleniumCluster/dentalxchange-selenium-sg"
#     name = "dentalx-selenium-automation-stack-DentalXChangeSeleniumClusterdentalxchangeseleniumsg39207702-91WBWV6YUI67"
#     tags = {}
#     vpc_id = "vpc-0f21c16a174e9a436"
#     ingress {
#         cidr_blocks = [
#             "0.0.0.0/0"
#         ]
#         description = "Port 4442 for inbound traffic"
#         from_port = 4442
#         protocol = "tcp"
#         to_port = 4442
#     }
#     ingress {
#         cidr_blocks = [
#             "0.0.0.0/0"
#         ]
#         description = "Port 4444 for inbound traffic"
#         from_port = 4444
#         protocol = "tcp"
#         to_port = 4444
#     }
#     ingress {
#         security_groups = [
#             "${aws_security_group.EC2SecurityGroup2.id}"
#         ]
#         description = "Load balancer to target"
#         from_port = 4444
#         protocol = "tcp"
#         to_port = 4444
#     }
#     ingress {
#         cidr_blocks = [
#             "0.0.0.0/0"
#         ]
#         description = "Port 5555 for inbound traffic"
#         from_port = 5555
#         protocol = "tcp"
#         to_port = 5555
#     }
#     ingress {
#         cidr_blocks = [
#             "0.0.0.0/0"
#         ]
#         description = "Port 4443 for inbound traffic"
#         from_port = 4443
#         protocol = "tcp"
#         to_port = 4443
#     }
#     egress {
#         cidr_blocks = [
#             "0.0.0.0/0"
#         ]
#         description = "Allow all outbound traffic by default"
#         from_port = 0
#         protocol = "-1"
#         to_port = 0
#     }
# }

# resource "aws_security_group" "EC2SecurityGroup2" {
#     description = "dentalx-selenium-automation-stack/DentalXChangeSeleniumCluster/dentalxchange-selenium-alb-sg"
#     name = "dentalx-selenium-automation-stack-DentalXChangeSeleniumClusterdentalxchangeseleniumalbsg7211715A-1SATDMSQ90BMJ"
#     tags = {}
#     vpc_id = "vpc-0f21c16a174e9a436"
#     ingress {
#         cidr_blocks = [
#             "0.0.0.0/0"
#         ]
#         description = "Port 80 for inbound traffic"
#         from_port = 80
#         protocol = "tcp"
#         to_port = 80
#     }
#     egress {
#         cidr_blocks = [
#             "0.0.0.0/0"
#         ]
#         description = "Allow all outbound traffic by default"
#         from_port = 0
#         protocol = "-1"
#         to_port = 0
#     }
# }

# resource "aws_lb_target_group" "ElasticLoadBalancingV2TargetGroup" {
#     health_check {
#         interval = 120
#         path = "/status"
#         port = "4444"
#         protocol = "HTTP"
#         timeout = 5
#         unhealthy_threshold = 2
#         healthy_threshold = 5
#         matcher = "200"
#     }
#     port = 80
#     protocol = "HTTP"
#     target_type = "ip"
#     vpc_id = "vpc-0f21c16a174e9a436"
#     name = "dental-Denta-IDL5QTCY1MWQ"
# }

# resource "aws_ecs_cluster" "ECSCluster" {
#     name = "dentalx-selenium-grid-cluster"
# }

# resource "aws_ecs_service" "ECSService" {
#     name = "dentalx-se-chrome-node-service"
#     cluster = "arn:aws:ecs:us-west-1:778525181753:cluster/dentalx-selenium-grid-cluster"
#     desired_count = 1
#     launch_type = "FARGATE"
#     platform_version = "LATEST"
#     task_definition = "${aws_ecs_task_definition.ECSTaskDefinition.arn}"
#     deployment_maximum_percent = 200
#     deployment_minimum_healthy_percent = 100
#     iam_role = "arn:aws:iam::778525181753:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
#     network_configuration {
#         assign_public_ip = "DISABLED"
#         security_groups = [
#             "${aws_security_group.EC2SecurityGroup.id}"
#         ]
#         subnets = [
#             "subnet-0de0d78ca91d25953",
#             "subnet-04ac0f0df7be8c8b7"
#         ]
#     }
#     scheduling_strategy = "REPLICA"
# }

# resource "aws_ecs_service" "ECSService2" {
#     name = "dentalx-se-hub-service"
#     cluster = "arn:aws:ecs:us-west-1:778525181753:cluster/dentalx-selenium-grid-cluster"
#     load_balancer {
#         target_group_arn = "arn:aws:elasticloadbalancing:us-west-1:778525181753:targetgroup/dental-Denta-IDL5QTCY1MWQ/8832a22b3bbc26b2"
#         container_name = "selenium-hub-container"
#         container_port = 4444
#     }
#     desired_count = 1
#     launch_type = "FARGATE"
#     platform_version = "LATEST"
#     task_definition = "${aws_ecs_task_definition.ECSTaskDefinition2.arn}"
#     deployment_maximum_percent = 200
#     deployment_minimum_healthy_percent = 100
#     iam_role = "arn:aws:iam::778525181753:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
#     network_configuration {
#         assign_public_ip = "DISABLED"
#         security_groups = [
#             "${aws_security_group.EC2SecurityGroup.id}"
#         ]
#         subnets = [
#             "subnet-0de0d78ca91d25953",
#             "subnet-04ac0f0df7be8c8b7"
#         ]
#     }
#     health_check_grace_period_seconds = 300
#     scheduling_strategy = "REPLICA"
# }

# resource "aws_ecs_task_definition" "ECSTaskDefinition" {
#     container_definitions = "[{\"name\":\"selenium-chrome-container\",\"image\":\"selenium/node-chrome:4.11.0\",\"cpu\":512,\"memory\":1024,\"links\":[],\"portMappings\":[{\"containerPort\":4444,\"hostPort\":4444,\"protocol\":\"tcp\"},{\"containerPort\":5555,\"hostPort\":5555,\"protocol\":\"tcp\"},{\"containerPort\":4443,\"hostPort\":4443,\"protocol\":\"tcp\"},{\"containerPort\":4442,\"hostPort\":4442,\"protocol\":\"tcp\"}],\"essential\":true,\"entryPoint\":[\"sh\",\"-c\"],\"command\":[\"PRIVATE=$(curl -s http://169.254.170.2/v2/metadata | jq -r '.Containers[0].Networks[0].IPv4Addresses[0]') ; export SE_OPTS=\\\"--host $PRIVATE\\\" ; /opt/bin/entry_point.sh\"],\"environment\":[{\"name\":\"SE_EVENT_BUS_PUBLISH_PORT\",\"value\":\"4442\"},{\"name\":\"SE_EVENT_BUS_HOST\",\"value\":\"dentalx-se-hub\"},{\"name\":\"NODE_MAX_SESSION\",\"value\":\"100\"},{\"name\":\"NODE_MAX_INSTANCES\",\"value\":\"100\"},{\"name\":\"SE_EVENT_BUS_SUBSCRIBE_PORT\",\"value\":\"4443\"},{\"name\":\"SE_OPTS\",\"value\":\"--log-level FINE\"}],\"environmentFiles\":[],\"mountPoints\":[],\"volumesFrom\":[],\"secrets\":[],\"dnsServers\":[],\"dnsSearchDomains\":[],\"extraHosts\":[],\"dockerSecurityOptions\":[],\"dockerLabels\":{},\"ulimits\":[],\"logConfiguration\":{\"logDriver\":\"awslogs\",\"options\":{\"awslogs-group\":\"dentalx-selenium-automation-stack-DentalXChangeSeleniumClusterdentalxseleniumchrometaskdefseleniumchromecontainerLogGroup7725DC1E-rGCUt3TMVUSe\",\"awslogs-region\":\"us-west-1\",\"awslogs-stream-prefix\":\"selenium-chrome-logs\"},\"secretOptions\":[]},\"systemControls\":[]}]"
#     family = "dentalxseleniumautomationstackDentalXChangeSeleniumClusterdentalxseleniumchrometaskdef5AB4A96A"
#     task_role_arn = "arn:aws:iam::778525181753:role/dentalx-selenium-automati-DentalXChangeSeleniumClu-174NCNFXUH0C2"
#     execution_role_arn = "arn:aws:iam::778525181753:role/dentalx-selenium-automati-DentalXChangeSeleniumClu-16XYLEIAGZ0PI"
#     network_mode = "awsvpc"
#     requires_compatibilities = [
#         "FARGATE"
#     ]
#     cpu = "512"
#     memory = "1024"
# }

# resource "aws_ecs_task_definition" "ECSTaskDefinition2" {
#     container_definitions = "[{\"name\":\"selenium-hub-container\",\"image\":\"selenium/hub:4.11.0\",\"cpu\":1024,\"memory\":2048,\"links\":[],\"portMappings\":[{\"containerPort\":4444,\"hostPort\":4444,\"protocol\":\"tcp\"},{\"containerPort\":5555,\"hostPort\":5555,\"protocol\":\"tcp\"},{\"containerPort\":4443,\"hostPort\":4443,\"protocol\":\"tcp\"},{\"containerPort\":4442,\"hostPort\":4442,\"protocol\":\"tcp\"}],\"essential\":true,\"entryPoint\":[],\"command\":[],\"environment\":[{\"name\":\"SE_OPTS\",\"value\":\"--log-level FINE\"}],\"environmentFiles\":[],\"mountPoints\":[],\"volumesFrom\":[],\"secrets\":[],\"dnsServers\":[],\"dnsSearchDomains\":[],\"extraHosts\":[],\"dockerSecurityOptions\":[],\"dockerLabels\":{},\"ulimits\":[],\"logConfiguration\":{\"logDriver\":\"awslogs\",\"options\":{\"awslogs-group\":\"dentalx-selenium-automation-stack-DentalXChangeSeleniumClusterdentalxseleniumhubtaskdefseleniumhubcontainerLogGroupDEB2661A-vBlkimbfUYRY\",\"awslogs-region\":\"us-west-1\",\"awslogs-stream-prefix\":\"selenium-hub-logs\"},\"secretOptions\":[]},\"systemControls\":[]}]"
#     family = "dentalxseleniumautomationstackDentalXChangeSeleniumClusterdentalxseleniumhubtaskdef41FF6FE8"
#     task_role_arn = "arn:aws:iam::778525181753:role/dentalx-selenium-automati-DentalXChangeSeleniumClu-T2IC6YVISWHL"
#     execution_role_arn = "arn:aws:iam::778525181753:role/dentalx-selenium-automati-DentalXChangeSeleniumClu-OH9UUG5OZGOM"
#     network_mode = "awsvpc"
#     requires_compatibilities = [
#         "FARGATE"
#     ]
#     cpu = "1024"
#     memory = "2048"
# }
