# Current region being deployed into
data "aws_region" "current" {}

# Note: filter out wavelength zones if they're enabled in the account being deployed to.
data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "region-name"
    values = [data.aws_region.current.name]
  }

  # filter {
  #   name   = "opt-in-status"
  #   values = ["opt-in-not-required", "opted-in"]
  # }

  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}
