ALTER TABLE matches
    ADD COLUMN external_source VARCHAR(40),
    ADD COLUMN external_id VARCHAR(64);

CREATE UNIQUE INDEX uk_matches_external_source_external_id
    ON matches (external_source, external_id)
    WHERE external_source IS NOT NULL AND external_id IS NOT NULL;

CREATE INDEX ix_matches_external_id ON matches (external_id);
