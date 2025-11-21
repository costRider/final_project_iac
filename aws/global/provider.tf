########################################
#   2025.11.15 -LMK
#    - module 분리 구조 작성
#   backend와 provider 정의
########################################


provider "aws" {
  region = var.aws_region

  #root 하위의 모듈에서 생성하는 리소스에 Tag가 자동으로 붙는다.
  default_tags {
    tags = local.common_tags
  }

}

