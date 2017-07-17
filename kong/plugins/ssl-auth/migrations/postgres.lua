return {
  {
    name = "2017-07-07-141911_init_sslauth",
    up = [[
      CREATE TABLE IF NOT EXISTS sslauth_credentials(
        id uuid,
        consumer_id uuid REFERENCES consumers (id) ON DELETE CASCADE,
        client_subject text UNIQUE,
        created_at timestamp without time zone default (CURRENT_TIMESTAMP(0) at time zone 'utc'),
        PRIMARY KEY (id)
      );

      DO $$
      BEGIN
        IF (SELECT to_regclass('sslauth_key_idx')) IS NULL THEN
          CREATE INDEX sslauth_key_idx ON sslauth_credentials(client_subject);
        END IF;
        IF (SELECT to_regclass('sslauth_consumer_idx')) IS NULL THEN
          CREATE INDEX sslauth_consumer_idx ON sslauth_credentials(consumer_id);
        END IF;
      END$$;
    ]],
    down = [[
      DROP TABLE sslauth_credentials;
    ]]
  }
}
