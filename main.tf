provider "google" {
  project = "bigquery-project-466916"
  region  = "us-central1"
}

# BigQuery Dataset
resource "google_bigquery_dataset" "etl_demo" {
  dataset_id = "etl_demo"
  location   = "US"
}

# BigQuery Table
resource "google_bigquery_table" "employees" {
  dataset_id = google_bigquery_dataset.etl_demo.dataset_id
  table_id   = "employees"

  schema = <<EOF
[
  {"name":"id","type":"INTEGER","mode":"REQUIRED"},
  {"name":"name","type":"STRING","mode":"NULLABLE"},
  {"name":"department","type":"STRING","mode":"NULLABLE"},
  {"name":"salary","type":"INTEGER","mode":"NULLABLE"}
]
EOF
}

# Cloud Storage Bucket
resource "google_storage_bucket" "etl_bucket" {
  name     = "my-etl-demo-bucket-${random_id.bucket_suffix.hex}"
  location = "US"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Cloud Function (Python)
resource "google_storage_bucket_object" "function_zip" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.etl_bucket.name
  source = "function-source.zip"
}

resource "google_cloudfunctions_function" "gcs_to_bq" {
  name        = "gcs_to_bq"
  description = "Load CSV from GCS into BigQuery"
  runtime     = "python39"
  region      = "us-central1"

  source_archive_bucket = google_storage_bucket.etl_bucket.name
  source_archive_object = google_storage_bucket_object.function_zip.name
  entry_point           = "gcs_to_bq"

  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.etl_bucket.name
  }
}
