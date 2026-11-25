// Tests de API contra la base de DESARROLLO (.env.dev). Crean datos de prueba y los borran al final.
// El token se firma localmente con el secreto de .env.dev (el login real es con Google).
import { describe, it, expect, beforeAll, afterAll } from "vitest";
import request from "supertest";
import type { RowDataPacket } from "mysql2";
import { app } from "../src/config/app";
import { db } from "../src/db/db";
import { generateAccessToken } from "../src/utils/utils";

const auth = {
  Authorization: `Bearer ${generateAccessToken({ auth: true, email: "test@local", nombre: "Test", avatar: "" })}`,
};

const DNI_TITULAR = "99000001";
const DNI_ACOMPANANTE = "99000002";
const legajosCreados: string[] = [];
const expensasCreadas: number[] = [];
let tipoServicioId = 1;

const body = (over: Record<string, unknown> = {}) => ({
  valor_total: 1000000,
  valor_total_usd: 0,
  destino: "nacional",
  fecha: "2026-11-24",
  fecha_ida: "2027-03-01",
  fecha_vuelta: "2027-03-10",
  moneda: 1,
  cotizacion: null,
  sucursal_id: 1,
  pago: "cuotas",
  pasajeros: [
    { es_titular: true, dni: "99.000.001", nombre: "test TITULAR", apellido: "PRUEBA vitest", vencimiento_dni: "2035-01-01", categoria_edad: "adulto" },
    { es_titular: false, dni: DNI_ACOMPANANTE, nombre: "ana", apellido: "prueba", vencimiento_dni: "2035-01-01", categoria_edad: "menor" },
  ],
  destinos: [
    {
      destino: "Bariloche",
      fecha_desde: "2027-03-01",
      fecha_hasta: "2027-03-05",
      servicios: [{ servicio_tipo_id: tipoServicioId, valor: 500000, moneda_id: 1, cotizacion: null, pagado_por: "pablo", observacion: "hotel" }],
    },
  ],
  ...over,
});

beforeAll(async () => {
  // Salvaguarda: nunca correr contra producción
  const [[row]] = await db.query<RowDataPacket[]>("SELECT DATABASE() AS db");
  if (!/test/i.test(String(row.db))) {
    throw new Error(`Base inesperada para tests: ${row.db}`);
  }
  const res = await request(app).get("/api/services").set(auth);
  tipoServicioId = res.body.data[0].id;
});

afterAll(async () => {
  for (const legajo of legajosCreados) {
    await request(app).delete(`/api/trips/${legajo}`).set(auth);
  }
  for (const id of expensasCreadas) {
    await request(app).delete(`/api/expenses/${id}`).set(auth);
  }
  // Los pasajeros de prueba quedan en el maestro: se borran si ya no están en ningún viaje
  await db.query(
    "DELETE p FROM pasajeros p LEFT JOIN viaje_pasajeros vp ON vp.pasajero_id = p.id WHERE p.dni IN (?, ?) AND vp.pasajero_id IS NULL",
    [DNI_TITULAR, DNI_ACOMPANANTE],
  );
  await db.end();
});

describe("autenticación", () => {
  it("sin token -> 401", async () => {
    expect((await request(app).get("/api/trips")).status).toBe(401);
  });
  it("token inválido -> 401", async () => {
    const res = await request(app).get("/api/trips").set({ Authorization: "Bearer abc.def.ghi" });
    expect(res.status).toBe(401);
  });
});

describe("tipos de servicio", () => {
  it("GET /api/services devuelve la lista", async () => {
    const res = await request(app).get("/api/services").set(auth);
    expect(res.status).toBe(200);
    expect(res.body.data.length).toBeGreaterThan(0);
  });
  it("los endpoints viejos de servicios sueltos ya no existen", async () => {
    const res = await request(app).post("/api/services").set(auth).send({});
    expect(res.status).toBe(404);
  });
});

describe("validaciones al crear un expediente", () => {
  it("fin anterior al inicio -> 400", async () => {
    const res = await request(app).post("/api/trips").set(auth).send(body({ fecha_ida: "2027-03-10", fecha_vuelta: "2027-03-01", destinos: [] }));
    expect(res.status).toBe(400);
  });
  it("destino fuera del rango del viaje -> 400", async () => {
    const res = await request(app).post("/api/trips").set(auth).send(
      body({ destinos: [{ destino: "Salta", fecha_desde: "2027-02-01", fecha_hasta: "2027-03-02", servicios: [] }] }),
    );
    expect(res.status).toBe(400);
  });
  it("sin pasajeros -> 422 (validador de esquema) con mensaje", async () => {
    const res = await request(app).post("/api/trips").set(auth).send(body({ pasajeros: [] }));
    expect(res.status).toBe(422);
    expect(res.body.error).toMatch(/pasajero/i);
  });
});

describe("ciclo de vida de un expediente", () => {
  let legajo = "";

  it("crea el expediente con legajo de Baradero", async () => {
    const res = await request(app).post("/api/trips").set(auth).send(body());
    expect(res.status).toBe(201);
    legajo = res.body.data.id;
    legajosCreados.push(legajo);
    expect(legajo).toMatch(/^TBSB\d{3,}$/);
  });

  it("lo devuelve completo, con nombres normalizados y En espera", async () => {
    const res = await request(app).get(`/api/trips/${legajo}`).set(auth);
    expect(res.status).toBe(200);
    const t = res.body.data;
    expect(t.nombre).toBe("Test Titular");
    expect(t.apellido).toBe("Prueba Vitest");
    expect(t.sucursal_id).toBe(1);
    expect(t.pasajeros).toHaveLength(2);
    expect(t.destinos).toHaveLength(1);
    expect(t.destinos[0].servicios).toHaveLength(1);
    expect(t.estado).toBe("en espera");
  });

  it("aparece al filtrar por Baradero y no por Hurlingham", async () => {
    const bar = await request(app).get("/api/trips").query({ search: legajo, sucursal: "baradero" }).set(auth);
    const hur = await request(app).get("/api/trips").query({ search: legajo, sucursal: "hurlingham" }).set(auth);
    expect(bar.body.data.map((t: { id: string }) => t.id)).toContain(legajo);
    expect(hur.body.data.map((t: { id: string }) => t.id)).not.toContain(legajo);
  });

  it("autocompletado de pasajeros por DNI", async () => {
    const res = await request(app).get("/api/pasajeros").query({ dni: DNI_TITULAR }).set(auth);
    expect(res.status).toBe(200);
    expect(res.body.data.some((p: { dni: string }) => p.dni === DNI_TITULAR)).toBe(true);
  });

  it("un servicio sin pagar deja el expediente Pendiente", async () => {
    const actual = (await request(app).get(`/api/trips/${legajo}`).set(auth)).body.data;
    const d = actual.destinos[0];
    const res = await request(app).patch(`/api/trips/${legajo}`).set(auth).send({
      destinos: [{
        destino_id: d.destino_id,
        destino: d.destino,
        fecha_desde: "2027-03-01",
        fecha_hasta: "2027-03-05",
        servicios: [{ servicio_tipo_id: tipoServicioId, valor: 500000, moneda_id: 1, cotizacion: null, pagado_por: "pendiente", observacion: "hotel" }],
      }],
    });
    expect(res.status).toBe(200);
    const despues = (await request(app).get(`/api/trips/${legajo}`).set(auth)).body.data;
    expect(despues.estado).toBe("pendiente");
    expect(despues.destinos[0].destino_id).toBe(d.destino_id); // conserva el id del destino
  });

  it("distribución: marca a mariana y rechaza un socio inexistente", async () => {
    const ok = await request(app).put(`/api/trips/${legajo}/distribucion/mariana`).set(auth).send({ abonado: true });
    expect(ok.status).toBe(200);
    const lista = await request(app).get(`/api/trips/${legajo}/distribucion`).set(auth);
    expect(lista.body.data.map((p: { socio: string }) => p.socio)).toContain("mariana");
    const mal = await request(app).put(`/api/trips/${legajo}/distribucion/marian`).set(auth).send({ abonado: true });
    expect(mal.status).toBe(400);
  });

  it("archivos: lista vacía, presign válido y tipo de archivo rechazado", async () => {
    const lista = await request(app).get(`/api/trips/${legajo}/archivos`).set(auth);
    expect(lista.status).toBe(200);
    expect(lista.body.data).toEqual([]);
    const ok = await request(app).post(`/api/trips/${legajo}/archivos/presign`).set(auth)
      .send({ nombre: "voucher.pdf", mime: "application/pdf", size: 1000, categoria: "Servicios" });
    expect(ok.status).toBe(200);
    expect(ok.body.data.url).toMatch(/^https?:\/\//);
    const mal = await request(app).post(`/api/trips/${legajo}/archivos/presign`).set(auth)
      .send({ nombre: "virus.exe", mime: "application/x-msdownload", size: 1000, categoria: "Otros" });
    expect(mal.status).toBe(400);
  });

  it("cancela y revierte la cancelación", async () => {
    const sinMotivo = await request(app).post(`/api/trips/${legajo}/cancel`).set(auth).send({});
    expect(sinMotivo.status).toBe(422);
    expect(sinMotivo.body.error).toBeTruthy();
    const textoLibre = await request(app).post(`/api/trips/${legajo}/cancel`).set(auth).send({ categoria: "Prueba automática" });
    expect(textoLibre.status).toBe(422);
    expect((await request(app).post(`/api/trips/${legajo}/cancel`).set(auth).send({ categoria: "cambio_planes" })).status).toBe(200);
    const cancelado = (await request(app).get(`/api/trips/${legajo}`).set(auth)).body.data;
    expect(cancelado.estado).toBe("cancelado");
    expect(cancelado.categoria_cancelacion).toBe("cambio_planes");
    expect((await request(app).post(`/api/trips/${legajo}/revert-cancel`).set(auth)).status).toBe(200);
    const revertido = (await request(app).get(`/api/trips/${legajo}`).set(auth)).body.data;
    expect(revertido.estado).not.toBe("cancelado");
    expect(revertido.categoria_cancelacion).toBeNull();
  });

  it("elimina el expediente", async () => {
    expect((await request(app).delete(`/api/trips/${legajo}`).set(auth)).status).toBe(200);
    legajosCreados.splice(legajosCreados.indexOf(legajo), 1);
    expect((await request(app).get(`/api/trips/${legajo}`).set(auth)).status).toBe(404);
  });
});

describe("finanzas", () => {
  it("resumen del año", async () => {
    const res = await request(app).get("/api/finance").query({ anio: 2026 }).set(auth);
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body.data)).toBe(true);
  });
  it("sin año -> 400", async () => {
    expect((await request(app).get("/api/finance").set(auth)).status).toBe(400);
  });
});

describe("dashboard", () => {
  const vistas = {
    expedientes: ["kpis", "estados", "sucursales", "evolucion", "motivos"],
    productos: ["kpis", "destinos", "servicios", "tipos", "edades"],
    finanzas: ["kpis", "mensual", "pagos", "monedas", "socios"],
    expensas: ["kpis", "mensual", "sucursales"],
  };

  it.each(Object.entries(vistas))("%s devuelve KPI y series", async (vista, sets) => {
    const res = await request(app).get(`/api/dashboard/${vista}`).query({ anio: 2026, sucursal: "baradero" }).set(auth);
    expect(res.status).toBe(200);
    expect(Object.keys(res.body.data).sort()).toEqual([...sets].sort());
    expect(typeof res.body.data.kpis).toBe("object");
  });

  it("los importes llegan como número y la evolución ignora el mes", async () => {
    const anual = (await request(app).get("/api/dashboard/finanzas").query({ anio: 2026 }).set(auth)).body.data;
    const mes = (await request(app).get("/api/dashboard/finanzas").query({ anio: 2026, mes: 1 }).set(auth)).body.data;
    expect(typeof anual.kpis.facturacion_ars).toBe("number");
    expect(mes.mensual).toEqual(anual.mensual);
  });

  it("sin año -> 400; sección inexistente -> 404", async () => {
    expect((await request(app).get("/api/dashboard/finanzas").set(auth)).status).toBe(400);
    expect((await request(app).get("/api/dashboard/otra").query({ anio: 2026 }).set(auth)).status).toBe(404);
  });
});

describe("expensas", () => {
  it("crea, lista y elimina una expensa", async () => {
    const res = await request(app).post("/api/expenses").set(auth)
      .send({ motivo: "Prueba automática", fecha: "2026-11-24", moneda: 1, monto: 1234, sucursal: "baradero" });
    expect(res.status).toBe(201);
    const id = res.body.data.id;
    expensasCreadas.push(id);
    const lista = await request(app).get("/api/expenses").query({ year: 2026, month: 11 }).set(auth);
    expect(lista.status).toBe(200);
    expect((await request(app).delete(`/api/expenses/${id}`).set(auth)).status).toBe(200);
    expensasCreadas.splice(expensasCreadas.indexOf(id), 1);
  });
  it("sin motivo -> 422 (validador de esquema) con mensaje", async () => {
    const res = await request(app).post("/api/expenses").set(auth)
      .send({ motivo: "", fecha: "2026-11-24", moneda: 1, monto: 1234, sucursal: "baradero" });
    expect(res.status).toBe(422);
    expect(res.body.error).toBeTruthy();
  });
});
