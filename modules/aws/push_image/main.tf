locals {
  docker_img_src_sha256 = sha256(join("", [for f in fileset(".", "${var.container_image_source_path}/**") : file(f)]))
  docker_build_command  = <<-EOT
        docker build --no-cache -t ${var.ecr_registry_uri}/${var.ecr_repository_name}:${var.container_image_tag} \
            -f ${var.container_image_source_path}/Dockerfile ${var.container_image_source_path}/

        aws ecr get-login-password --region ${var.region} | \
            docker login --username AWS --password-stdin ${var.ecr_registry_uri}

        docker push ${var.ecr_registry_uri}/${var.ecr_repository_name}:${var.container_image_tag}
    EOT
}

# local-exec for build and push of docker image
resource "null_resource" "build_push_docker_image" {
  triggers = {
    detect_docker_source_changes = var.force_image_rebuild == true ? timestamp() : local.docker_img_src_sha256
  }
  provisioner "local-exec" {
    command = local.docker_build_command
  }
}

