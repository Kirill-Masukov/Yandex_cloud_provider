terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  ztoken     = "y0_AgAAAABqT1WnAATuwQAADiI_aB6mclAmR9aXDf3Bkut5-lk"
  cloud_id  = "b1go4n5hoo0u8ji"
  folder_id = "b1gj2d8qm181ihre"
  zone      = "ru-central1-a"
}

resource "yandex_compute_image" "image-1" {
  name        = "base-prod"
  source_disk = "fhm5djm4n86jnt"
}
