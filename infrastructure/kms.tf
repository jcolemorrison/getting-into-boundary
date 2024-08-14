resource "aws_kms_key" "eks_cluster" {
  description             = "KMS key for EKS secrets"
  deletion_window_in_days = 7

  policy = data.aws_iam_policy_document.eks_kms.json
}

data "aws_iam_policy_document" "eks_kms" {
  statement {
    sid       = "RootAccount"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid = "KeyAdministration"
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
      "kms:ReplicateKey",
      "kms:ImportKeyMaterial"
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["${data.aws_iam_session_context.current.issuer_arn}"]
    }
  }

  statement {
    sid = "KeyUsage"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_role.eks_cluster.arn}"]
    }
  }
}