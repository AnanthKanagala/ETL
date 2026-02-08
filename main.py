from google.cloud import bigquery

def gcs_to_bq(event, context):
    client = bigquery.Client()
    table_id = "bigquery-project-466916.etl_demo.employees"

    uri = f"gs://{event['bucket']}/{event['name']}"

    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.CSV,
        autodetect=True,
        write_disposition="WRITE_APPEND"
    )

    load_job = client.load_table_from_uri(uri, table_id, job_config=job_config)
    load_job.result()
