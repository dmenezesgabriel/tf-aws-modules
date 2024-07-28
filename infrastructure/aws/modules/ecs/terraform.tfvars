
applications = {
  auth = {
    name                    = "auth"
    aws_ecr_repository_name = "ecs-todo-auth"
    image_tag               = "20240721220624"
    port                    = 80
    path                    = "/auth/"
    health_path             = "/auth/"

  }
  command = {
    name                    = "command"
    aws_ecr_repository_name = "ecs-todo-command"
    image_tag               = "20240721220624"
    port                    = 80
    path                    = "/command/"
    health_path             = "/command/"
  }
}
