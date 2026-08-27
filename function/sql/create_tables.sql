CREATE TABLE IF NOT EXISTS focos_queimadas (
    id          SERIAL PRIMARY KEY,
    lat         DOUBLE PRECISION NOT NULL,
    lon         DOUBLE PRECISION NOT NULL,
    municipio   VARCHAR(100),
    estado      VARCHAR(50),
    bioma       VARCHAR(50),
    satelite    VARCHAR(50),
    data_hora   TIMESTAMP,
    coletado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS ix_focos_queimadas_coletado_em ON focos_queimadas (coletado_em DESC);
CREATE INDEX IF NOT EXISTS ix_focos_queimadas_estado_bioma ON focos_queimadas (estado, bioma);

CREATE OR REPLACE VIEW vw_focos_recentes AS
SELECT id, lat, lon, municipio, estado, bioma, satelite, data_hora, coletado_em
FROM focos_queimadas
WHERE coletado_em >= NOW() - INTERVAL '24 hours';

SELECT COUNT(*) AS total_focos FROM focos_queimadas;
SELECT estado, COUNT(*) AS qtd FROM focos_queimadas GROUP BY estado ORDER BY qtd DESC;
SELECT * FROM focos_queimadas ORDER BY coletado_em DESC LIMIT 10;
