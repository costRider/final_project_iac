 #처음엔 local backend로 (추후 S3로 변경)
  terraform {
    backend "local" {
        path = "terraform.tfstate"
    }
  }