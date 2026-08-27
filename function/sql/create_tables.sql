CREATE TABLE IF NOT EXISTS focos_queimadas (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    lat         DOUBLE NOT NULL,
    lon         DOUBLE NOT NULL,
    municipio   VARCHAR(100),
    estado      VARCHAR(50),
    bioma       VARCHAR(50),
    satelite    VARCHAR(50),
    data_hora   DATETIME,
    coletado_em DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IX_focos_queimadas_coletado_em ON focos_queimadas (coletado_em DESC);
CREATE INDEX IX_focos_queimadas_estado_bioma ON focos_queimadas (estado, bioma);

CREATE OR REPLACE VIEW vw_focos_recentes AS
SELECT id, lat, lon, municipio, estado, bioma, satelite, data_hora, coletado_em
FROM focos_queimadas
WHERE coletado_em >= NOW() - INTERVAL 24 HOUR;
