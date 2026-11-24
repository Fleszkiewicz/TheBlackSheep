import { describe, it, expect } from "vitest";
import {
  titleCaseName,
  parsePasajeros,
  parseServicios,
  validateDateRange,
} from "../src/utils/validation";

describe("titleCaseName", () => {
  it.each([
    ["franco LESZKIEWICZ", "Franco Leszkiewicz"],
    ["maría  josé", "María José"],
    ["o'brien", "O'Brien"],
    ["PÉREZ-GARCÍA", "Pérez-García"],
    ["j.c. ñandú", "J.C. Ñandú"],
  ])("%s -> %s", (input, expected) => {
    expect(titleCaseName(input)).toBe(expected);
  });

  it("deja null y vacío como están", () => {
    expect(titleCaseName(null)).toBeNull();
    expect(titleCaseName("")).toBe("");
  });
});

describe("parsePasajeros", () => {
  const titular = { es_titular: true, apellido: "pérez", nombre: "JUAN", dni: "30.123 456" };

  it("normaliza DNI y nombres", () => {
    const [p] = parsePasajeros([titular]);
    expect(p.dni).toBe("30123456");
    expect(p.apellido).toBe("Pérez");
    expect(p.nombre).toBe("Juan");
    expect(p.es_titular).toBe(true);
  });

  it("exige apellido", () => {
    expect(() => parsePasajeros([{ ...titular, apellido: "  " }])).toThrow(/apellido/);
  });

  it("rechaza una categoría de edad inválida", () => {
    expect(() => parsePasajeros([{ ...titular, categoria_edad: "anciano" }])).toThrow();
  });

  it("rechaza una lista vacía o que no es lista", () => {
    expect(() => parsePasajeros([])).toThrow();
    expect(() => parsePasajeros("x")).toThrow();
  });
});

describe("parseServicios", () => {
  const ok = { servicio_tipo_id: 1, valor: 100, moneda_id: 1, pagado_por: "pablo" };

  it("acepta un servicio válido", () => {
    expect(parseServicios([ok], "test")[0].servicio_tipo_id).toBe(1);
  });

  it("rechaza servicio sin tipo o con valor negativo", () => {
    expect(() => parseServicios([{ ...ok, servicio_tipo_id: 0 }], "test")).toThrow(/tipo/);
    expect(() => parseServicios([{ ...ok, valor: -1 }], "test")).toThrow(/Valor/);
  });
});

describe("validateDateRange", () => {
  it("fin anterior al inicio es inválido", () => {
    expect(validateDateRange(new Date("2026-12-10"), new Date("2026-12-01")).valid).toBe(false);
    expect(validateDateRange(new Date("2026-12-01"), new Date("2026-12-10")).valid).toBe(true);
  });
});
