return {
  {
    name = "2017-07-07-141911_init_sslauth",
    up =  [[
      CREATE TABLE IF NOT EXISTS sslauth_credentials(
        id uuid,
        consumer_id uuid,
        client_subject text,
        created_at timestamp,
        PRIMARY KEY (id)
      );

      CREATE INDEX IF NOT EXISTS ON sslauth_credentials(client_subject);
      CREATE INDEX IF NOT EXISTS sslauth_consumer_id ON sslauth_credentials(consumer_id);
    ]],
    down = [[
      DROP TABLE sslauth_credentials;
    ]]
  }
}
