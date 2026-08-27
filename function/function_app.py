import azure.functions as func
import requests
import psycopg2
import os
import logging
from datetime import datetime, timedelta

app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)

BASE_URL = (
    "https://dataserver-coids.inpe.br"
    "/queimadas/queimadas/focos/csv/diario/Brasil/"
)

def get_connection():
    return psycopg2.connect(
        host=os.environ["SQL_SERVER"],
        user=os.environ["SQL_USER"],
        password=os.environ["SQL_PASS"],
        dbname=os.environ["SQL_DB"],
        sslmode="require",
        connect_timeout=30
    )

def criar_tabela_se_nao_existir(cursor):
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS focos_queimadas (
            id          SERIAL PRIMARY KEY,
            lat         DOUBLE PRECISION,
            lon         DOUBLE PRECISION,
            municipio   VARCHAR(100),
            estado      VARCHAR(50),
            bioma       VARCHAR(50),
            satelite    VARCHAR(50),
            data_hora   TIMESTAMP,
            coletado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)

def buscar_focos_inpe(data):
    data_fmt = data.replace("-", "")
    url = f"{BASE_URL}focos_diario_br_{data_fmt}.csv"
    logging.info(f"Baixando: {url}")

    resp = requests.get(url, timeout=60)
    resp.raise_for_status()

    focos = []
    lines = resp.text.splitlines()
    if len(lines) < 2:
        return focos

    header = [h.strip() for h in lines[0].split(",")]
    for line in lines[1:]:
        parts = line.split(",")
        if len(parts) < len(header):
            continue
        row = dict(zip(header, parts))
        focos.append(row)
    return focos

def inserir_focos(cursor, focos):
    total = 0
    for foco in focos:
        try:
            cursor.execute(
                """
                INSERT INTO focos_queimadas
                    (lat, lon, municipio, estado, bioma, satelite, data_hora)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
                """,
                (
                    float(foco.get("lat", 0) or 0),
                    float(foco.get("lon", 0) or 0),
                    foco.get("municipio", "").strip(),
                    foco.get("estado", "").strip(),
                    foco.get("bioma", "").strip(),
                    foco.get("satelite", "").strip(),
                    foco.get("data_hora_gmt", "").strip(),
                )
            )
            total = total + 1
        except Exception as e:
            logging.warning(f"Erro ao inserir foco: {e} | dados: {foco}")
            continue
    return total

@app.route(route="coleta", methods=["GET", "POST"])
def coleta_queimadas(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Iniciando coleta de focos de queimadas (HTTP Trigger)...")

    data_param = req.params.get("data")
    if not data_param:
        data_param = (datetime.utcnow() - timedelta(days=1)).strftime("%Y-%m-%d")

    try:
        focos = buscar_focos_inpe(data_param)
    except Exception as e:
        logging.error(f"Erro ao buscar dados do INPE: {e}")
        return func.HttpResponse(f"Erro ao buscar dados do INPE: {e}", status_code=500)

    try:
        conn = get_connection()
        cursor = conn.cursor()
        criar_tabela_se_nao_existir(cursor)
        total = inserir_focos(cursor, focos)
        conn.commit()
        conn.close()
    except Exception as e:
        logging.error(f"Erro ao salvar no banco: {e}")
        return func.HttpResponse(f"Erro ao salvar no banco: {e}", status_code=500)

    return func.HttpResponse(
        f"{total} focos salvos com sucesso para a data {data_param}.",
        status_code=200
    )
